import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';

Widget showOption(
    {required String title,
    required TextEditingController controller,
    required FocusNode focus,
    required bool isConfirm,
    required BuildContext context}) {
  var authController = Get.find<FirebaseAuthController>();
  return Stack(
    children: [
      Padding(
        padding: EdgeInsets.only(left: 60.w, right: 40.w),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            enabled: !isConfirm,
            focusNode: focus,
            obscureText: title == 'Email'.tr
                ? false
                : Get.find<FirebaseAuthController>().showPassword.value,
            controller: controller,
            cursorColor: Colors.black,
            cursorHeight: 17.sp,
            // obscureText: authController.showPassword.value,
            validator: title == 'Email'
                ? (value) {
                    if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value!)) {
                      return "Enter Correct Name";
                    } else {
                      return null;
                    }
                  }
                : null,
            // controller: ,
            style: kTextFieldInputStyle,

            decoration: InputDecoration(
              suffixIcon: title != 'Email'
                  ? InkWell(
                      splashColor: Colors.red,
                      onTap: () {
                        authController.changeShowPassword(
                            value: !authController.showPassword.value);
                        log("presses");
                        log(authController.showPassword.value.toString());
                      },
                      child: const Icon(Icons.remove_red_eye),
                    )
                  : null,
              hintText: title,
              hintStyle:
                  TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic),
              // label: Text(
              //   'Email',
              //   style: TextStyle(
              //       color: Colors.black, fontSize: 13.sp),
              // ),
              border: const UnderlineInputBorder(),
              // enabledBorder: kTextFieldBorder,
              // focusedBorder: kTextFieldBorder
            ),
          ),
        ),
      ),
      Positioned(
          right: 10,
          top: 10,
          child: Visibility(
            visible: isConfirm,
            child: CircleAvatar(
              radius: 10.r,
              backgroundColor: Colors.green,
              child: Center(
                  child: Icon(
                Icons.check,
                color: Colors.white,
                size: 15.sp,
              )),
            ),
          ))
    ],
  );
}

Widget showPhoneOption(
    {required String title,
    required TextEditingController controller,
    required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.only(left: 100),
    child: TextFormField(
      // obscureText: title == 'Email'.tr
      //     ? false
      //     : Get.find<FirebaseAuthController>().showPassword.value,
      controller: controller,
      cursorColor: Colors.black,
      cursorHeight: 17.sp,
      // validator: title == 'Email'
      //     ? (value) {
      //         if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value!)) {
      //           return "Enter Correct Name";
      //         } else {
      //           return null;
      //         }
      //       }
      //     : null,
      // controller: ,
      style: kTextFieldInputStyle,
      keyboardType: TextInputType.number,

      decoration: InputDecoration(
        // suffixIcon: title != 'Email'
        //     ? GestureDetector(
        //         onTap: () {
        //           var controller =
        //               Get.find<FirebaseAuthController>();

        //           controller.changeShowPassword(
        //               condition: !controller.showPassword.value);
        //           log("presses");
        //         },
        //         child: const Icon(Icons.remove_red_eye),
        //       )
        //     : null,
        hintText: title,
        hintStyle: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic),
        // label: Text(
        //   'Email',
        //   style: TextStyle(
        //       color: Colors.black, fontSize: 13.sp),
        // ),
        border: InputBorder.none,
        // enabledBorder: kTextFieldBorder,
        // focusedBorder: kTextFieldBorder
      ),
    ),
  );
}
