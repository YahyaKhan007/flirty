// ignore_for_file: must_be_immutable

import 'package:email_otp/email_otp.dart';
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

class SignPage extends StatefulWidget {
  final bool goAhead;
  final String email;
  const SignPage({super.key, required this.goAhead, required this.email});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  @override
  void initState() {
    initilizeBannerAd();
    signupEmailController = TextEditingController();
    if (widget.goAhead) {
      signupEmailController.text = widget.email;
    }
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

  EmailOTP myauth = EmailOTP();

  final _formkey = GlobalKey<FormState>();

  FocusNode focus1 = FocusNode();

  FocusNode focus2 = FocusNode();

  FocusNode focus3 = FocusNode();

  late TextEditingController signupEmailController;

  TextEditingController signupPasswordController = TextEditingController();

  TextEditingController signupConfirmPasswordController =
      TextEditingController();

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
      body: InkWell(
        onTap: () {
          focus1.unfocus();
          focus2.unfocus();
          focus3.unfocus();
        },
        child: Obx(
          () => Container(
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        fontSize: 22.sp,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        decorationColor: Colors.black,
                        // backgroundColor: Colors.grey.shade100,
                        color: appBarColor,
                      ),
                    ),
                    Text(
                      "Create an acoount",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12.sp,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        decorationColor: Colors.black,
                        // backgroundColor: Colors.grey.shade100,
                        color: appBarColor,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    Row(
                      children: [
                        showOption(
                            context: context,
                            isConfirm: widget.goAhead,
                            controller: signupEmailController,
                            focus: focus1,
                            title: "Email"),
                      ],
                    ),
                    Visibility(
                      visible: widget.goAhead,
                      child: showOption(
                          isConfirm: false,
                          context: context,
                          controller: signupPasswordController,
                          focus: focus2,
                          title: "Password"),
                    ),
                    Visibility(
                      visible: widget.goAhead,
                      child: showOption(
                          isConfirm: false,
                          context: context,
                          focus: focus3,
                          controller: signupConfirmPasswordController,
                          title: "Confirm Password"),
                    ),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    controller.isLoading.value
                        ? spinkit(color: Colors.pink, size: 30.0)
                        : Padding(
                            padding: EdgeInsets.only(
                                right: size.width * 0.15,
                                left: size.width * 0.25),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                if (signupEmailController.text != '') {
                                  if (widget.goAhead) {
                                    if (signupPasswordController.text != '' &&
                                        signupConfirmPasswordController.text !=
                                            '') {
                                      controller.signupUser(
                                          email: signupEmailController.text,
                                          password:
                                              signupPasswordController.text,
                                          accountType: 'accountType',
                                          userProvider: userProvider);
                                    } else {
                                      Get.snackbar("Missing Fields".tr,
                                          "Entered all the data".tr);
                                    }
                                  } else {
                                    controller.isLoading.value = true;
                                    myauth.setConfig(
                                        appEmail: "me@rohitchouhan.com",
                                        appName: "Email OTP",
                                        userEmail: signupEmailController.text,
                                        otpLength: 4,
                                        otpType: OTPType.digitsOnly);
                                    if (await myauth.sendOTP() == true) {
                                      Get.showSnackbar(const GetSnackBar(
                                        backgroundColor: Colors.green,
                                        snackPosition: SnackPosition.TOP,
                                        duration: Duration(seconds: 2),
                                        title: "OTP sent",
                                        message:
                                            "OTP has been sent to your email",
                                      ));
                                      controller.isLoading.value = false;
                                      Get.to(() => OTPScreen(
                                            myAuth: myauth,
                                            email: signupEmailController.text,
                                          ));
                                    } else {
                                      Get.showSnackbar(const GetSnackBar(
                                        backgroundColor: Colors.red,
                                        snackPosition: SnackPosition.TOP,
                                        duration: Duration(seconds: 2),
                                        title: "OTP Failed",
                                        message: "OTP sending failed",
                                      ));
                                      controller.isLoading.value = false;
                                    }
                                  }
                                }
                              },
                              child: Container(
                                height: 55.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: buttonGradient,
                                ),
                                child: controller.isLoading.value
                                    ? spinkit(color: Colors.white, size: 20)
                                    : Center(
                                        child: Text(
                                        widget.goAhead ? "Sign Up" : 'Send OTP',
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
                    SizedBox(
                      height: size.height * 0.22,
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account",
                                style: TextStyle(fontSize: 11.sp),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.off(() => LoginPage(),
                                      transition: Transition.zoom,
                                      duration:
                                          const Duration(milliseconds: 800));
                                },
                                child: Text(
                                  "Login here".tr,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontStyle: FontStyle.italic,
                                      color: appBarColor),
                                ),
                              )
                            ])),
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
