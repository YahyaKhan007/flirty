import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../pages.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.email, required this.myAuth});
  final String email;
  final EmailOTP myAuth;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController one = TextEditingController();

  final TextEditingController two = TextEditingController();

  final TextEditingController three = TextEditingController();

  final TextEditingController four = TextEditingController();

  final oneFocus = FocusNode();

  final twoFocus = FocusNode();

  final threeFocus = FocusNode();

  final fourFocus = FocusNode();
  final email = FocusNode();

  @override
  void dispose() {
    oneFocus.dispose();
    twoFocus.dispose();
    threeFocus.dispose();
    fourFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var firebaseController = Get.find<FirebaseAuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/logo.png",
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            SizedBox(
              height: 35.h,
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.none,
                child: Text("ENTER VARIFICATION OTP",
                    style: GoogleFonts.cinzel(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      fontSize: 25.sp,
                      color: appBarColor,
                      letterSpacing: -1,
                      wordSpacing: 5,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 45.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      // maxLength: 1,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      focusNode: oneFocus,
                      controller: one,
                      onChanged: (v) {
                        setState(() {
                          twoFocus.requestFocus();
                        });
                      },
                      decoration:
                          const InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: twoFocus,
                      textAlign: TextAlign.center,
                      controller: two,
                      onChanged: (v) {
                        threeFocus.requestFocus();
                      },
                      decoration:
                          const InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,

                      // maxLength: 1,
                      textAlign: TextAlign.center,
                      controller: three,
                      focusNode: threeFocus,
                      onChanged: (v) {
                        fourFocus.requestFocus();
                      },
                      decoration:
                          const InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,

                      // maxLength: 1,
                      textAlign: TextAlign.center,
                      controller: four,
                      focusNode: fourFocus,
                      onChanged: (v) {
                        fourFocus.unfocus();
                      },
                      decoration:
                          const InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                  child: Text(
                    "Can't find the PIN?",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onPressed: () {
                    try {
                      // myauth.sendOTP();
                    } catch (e) {
                      log(e.toString());
                    }
                  }),
            ),
            SizedBox(
              height: 10.h,
            ),
            firebaseController.isLoading.value
                ? spinkit(color: appBarColor, size: 30.0)
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        firebaseController.isLoading.value = true;
                        if (await widget.myAuth.verifyOTP(
                                otp: one.text +
                                    two.text +
                                    three.text +
                                    four.text) ==
                            true) {
                          Get.showSnackbar(const GetSnackBar(
                            backgroundColor: Colors.green,
                            snackPosition: SnackPosition.TOP,
                            duration: Duration(seconds: 2),
                            title: "OTP Varified",
                            message: "The OTP has been Varified",
                          ));
                          firebaseController.isLoading.value = false;

                          Get.off(() =>
                              SignPage(email: widget.email, goAhead: true));
                        } else {
                          Get.showSnackbar(const GetSnackBar(
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.TOP,
                            duration: Duration(seconds: 2),
                            title: "OTP InValid",
                            message: "The OTP is not Valid",
                          ));
                          firebaseController.isLoading.value = false;
                        }
                      },
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: buttonGradient),
                        child: Center(
                            child: Text(
                          "Confirm",
                          style: GoogleFonts.playfairDisplay(
                            letterSpacing: 1,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            decorationColor: Colors.black,
                            color: Colors.white,
                          ),
                        )),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
