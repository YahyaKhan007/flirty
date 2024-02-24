import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../models/models.dart';

snakbar({required UserModel userModel}) {
  return Get.showSnackbar(
    GetSnackBar(
      icon: Icon(
        Icons.favorite,
        color: Colors.red,
        size: 50.sp,
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text(
          "You Liked ${userModel.fullName}",
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      barBlur: 3,
      borderRadius: 2000,
      titleText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text("Liked",
            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
      ),
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.TOP,
    ),
  );
}

redSnakbar({required UserModel userModel}) {
  return Get.showSnackbar(
    GetSnackBar(
      icon: Icon(
        Icons.error,
        color: Colors.white,
        size: 50.sp,
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text(
          "You Aready Liked ${userModel.fullName}",
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      barBlur: 3,
      borderRadius: 2000,
      titleText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text("Already Liked",
            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
      ),
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.TOP,
    ),
  );
}

matchSnakbar({required UserModel userModel}) {
  return Get.showSnackbar(
    GetSnackBar(
      icon: Icon(
        Icons.error,
        color: Colors.white,
        size: 50.sp,
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text(
          "You Both are already matched",
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.blue.shade400,
      barBlur: 3,
      borderRadius: 2000,
      titleText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text("Already Matched",
            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
      ),
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.TOP,
    ),
  );
}

recievedSnakbar({required UserModel userModel}) {
  return Get.showSnackbar(
    GetSnackBar(
      icon: Icon(
        Icons.error,
        color: Colors.white,
        size: 50.sp,
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text(
          "Go to ${userModel.fullName} and accept the request",
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.blue.shade400,
      barBlur: 3,
      borderRadius: 2000,
      titleText: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Text("Got the Request Already",
            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
      ),
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.TOP,
    ),
  );
}
