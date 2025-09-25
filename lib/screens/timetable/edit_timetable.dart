import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../viewmodel/timetable_vm.dart';

class Course {
  final String courseId;
  final String courseName;

  Course({required this.courseId, required this.courseName});

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['course_id']?.toString() ?? '',
      courseName: map['course_name'] ?? '',
    );
  }
}

class EditTimetableScreen extends ConsumerStatefulWidget {
  const EditTimetableScreen({super.key});

  @override
  ConsumerState<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends ConsumerState<EditTimetableScreen> {
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  final List<String> dayKeys = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final List<String> timeSlots = [
    "9:10 AM - 10:00 AM",
    "10:05 AM - 10:55 AM",
    "11:00 AM - 11:50 AM",
    "11:50 AM - 12:40 PM",
    "12:40 PM - 1:30 PM",
    "1:30 PM - 2:20 PM",
    "2:20 PM - 3:10 PM",
    "3:10 PM - 4:00 PM",
  ];

  int selectedDayIndex = 0;
  List<String?> selectedCourseIds = [];
  List<TextEditingController> classroomControllers = [];
  List<Course> availableCourses = [];
  bool isSubmitting = false;
  bool isLoadingCourses = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and selected courses for each time slot
    for (int i = 0; i < timeSlots.length; i++) {
      selectedCourseIds.add(null);
      classroomControllers.add(TextEditingController());
    }
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
      ref.read(slotsProvider.notifier).fetchSlots();
    });
  }

  @override
  void dispose() {
    for (var controller in classroomControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoadingCourses = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userEmail = supabase.auth.currentUser?.email;

      if (userEmail == null) {
        throw Exception("User not logged in");
      }

      // Get user's program_id
      final userData = await supabase
          .from('users')
          .select('program_id')
          .eq('email', userEmail)
          .single();

      final programId = userData['program_id'];

      // Fetch courses for this program
      final response = await supabase
          .from('courses')
          .select('course_id, course_name')
          .eq('program_id', programId)
          .order('course_name', ascending: true);

      final courses = (response as List<dynamic>)
          .map((course) => Course.fromMap(course as Map<String, dynamic>))
          .toList();

      setState(() {
        availableCourses = courses;
        isLoadingCourses = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCourses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading courses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadDataForSelectedDay() {
    final timetableState = ref.read(slotsProvider);
    final selectedDay = dayKeys[selectedDayIndex];

    // Clear all selections and controllers first
    for (int i = 0; i < selectedCourseIds.length; i++) {
      selectedCourseIds[i] = null;
      classroomControllers[i].clear();
    }

    // Load existing data for the selected day
    final daySlots = timetableState.slots.where((slot) => slot.day == selectedDay).toList();

    for (var slot in daySlots) {
      // Find the matching time slot index
      final timeString = "${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}";
      final timeIndex = timeSlots.indexOf(timeString);

      if (timeIndex != -1) {
        selectedCourseIds[timeIndex] = slot.courseId;
        classroomControllers[timeIndex].text = slot.classCode;
      }
    }

    setState(() {}); // Refresh UI
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "$displayHour:${minute.toString().padLeft(2, '0')} $period";
  }

  DateTime _parseTime(String timeString, DateTime baseDate) {
    final parts = timeString.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final timeParts = timePart.split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  Future<void> _submitTimetable() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userEmail = supabase.auth.currentUser?.email;

      if (userEmail == null) {
        throw Exception("User not logged in");
      }

      // Get user's program_id
      final userData = await supabase
          .from('users')
          .select('program_id')
          .eq('email', userEmail)
          .single();

      final programId = userData['program_id'];
      final selectedDay = dayKeys[selectedDayIndex];
      final baseDate = DateTime.now();

      // First, get existing timetable entries for this day to get their IDs
      final existingEntries = await supabase
          .from('timetable')
          .select('t_id, start_time, end_time')
          .eq('program_id', programId)
          .eq('day', selectedDay);

      // Prepare entries for upsert
      final List<Map<String, dynamic>> upsertEntries = [];

      for (int i = 0; i < timeSlots.length; i++) {
        final courseId = selectedCourseIds[i];
        final classroom = classroomControllers[i].text.trim();

        final timeRange = timeSlots[i].split(' - ');
        final startTime = _parseTime(timeRange[0], baseDate);
        final endTime = _parseTime(timeRange[1], baseDate);

        // Find matching existing entry by time
        Map<String, dynamic>? existingEntry;
        for (var entry in existingEntries) {
          final existingStart = DateTime.parse(entry['start_time']).toLocal();
          final existingEnd = DateTime.parse(entry['end_time']).toLocal();

          // Compare times (ignoring date part)
          if (existingStart.hour == startTime.hour &&
              existingStart.minute == startTime.minute &&
              existingEnd.hour == endTime.hour &&
              existingEnd.minute == endTime.minute) {
            existingEntry = entry;
            break;
          }
        }

        if (courseId != null && courseId.isNotEmpty) {
          // Create or update entry
          final entryData = {
            'program_id': programId,
            'course_id': courseId,
            'class_code': classroom.isNotEmpty ? classroom : null,
            'day': selectedDay,
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
          };

          // If existing entry found, include t_id for update
          if (existingEntry != null) {
            entryData['t_id'] = existingEntry['t_id'];
          }

          upsertEntries.add(entryData);
        } else if (existingEntry != null) {
          // Delete entry if no course selected but entry exists
          await supabase
              .from('timetable')
              .delete()
              .eq('t_id', existingEntry['t_id']);
        }
      }

      // Perform upsert operation
      if (upsertEntries.isNotEmpty) {
        await supabase
            .from('timetable')
            .upsert(upsertEntries, onConflict: 't_id');
      }

      // Refresh the timetable data
      await ref.read(slotsProvider.notifier).fetchSlots();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timetable updated successfully for ${days[selectedDayIndex]}'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating timetable: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = ref.watch(slotsProvider);

    // Load data when day changes or when data is fetched
    ref.listen(slotsProvider, (previous, next) {
      if (!next.isLoading && next.errorMessage == null) {
        _loadDataForSelectedDay();
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            /// Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 15.sp, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Edit Timetable",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : _submitTimetable,
                  child: isSubmitting
                      ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: mainBlue,
                    ),
                  )
                      : Text(
                    "Submit",
                    style: TextStyle(fontSize: 15.sp, color: mainBlue),
                  ),
                ),
              ],
            ),

            /// Days as ToggleButtons
            ToggleButtons(
              selectedColor: Colors.white,
              constraints: BoxConstraints(
                minWidth: (1.sw - (days.length - 1) * 2) / days.length,
                minHeight: 50.h,
              ),
              fillColor: mainBlue,
              color: Colors.black,
              isSelected: List.generate(days.length,
                      (index) => index == selectedDayIndex),
              onPressed: (index) {
                setState(() {
                  selectedDayIndex = index;
                });
                _loadDataForSelectedDay();
              },
              children: days.map((day) {
                return Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),

            /// Loading indicator
            if (timetableState.isLoading || isLoadingCourses)
              Padding(
                padding: EdgeInsets.all(20.h),
                child: CircularProgressIndicator(color: mainBlue),
              ),

            /// Error message
            if (timetableState.errorMessage != null)
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Error: ${timetableState.errorMessage}',
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),

            /// Timetable entries
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: List.generate(timeSlots.length, (int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded),
                            SizedBox(width: 6.w),
                            Text(
                              timeSlots[index],
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 17.sp,
                              ),
                            ),
                          ],
                        ),
                        _subjectFieldBuild(
                          index == 0,
                          index,
                          classroomControllers[index],
                        ),
                        SizedBox(height: 25.h),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectFieldBuild(
      bool showHint,
      int index,
      TextEditingController classroomController,
      ) {
    // Deduplicate courses by courseId
    final uniqueCoursesMap = {for (var c in availableCourses) c.courseId: c};
    final uniqueCourses = uniqueCoursesMap.values.toList();

    // Ensure selected value exists
    final currentValue = selectedCourseIds[index];
    final safeValue = uniqueCourses.any((c) => c.courseId == currentValue)
        ? currentValue
        : null;

    return Column(
      children: [
        // Subject Dropdown
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.h),
                child: Icon(Icons.book_outlined, size: 20.sp),
              ),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: safeValue,
                    hint: Text(
                      showHint ? "Select Subject..." : "Select Subject...",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 15.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          "None",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 15.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ...uniqueCourses.map((Course course) {
                        return DropdownMenuItem<String>(
                          value: course.courseId,
                          child: Text(
                            course.courseName,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 15.sp,
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: isLoadingCourses ? null : (String? newValue) {
                      setState(() {
                        selectedCourseIds[index] = newValue;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        // Classroom TextField
        TextField(
          controller: classroomController,
          style: TextStyle(fontFamily: "Inter", fontSize: 15.sp),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w),
              child: Icon(Icons.door_front_door_outlined, size: 20.sp),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: showHint ? "Classroom Code... e.g. A105" : null,
            hintStyle: TextStyle(fontFamily: "Inter"),
          ),
        ),
      ],
    );
  }
}