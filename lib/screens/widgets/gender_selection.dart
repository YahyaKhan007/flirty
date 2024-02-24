import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/controllers.dart';

Widget genderSelection(
    {required Size size,
    required BuildContext context,
    required FirebaseAuthController firebaseAuthController}) {
  return GetBuilder(
    init: Get.find<FirebaseAuthController>(),
    builder: (firebasController) => Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Radio.adaptive(
                    // activeColor: Colors.white,
                    value: firebaseAuthController.genderTypes[0],
                    groupValue: firebaseAuthController.selectGender.value,
                    onChanged: ((onChanged) {
                      firebaseAuthController.changeGender(gender: onChanged!);
                      log(firebasController.selectGender.value);
                    })),
                Text(
                  "Male".tr,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            Row(
              children: [
                Radio.adaptive(
                    // activeColor: Colors.white,
                    value: firebaseAuthController.genderTypes[1],
                    groupValue: firebaseAuthController.selectGender.value,
                    onChanged: ((onChanged) {
                      firebaseAuthController.changeGender(gender: onChanged!);
                      log(firebasController.selectGender.value);
                    })),
                Text(
                  "Female".tr,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}
