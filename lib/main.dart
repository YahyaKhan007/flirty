// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flirty_updated/screens/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'bindings.dart';
import 'controllers/controllers.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart';

import 'models/models.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/on_boarding/on_boarding.dart';
import 'utils/ad_helper.dart';

SharedPreferences? prefs;
var uuid = const Uuid();

late AppOpenAd appOpenAd;

loadAppOpenAd() async {
  AppOpenAd.load(
    adUnitId: AdHelper.startingPageAd(),
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        appOpenAd = ad;
        appOpenAd.show();
      },
      onAdFailedToLoad: (er) {
        log(er.toString());
      },
    ),
    orientation: AppOpenAd.orientationPortrait,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  loadAppOpenAd();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // LocalNotificationServic.initialize();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingShown = prefs.getBool('onboarding_shown') ?? false;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    await messaging.requestPermission();

    messaging.onTokenRefresh.listen((String? newToken) {
      // Send the new token to your server
      print("the new token i s:    ${newToken.toString()}");
    });
  } catch (e) {
    log("$e");
  }

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  UserModel? thisUserModel;

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    log('User fetched');
    thisUserModel = await FirebaseHelper.getClientModelById(currentUser.uid);
    log("The Logged User is ---->  ${thisUserModel?.email.toString()}");
  }

  runApp(
    ScreenUtilInit(
      designSize: const Size(350, 690),
      ensureScreenSize: true,
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MyApp(
          userModel: thisUserModel,
          onboardingShown: onboardingShown,
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingShown;
  final UserModel? userModel;
  const MyApp(
      {super.key, required this.userModel, required this.onboardingShown});

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    log("=========================================================\n=============================================${prefs?.getBool('onboarding_shown').toString()}");
    log("=========================================================\n=============================================${onboardingShown.toString()}");
    return MultiProvider(
        providers: [
          ListenableProvider(create: (_) => LoadingProvider()),
          ListenableProvider(create: (_) => UserProvider()),
        ],
        // child: DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (BuildContext context) {
        child: GetMaterialApp(
          useInheritedMediaQuery: false,

          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          initialBinding: ControllerBinding(),
          debugShowCheckedModeBanner: false,
          // showSemanticsDebugger: true,
          title: 'Flirty',
          theme: ThemeData(
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 227, 222, 221)),
            useMaterial3: true,
          ),
          home: !onboardingShown
              ? OnBoardingScreen(
                  userModel: userModel,
                  firebaseUser: FirebaseAuth.instance.currentUser)
              : SplashScreen(
                  firebaseUser: FirebaseAuth.instance.currentUser,
                  userModel: userModel),
        ));
  }
  // ),
  //   );
  // }
}
