// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';

Widget GlassMorphism(
    {required double width,
    required double height,
    required double blur,
    required double borderRadius,
    required dynamic child}) {
  return Padding(
    padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
    child: GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      blur: blur,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 93, 87, 87).withOpacity(0.1),
            const Color.fromARGB(255, 87, 79, 79).withOpacity(0.2),
          ],
          stops: const [
            0.1,
            1,
          ]),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.5),
          const Color((0xFFFFFFFF)).withOpacity(0.5),
        ],
      ),
      child: child,
    ),
  );
}
