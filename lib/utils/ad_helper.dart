import 'dart:io';

class AdHelper {
  static String startingPageAd() {
    if (Platform.isAndroid) {
      // ~ ca-app-pub-8940653964189275/7442259135      ---->   real ID

      // ~ ca-app-pub-3940256099942544/9257395921      ---->   Test ID

      return "ca-app-pub-8940653964189275/7442259135";
    } else {
      return " ";
    }
  }

  //  Banner Ad
  static String bannerAds1() {
    if (Platform.isAndroid) {
      //~ Real   ID     ---------------->    ca-app-pub-8940653964189275/1583783011

      //~ Test   ID     ---------------->    ca-app-pub-3940256099942544/6300978111

      return "ca-app-pub-8940653964189275/1583783011";
    } else {
      return " ";
    }
  }

  //  Rewarded Ad
  static String rewardedAd() {
    if (Platform.isAndroid) {
      //~ Real   ID     ---------------->    ca-app-pub-8940653964189275/6710102716

      //~ Test   ID     ---------------->    ca-app-pub-3940256099942544/5224354917

      return "ca-app-pub-8940653964189275/6710102716";
    } else {
      return " ";
    }
  }
}
