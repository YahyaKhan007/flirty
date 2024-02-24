// // app_open_ads.dart
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AppOpenAds {
//   static void initialize() {
//     MobileAds.instance.updateRequestConfiguration(
//       RequestConfiguration(
//         testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
//       ),
//     );
//   }

//   static Future<void> loadAppOpenAd() async {
//     final appOpenAd = AppOpenAd(
//       adUnitId: '<your-ad-unit-id>',
//       request: AdRequest(),
//       orientation: AppOpenAdOrientation.portrait,
//       loadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (ad) {
//           ad.show();
//         },
//         onAdFailedToLoad: (error) {
//           print('App Open Ad failed to load: $error');
//         },
//       ),
//     );

//     appOpenAd.load();
//   }
// }

