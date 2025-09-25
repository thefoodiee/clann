import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../viewmodel/auth/signup_vm.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {

  final bool isCrSelected = true;

  bool showPass = true;

  bool showConfirmpass = true;

  // key: "ProgramName-Section", value: program_id
  final Map<String, String> programIdMap = {
    "B.Tech CSE Core-A": "BCSECOREA2327",
    "B.Tech CSE Core-B": "BCSECOREB2327",
    "B.Tech CSE Core-C": "BCSECOREC2327",
    "B.Tech CSE Core-D": "BCSECORED2327",
    "B.Tech CSE Core-E": "BCSECOREE2327",
    "B.Tech CSE Core-F": "BCSECOREF2327",
    "B.Tech CSE AI-ML-A": "BCSEAIMLA2327",
    "B.Tech CSE AI-ML-B": "BCSEAIMLB2327",
    "B.Tech CSE AI-ML-C": "BCSEAIMLC2327",
    "B.Tech CSE AI-ML-D": "BCSEAIMLD2327",
    "B.Tech CSE AI-ML-E": "BCSEAIMLE2327",
    // add all combinations
  };

  String? getProgramId(String program, String section) {
    return programIdMap["$program-$section"];
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollnoController = TextEditingController();

  // @override
  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(authProvider);
    final signUpState = ref.watch(signUpProvider);
    final signUpVM = ref.read(signUpProvider.notifier);

    // Fetch programs when the widget first builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (signUpState.programNames.isEmpty && !signUpState.isLoading) {
        signUpVM.fetchPrograms();
      }
    });
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 10.h),
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Opacity(
                        opacity: 0.5,
                        child: SvgPicture.asset(
                          "assets/images/sign_up.svg",
                          height: 100.h,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        customTextField("Name", nameController),
                        customTextField("Roll Number", rollnoController),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Class"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tfGrey,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: signUpState.selectedProgram ??
                                          (signUpState.programNames.isNotEmpty
                                              ? signUpState.programNames.first
                                              : null),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      decoration: const InputDecoration.collapsed(
                                        hintText: "",
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      dropdownColor: tfGrey,
                                      borderRadius: BorderRadius.circular(10.r),
                                      style: const TextStyle(color: Colors.black),
                                      items: signUpState.programNames
                                          .map((prog) => DropdownMenuItem(
                                        value: prog,
                                        child: Text(prog),
                                      ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) signUpVM.selectProgram(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
          
                            SizedBox(width: 15.w), // spacing between dropdowns
                            // Section Dropdown
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Section"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tfGrey,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: signUpState.selectedSection ??
                                          (signUpState.selectedProgram != null
                                              ? signUpState
                                              .programSections[
                                          signUpState.selectedProgram!]!
                                              .first
                                              : null),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      decoration: const InputDecoration.collapsed(
                                        hintText: "",
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      dropdownColor: tfGrey,
                                      borderRadius: BorderRadius.circular(10.r),
                                      style: const TextStyle(color: Colors.black),
                                      items: signUpState.selectedProgram != null
                                          ? signUpState.programSections[
                                      signUpState.selectedProgram!]!
                                          .map((sec) => DropdownMenuItem(
                                        value: sec,
                                        child: Text(sec),
                                      ))
                                          .toList()
                                          : [],
                                      onChanged: (value) {
                                        if (value != null) signUpVM.selectSection(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        customTextField("Email", emailController),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Password"),
                            TextField(
                              controller: passwordController,
                              obscureText: showPass,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsetsGeometry.all(10.h),
                                fillColor: tfGrey,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  icon: showPass
                                      ? Icon(Icons.visibility_off_rounded)
                                      : Icon(Icons.visibility_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Confirm Password"),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: showConfirmpass,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsetsGeometry.all(10.h),
                                fillColor: tfGrey,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showConfirmpass = !showConfirmpass;
                                    });
                                  },
                                  icon: showConfirmpass
                                      ? Icon(Icons.visibility_off_rounded)
                                      : Icon(Icons.visibility_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80.h),
                        TextButton(
                          onPressed: () async{
                            final program = signUpState.selectedProgram; // use ViewModel state
                            final sec = signUpState.selectedSection;  // your section dropdown
          
                            if (program == null || sec == null) return;
          
                            final programId = getProgramId(program, sec);
                            if (programId == null) return; // handle invalid selection
                            if(passwordController.text != confirmPasswordController.text){
                              Fluttertoast.showToast(msg: "Passwords don't match!");
                              return;
                            }
          
                            await ref.read(authProvider.notifier).signUp(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text,
                              rollno: int.parse(rollnoController.text),
                              program_id: programId,
                              context: context,
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(mainBlue),
                            padding: WidgetStateProperty.all(
                              EdgeInsetsGeometry.symmetric(horizontal: 40.w),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?"),
                            TextButton(
                              onPressed: () => context.pushReplacement("/login"),
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  EdgeInsetsGeometry.zero,
                                ),
                              ),
                              child: Text(
                                "Log In",
                                style: TextStyle(color: mainBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget customTextField(
  String label,
  TextEditingController controller, {
  String? hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsetsGeometry.all(10.h),
          fillColor: tfGrey,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      SizedBox(height: 20.h),
    ],
  );
}