import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../pages.dart';

import 'package:in_app_review/in_app_review.dart';

class SplashScreen extends StatefulWidget {
  final User? firebaseUser;
  final UserModel? userModel;
  const SplashScreen({
    super.key,
    required this.firebaseUser,
    required this.userModel,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final InAppReview inAppReview = InAppReview.instance;

  late UserProvider userModelProvider;

  // void _requestReview() async {
  //   if (await inAppReview.isAvailable()) {
  //     inAppReview.requestReview();
  //   }
  // }

  @override
  void initState() {
    userModelProvider = Provider.of<UserProvider>(context, listen: false);
    super.initState();

    // _requestReview();

    Future.delayed(const Duration(seconds: 3), () async {
      if (widget.userModel != null) {
        if (widget.userModel?.fullName == '') {
          log('Profle not complete');
          Get.offAll(() => CompleteProfile(
                isEdit: false,
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser,
              ));
        } else {
          var user = await FirebaseHelper.getClientModelById(
              FirebaseAuth.instance.currentUser!.uid);
          userModelProvider.updateUser(user);
          userModelProvider.updateFirebaseUser(widget.firebaseUser!);

          Get.offAll(() => HomePage(
                userModel: widget.userModel!,
              ));
        }
      } else {
        Get.off(() => LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/back_design.png',
                ),
                fit: BoxFit.fitHeight)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
                child: Image.asset(
              "assets/heart.gif",
              width: size.width * 0.35,
              color: appBarColor,
              // color: appBarColor,
            )),
            Center(
                child: Image.asset(
              "assets/logo.png",
              width: size.width * 0.45,
              // color: appBarColor,
            )),
            // AnimatedOpacity(
            //     duration: const Duration(seconds: 2),
            //     curve: Curves.easeInOut,
            //     opacity: Get.find<FirebaseAuthController>().opacity.value,
            //     child: Column(children: [

            //     ])),
            SizedBox(
              height: size.height * 0.4,
            ),
          ],
        ),
      ),
    );
  }
}
