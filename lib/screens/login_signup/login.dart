// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../pages.dart';
import '../../utils/ad_helper.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();

  FocusNode focus1 = FocusNode();

  FocusNode focus2 = FocusNode();

  TextEditingController emailController = TextEditingController();

  TextEditingController passController = TextEditingController();

  @override
  void initState() {
    initilizeBannerAd();
    super.initState();
  }

  // ! Google Ads Banner
  late BannerAd chatScreenBanner;

  void initilizeBannerAd() async {
    chatScreenBanner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAds1(),
      listener: BannerAdListener(
          onAdLoaded: (ad) {},
          onAdClosed: (ad) {
            ad.dispose();
          },
          onAdFailedToLoad: (ad, err) {
            print(err.toString());
          }),
      request: const AdRequest(),
    );
    await chatScreenBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    var controller = Get.find<FirebaseAuthController>();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: chatScreenBanner.size.height.toDouble(),
        width: chatScreenBanner.size.width.toDouble(),
        child: AdWidget(ad: chatScreenBanner),
      ),
      // appBar: AppBar(
      //   backgroundColor: appBarColor,
      // ),
      body: Obx(
        () => InkWell(
          onTap: () {
            focus1.unfocus();
            focus2.unfocus();
          },
          child: Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/back_design.png'),
                    fit: BoxFit.fitHeight)),
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * 0.15,
                    ),
                    Image.asset(
                      "assets/logo.png",
                      height: size.height * 0.1,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      "Welcome Back !",
                      style: GoogleFonts.cormorantGaramond(
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          decorationColor: Colors.black,
                          // backgroundColor: Colors.blue.shade100,
                          color: appBarColor,
                          fontSize: 22.sp),
                    ),
                    Text(
                      "Login to your account",
                      style: GoogleFonts.cormorantGaramond(
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          decorationColor: Colors.black,
                          // backgroundColor: Colors.blue.shade100,
                          color: appBarColor,
                          fontSize: 12.sp),
                    ),

                    SizedBox(
                      height: size.height * 0.08,
                    ),

                    showOption(
                        isConfirm: false,
                        context: context,
                        controller: emailController,
                        focus: focus1,
                        title: "Email"),

                    // ^ password Option
                    showOption(
                        isConfirm: false,
                        context: context,
                        controller: passController,
                        focus: focus2,
                        title: "Password"),
                    Padding(
                      padding: EdgeInsets.only(right: 25.w),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                            child: Text(
                              "Forget Password ?",
                              style: GoogleFonts.cormorantGaramond(
                                  fontWeight: FontWeight.w700,
                                  decorationColor: Colors.black,
                                  // backgroundColor: Colors.blue.shade100,
                                  color: appBarColor,
                                  fontSize: 15.sp),
                            ),
                            onPressed: () {
                              try {
                                Get.to(() => ForgetPassword(),
                                    transition: Transition.rightToLeftWithFade,
                                    duration:
                                        const Duration(milliseconds: 700));
                                // myauth.sendOTP();
                              } catch (e) {
                                log(e.toString());
                              }
                            }),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),

                    controller.isLoading.value
                        ? spinkit(color: Colors.pink, size: 30.r)
                        : Padding(
                            padding: EdgeInsets.only(
                                right: size.width * 0.15,
                                left: size.width * 0.25),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                focus1.unfocus();
                                focus2.unfocus();
                                if (emailController.text != '' &&
                                    passController.text != '') {
                                  controller.loginUser(
                                      email: emailController.text,
                                      password: passController.text,
                                      userProvider: userProvider);
                                } else {
                                  Get.snackbar("Missing Fields".tr,
                                      "Entered all the data".tr);
                                }
                              },
                              child: Container(
                                height: 55.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: buttonGradient),
                                child: Center(
                                    child: Text(
                                  "Login",
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
                          ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80.w),
                      child: SizedBox(
                        width: size.width,
                        child: const Row(
                          children: [
                            Expanded(
                              child: Divider(

                                color: Colors.grey,
                              ),
                            ),
                            Text("  OR  "),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        controller.signInWithGoogle(userProvider: userProvider);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(25.r)),
                        height: 40.h,
                        margin: EdgeInsets.only(
                            right: 40.w, top: 15.h, left: 70.w, bottom: 30.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_icon.jpg',
                              height: 25.h,
                            ),
                            Text(
                              "   Sign In with Google",
                              style: TextStyle(fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                    ),

                    // SizedBox(
                    //   height: size.height * 0.05,
                    // ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Dont have any account".tr,
                              style: TextStyle(fontSize: 11.sp),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.off(
                                    () => const SignPage(
                                          email: '',
                                          goAhead: false,
                                          // goAhead: true,
                                        ),
                                    transition: Transition.zoom,
                                    duration:
                                        const Duration(milliseconds: 800));
                              },
                              child: Text(
                                "Signup here",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontStyle: FontStyle.italic,
                                    color: appBarColor),
                              ),
                            )
                          ]),
                    ),
                    SizedBox(height: 20.h,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
