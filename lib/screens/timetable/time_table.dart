import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/timetable_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../viewmodel/user_vm.dart';

class TimeTableScreen extends ConsumerStatefulWidget {
  const TimeTableScreen({super.key});

  @override
  ConsumerState<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends ConsumerState<TimeTableScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(slotsProvider.notifier).fetchSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final slotState = ref.watch(slotsProvider);
    final userState = ref.watch(userViewModelProvider);

    // Filter slots based on selected day
    final dayName = DateFormat('EEEE').format(_selectedDate);
    final filteredSlots = slotState.slots
        .where((slot) => slot.day.toLowerCase() == dayName.toLowerCase())
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Time Table",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                  ),
                  if (slotState.isOffline) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.cloud_off,
                      color: Colors.orange,
                      size: 20.sp,
                    ),
                  ],
                ],
              ),

              // Offline/Cache status banner
              if (slotState.isOffline || slotState.lastCacheUpdate != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: slotState.isOffline ? Colors.orange.shade100 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: slotState.isOffline ? Colors.orange : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        slotState.isOffline ? Icons.cloud_off : Icons.update,
                        size: 16.sp,
                        color: slotState.isOffline ? Colors.orange.shade700 : Colors.blue.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          slotState.isOffline
                              ? 'Offline Mode'
                              : slotState.lastCacheUpdate != null
                              ? 'Last updated: ${_formatLastUpdate(slotState.lastCacheUpdate!)}'
                              : 'Using cached data',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: slotState.isOffline ? Colors.orange.shade700 : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      if (slotState.isOffline)
                        GestureDetector(
                          onTap: () => ref.read(slotsProvider.notifier).refreshTimetable(),
                          child: Icon(
                            Icons.refresh,
                            size: 16.sp,
                            color: Colors.orange.shade700,
                          ),
                        ),
                    ],
                  ),
                ),

              SizedBox(height: 20.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(slotsProvider.notifier).refreshTimetable(),
                  child: ListView(
                    children: [
                      SfCalendar(
                        view: CalendarView.month,
                        backgroundColor: Colors.white,
                        cellBorderColor: Colors.transparent,
                        headerStyle: CalendarHeaderStyle(
                          backgroundColor: Colors.white,
                        ),
                        selectionDecoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: mainBlue, width: 2),
                          shape: BoxShape.circle,
                        ),
                        todayHighlightColor: mainBlue,
                        onTap: (calendarTapDetails) {
                          if (calendarTapDetails.date != null) {
                            setState(() {
                              _selectedDate = calendarTapDetails.date!;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      if (slotState.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (slotState.errorMessage != null && slotState.slots.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                slotState.isOffline ? Icons.cloud_off : Icons.error_outline,
                                size: 48.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                slotState.errorMessage!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton.icon(
                                onPressed: () => ref.read(slotsProvider.notifier).refreshTimetable(),
                                icon: Icon(Icons.refresh),
                                label: Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (filteredSlots.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "No classes scheduled for $dayName",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredSlots.length,
                            itemBuilder: (context, index) {
                              final slot = filteredSlots[index];
                              final formattedRange =
                                  "${DateFormat('h:mma').format(slot.startTime)} - "
                                  "${DateFormat('h:mma').format(slot.endTime)}";

                              return _timeTableCard(
                                subject: slot.courseName,
                                classCode: slot.classCode,
                                time: formattedRange,
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if(userState.user?.is_cr ?? false)
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20.h),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                shape: CircleBorder(),
                heroTag: "editBtn",
                onPressed: () => context.push("/edit_timetable"),
                backgroundColor: mainBlue,
                child: Icon(
                  Icons.edit_calendar_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(lastUpdate);
    }
  }
}

Widget _timeTableCard({
  required String time,
  required String subject,
  required String classCode,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: lightBlue,
        boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0, 1), blurRadius: 5),
        ],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded( // Allows content to wrap inside available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 4.h),
                Text(
                  subject,
                  style: TextStyle(fontSize: 18.sp, fontFamily: "Inter"),
                  softWrap: true,
                ),
                SizedBox(height: 2.h),
                Text(
                  classCode,
                  style: TextStyle(fontSize: 18.sp, fontFamily: "Inter"),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}