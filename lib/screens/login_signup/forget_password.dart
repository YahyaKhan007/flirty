// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../pages.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});

  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Obx(
          () => Container(
            height: size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/back_design.png"),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.08,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: CupertinoButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.07,
                ),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: size.width * 0.7,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: TextFormField(
                      controller: email,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: "Enter the email",
                          hintStyle: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 13.sp)),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                SizedBox(
                  height: 20.h,
                ),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Get.find<FirebaseAuthController>().isLoading.value
                        ? spinkit(color: appBarColor, size: 30)
                        : Container(
                            height: 50,
                            width: 200.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.r),
                                gradient: buttonGradient),
                            child: Center(
                                child: Text(
                              'Reset Password',
                              style: GoogleFonts.cinzel(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ))),
                    onPressed: () async {
                      try {
                        Get.find<FirebaseAuthController>().isLoading.value =
                            true;

                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(
                              email: email.text,
                            )
                            .then((value) => Get.find<FirebaseAuthController>()
                                .isLoading
                                .value = false)
                            .then((value) => Get.showSnackbar(const GetSnackBar(
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.TOP,
                                  duration: Duration(seconds: 3),
                                  title: "Password reset Link send",
                                  message:
                                      "Password reset Link has been send to your email",
                                )))
                            .then((value) => Get.off(() => LoginPage()));
                        // Password reset email sent successfully
                        log('Password reset email sent to ${email.text}');

                        Get.find<FirebaseAuthController>().isLoading.value =
                            false;
                      } catch (e) {
                        Get.find<FirebaseAuthController>().isLoading.value =
                            false;
                        // An error occurred
                        log('Error sending password reset email: $e');
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
