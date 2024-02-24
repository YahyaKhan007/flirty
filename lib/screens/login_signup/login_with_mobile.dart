// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/controllers.dart';
import '../widgets/widgets.dart';

class LoginWithPhone extends StatelessWidget {
  LoginWithPhone({super.key});

  TextEditingController phoneNuberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<FirebaseAuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login with mobile"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
          child: showPhoneOption(
              title: '+92 312 1290982',
              controller: phoneNuberController,
              context: context),
        ),
        SizedBox(
          height: 40.h,
        ),
        CupertinoButton.filled(
            child: const Text('Login'),
            onPressed: () {
              controller.loginWithMobilePhone(
                  mobileNumber: phoneNuberController.text);
            }),
      ]),
    );
  }
}

// ! varify number

class VarifyNumber extends StatelessWidget {
  final String varificationId;
  VarifyNumber({super.key, required this.varificationId});

  TextEditingController varifyPhoneNuberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<FirebaseAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Varify mobile number"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
          child: showPhoneOption(
              title: '6 digit code',
              controller: varifyPhoneNuberController,
              context: context),
        ),
        SizedBox(
          height: 40.h,
        ),
        CupertinoButton.filled(
            child: const Text('Varify OTP'),
            onPressed: () {
              controller.loginWithMobilePhone(
                  mobileNumber: varifyPhoneNuberController.text);
            }),
      ]),
    );
  }
}
