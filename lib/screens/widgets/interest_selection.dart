import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/controllers.dart';

Widget interestSelection(
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
                    value: firebaseAuthController.interestTypes[0],
                    groupValue: firebaseAuthController.selectInterest.value,
                    onChanged: ((onChanged) {
                      firebaseAuthController.changeInterest(gender: onChanged!);
                      log(firebasController.selectInterest.value);
                    })),
                Text(
                  "Males".tr,
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
                    value: firebaseAuthController.interestTypes[1],
                    groupValue: firebaseAuthController.selectInterest.value,
                    onChanged: ((onChanged) {
                      firebaseAuthController.changeInterest(gender: onChanged!);
                      log(firebasController.selectInterest.value);
                    })),
                Text(
                  "Females".tr,
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
                    value: firebaseAuthController.interestTypes[2],
                    groupValue: firebaseAuthController.selectInterest.value,
                    onChanged: ((onChanged) {
                      firebaseAuthController.changeInterest(gender: onChanged!);
                      log(firebasController.selectInterest.value);
                    })),
                Text(
                  "Both".tr,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
