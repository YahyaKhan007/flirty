// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../models/user_model.dart';
import '../../pages.dart';
import '../../utils/ad_helper.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade100,
        highlightColor: Colors.grey.shade500,
        child: ListTile(
          leading: CircleAvatar(
            radius: 27.r,
            backgroundColor: Colors.white,
          ),
          title: Container(
              height: 5,
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.4),
          subtitle: Container(height: 3, color: Colors.white, width: 50),
        ),
      ),
    );
  }
}

class MatchedUsers extends StatefulWidget {
  final UserModel currentUserModel;
  const MatchedUsers({super.key, required this.currentUserModel});

  @override
  State<MatchedUsers> createState() => _MatchedUsersState();
}

class _MatchedUsersState extends State<MatchedUsers> {
  late UserProvider userProvider;
  late FirebaseAuthController controller;

  @override
  void initState() {
    controller = Get.find<FirebaseAuthController>();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    initilizeBannerAd();
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.userModel!.uid)
        .update({'lastActive': Timestamp.now()});
    // Call the init method to fetch all users
    controller.getAllUsers(userModel: widget.currentUserModel);
    Future.delayed(const Duration(seconds: 8), () {
      Get.find<FirebaseAuthController>().showShimmer.value = false;
    });
  }

  // ! Google Ads Banner
  late BannerAd matchScreenBanner;
  void initilizeBannerAd() async {
    matchScreenBanner = BannerAd(
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
    await matchScreenBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SizedBox(
          height: matchScreenBanner.size.height.toDouble(),
          width: matchScreenBanner.size.width.toDouble(),
          child: AdWidget(ad: matchScreenBanner),
        ),
        body: Obx(
          () => controller.matchedUserList.isEmpty &&
                  Get.find<FirebaseAuthController>().showShimmer.value
              ? const ShimmerEffect()
              : controller.matchedUserList.isEmpty &&
                      !Get.find<FirebaseAuthController>().showShimmer.value
                  ? Center(
                      child: Text(
                        "No Matches Yet",
                        style: GoogleFonts.cinzel(
                            color: appBarColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp),
                      ),
                    )
                  : SizedBox(
                      height: size.height,
                      width: size.width,
                      child: ListView.builder(
                          itemCount: controller.matchedUserList.length,
                          itemBuilder: ((context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Get.to(() {
                                      return Profile(
                                          endUser: true,
                                          userModel: controller
                                              .matchedUserList[index]!,
                                          distance:
                                              Random().nextInt(100).toDouble()
                                          // distanceBetween(
                                          //     userLatitude: controller
                                          //         .matchedUserList[index]!
                                          //         .latitude!,
                                          //     userLongitude: controller
                                          //         .matchedUserList[index]!
                                          //         .longitude!,
                                          //     yourLatitude:
                                          //         widget.currentUserModel.latitude!,
                                          //     yourLongitude: widget
                                          //         .currentUserModel.longitude!)
                                          );
                                    });
                                  },
                                  leading: CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor: Colors.grey.shade500,
                                    backgroundImage:
                                        // AssetImage('assets/emotion/happy.png')
                                        NetworkImage(controller
                                            .matchedUserList[index]!
                                            .profilePicture!),
                                  ),
                                  title: Text(
                                    controller
                                        .matchedUserList[index]!.fullName!,
                                    style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                          controller
                                              .matchedUserList[index]!.city!,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12.sp)),
                                      const Text(" : "),
                                      Text(
                                        controller
                                            .matchedUserList[index]!.country!,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "Flirty",
                                    style: GoogleFonts.cinzel(
                                      fontSize: 13.sp,
                                      color: appBarColor,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Divider(
                                    endIndent: 20.w,
                                    indent: 70.w,
                                    height: 0,
                                    thickness: 0.5,
                                    color: Colors.black38)
                              ],
                            );
                          })),
                    ),
        ));
  }
}
