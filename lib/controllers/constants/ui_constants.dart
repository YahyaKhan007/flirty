import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final kTextFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.r), bottomRight: Radius.circular(30.r)),
    borderSide: const BorderSide(
      color: Colors.black,
    ));

final kButtonTextStyle = TextStyle(
    fontSize: 15.sp,
    // fontFamily: '',
    fontWeight: FontWeight.bold,
    color: Colors.black);

final kTextFieldInputStyle = TextStyle(
  fontSize: 13.sp, color: Colors.black,
  // fontFamily: ''
);

BoxShadow avatarShadow = const BoxShadow(
  color: Colors.pink,
  blurRadius: 3,
  offset: Offset(-1, 4),
  spreadRadius: 0.00,
);

BoxShadow shadow = BoxShadow(
  color: Colors.blue.shade300,
  blurRadius: 5,
  offset: const Offset(1, 4),
  spreadRadius: 0.00,
);

BoxShadow greyShadow = BoxShadow(
  color: Colors.grey.shade300,
  blurRadius: 5,
  offset: const Offset(1, 4),
  spreadRadius: 0.00,
);

Color appBarColor = const Color(0xffEC755A);

double myLatitude = 33.9624067;
double myLongitude = 71.7294917;

LinearGradient buttonGradient = LinearGradient(
  colors: [appBarColor, const Color(0xFFFF6A7F)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
