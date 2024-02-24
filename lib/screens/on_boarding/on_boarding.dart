import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../models/models.dart';
import '../../pages.dart';
import '../widgets/app_constants.dart';

class OnBoardingScreen extends StatefulWidget {
  final User? firebaseUser;
  final UserModel? userModel;
  const OnBoardingScreen({
    super.key,
    required this.firebaseUser,
    required this.userModel,
  });

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final Color kDarkBlueColor = const Color(0xFF053149);

  @override
  void initState() {
    super.initState();
    checkOnboardingStatus();
    Future.delayed(const Duration(seconds: 3), () => showDialogAboutUpdate());
  }

  showDialogAboutUpdate() {
    Get.dialog(AlertDialog(
      title: Text(
        'Attention Users',
        style: TextStyle(
            fontSize: 23.sp,
            fontStyle: FontStyle.italic,
            color: appBarColor,
            fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "For Security Purposes we have Secured Our Database from Un-authentic Users, Which is why we have Cleared all the pervious Account, So you are required to create a new One !",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
                child: Text(
              "Happy Journey with Flirty",
              style: TextStyle(
                  fontSize: 20.sp,
                  fontStyle: FontStyle.italic,
                  color: appBarColor,
                  fontWeight: FontWeight.normal),
            )),
          ],
        ),
      ),
    ));
  }

  void showConfirmAcceptPoliciesAlertDialog() {
    Get.defaultDialog(
      title: AppConsants.mainhead,
      titleStyle: GoogleFonts.blackOpsOne(
        fontSize: 18.sp,
        textStyle: Theme.of(context).textTheme.bodyMedium,
        decorationColor: Colors.black,
        color: Colors.black.withOpacity(0.6),
      ),
      content: SizedBox(
        height: 250.0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1 - ${AppConsants.string1head}',
                  style: GoogleFonts.blackOpsOne(
                    color: appBarColor,
                  )),
              Text(AppConsants.heading1text,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: Colors.black,
                      fontSize: 15.sp)),
              SizedBox(
                height: 10.h,
              ),
              Text('2 - ${AppConsants.string2head}',
                  style: GoogleFonts.blackOpsOne(
                    color: appBarColor,
                  )),
              Text(AppConsants.heading2text,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: Colors.black,
                      fontSize: 15.sp)),
              SizedBox(
                height: 10.h,
              ),
              Text(AppConsants.heading3text,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: Colors.black,
                      fontSize: 15.sp)),
              SizedBox(
                height: 10.h,
              ),
              Text(AppConsants.heading4text,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: Colors.black,
                      fontSize: 15.sp))
            ],
          ),
        ),
      ),
      textConfirm: 'OK',
      confirm: InkWell(
        onTap: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool('onboarding_shown', true);
          });

          Get.off(() => SplashScreen(
                firebaseUser: widget.firebaseUser,
                userModel: widget.userModel,
              ));
        },
        child: Container(
            height: 45.h,
            width: 130.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: buttonGradient),
            child: Center(
                child: Text(
              'I Accept!',
              style: GoogleFonts.cormorantGaramond(
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  decorationColor: Colors.black,
                  // backgroundColor: Colors.blue.shade100,
                  color: Colors.white,
                  fontSize: 20.sp),
            ))),
      ),
    );
  }

  void checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardingShown = prefs.getBool('onboarding_shown') ?? false;

    if (!onboardingShown) {
      // prefs.setBool('onboarding_shown', true);
    } else {
      // Onboarding already shown, navigate to another screen or perform any other action
      // For example, you can navigate to the home screen using Navigator.pushReplacement()
      Get.off(() => SplashScreen(
            firebaseUser: widget.firebaseUser,
            userModel: widget.userModel,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return OnBoardingSlider(
      finishButtonText: 'Finsih',
      finishButtonTextStyle: GoogleFonts.cormorantGaramond(
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          decorationColor: Colors.black,
          // backgroundColor: Colors.blue.shade100,
          color: Colors.white,
          fontSize: 20.sp),
      onFinish: () {
        showConfirmAcceptPoliciesAlertDialog();
      },
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: appBarColor,
      ),
      skipFunctionOverride: () {
        showConfirmAcceptPoliciesAlertDialog();
      },
      skipTextButton: Text(
        'Skip',
        style: GoogleFonts.cormorantGaramond(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            decorationColor: Colors.black,
            // backgroundColor: Colors.blue.shade100,
            color: appBarColor,
            fontSize: 20.sp),
      ),
      controllerColor: appBarColor,
      totalPage: 3,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      centerBackground: true,
      background: [
        Image.asset(
          'assets/2.png',
          alignment: Alignment.center,
          height: height * 0.5,
          width: size.width,
        ),
        Image.asset(
          'assets/2.png',
          alignment: Alignment.center,
          height: height * 0.5,
          width: size.width,
        ),
        Center(
          child: Image.asset(
            'assets/2.png',
            alignment: Alignment.center,
            height: height * 0.5,
            width: size.width,
          ),
        ),
      ],
      speed: 1.8,
      pageBodies: [
        Container(
          alignment: Alignment.center,
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height * 0.55,
              ),
              Text(
                'Welcome to Flirty',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    decorationColor: Colors.black,
                    // backgroundColor: Colors.blue.shade100,
                    color: appBarColor,
                    fontSize: 22.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                  'Welcome to Flirty! Your hub for meaningful connections. Swipe right to begin!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: appBarColor,
                      fontSize: 15.sp)),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height * 0.55,
              ),
              Text(
                'Discover Romance',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    decorationColor: Colors.black,
                    // backgroundColor: Colors.blue.shade100,
                    color: appBarColor,
                    fontSize: 22.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                  "Explore romance with Flirty's matchmaking. Find common interests and start chatting!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: appBarColor,
                      fontSize: 15.sp)),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height * 0.55,
              ),
              Text(
                'Connect with Flirty',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    decorationColor: Colors.black,
                    // backgroundColor: Colors.blue.shade100,
                    color: appBarColor,
                    fontSize: 22.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                  'Connect locally, discover love. User-friendly design and privacy-focused. Join Flirty now!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.blue.shade100,
                      color: appBarColor,
                      fontSize: 15.sp)),
            ],
          ),
        ),
      ],
    );
  }
}
