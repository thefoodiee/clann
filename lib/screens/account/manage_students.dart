import 'package:clann/viewmodel/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/colors.dart';

class ManageStudentsScreen extends ConsumerWidget {
  const ManageStudentsScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchStudents(String programId) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('users')
        .select('name')
        .eq('program_id', programId)
        .order('user_id', ascending: true);

    // cast to List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.read(userViewModelProvider);
    final programID = userState.user!.program_id;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: mainBlue),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Manage Students",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40)
              ],
            ),
            SizedBox(height: 10.h,),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchStudents(programID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return const Center(child: Text("No students found"));
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _studentTile(student['name']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _studentTile(String name){
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 0, 0, 20.h),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 1))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp
            ),
          ),
          // IconButton(onPressed: (){}, icon: Icon(Icons.delete_outline_outlined))
        ],
      ),
    ),
  );
}