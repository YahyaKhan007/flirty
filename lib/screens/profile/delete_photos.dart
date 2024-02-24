// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flirty_updated/controllers/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../controllers/constants/ui_constants.dart';
import '../../utils/ad_helper.dart';

class DeletePhotos extends StatefulWidget {
  final UserModel endUserModel;
  const DeletePhotos({super.key, required this.endUserModel});

  @override
  State<DeletePhotos> createState() => _DeletePhotosState();
}

class _DeletePhotosState extends State<DeletePhotos> {
  final CarouselController _controller = CarouselController();
  ScrollController scrollController = ScrollController();
  int _current = 0;

  late FirebaseAuthController controller;

  @override
  void initState() {
    controller = Get.find<FirebaseAuthController>();
    controller.tempImageList.value = widget.endUserModel.photos!;
    initializeBannerAd();

    super.initState();
  }

  late BannerAd profileBanner;
  void initializeBannerAd() {
    profileBanner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAds1(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            // Ad loaded successfully
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Ad failed to load
          print('Banner Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );

    profileBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    Size size = MediaQuery.of(context).size;

    double height = size.height;
    // double width =  size.width;
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appBarColor.withRed(10),
              const Color.fromARGB(255, 190, 54, 72).withGreen(10)
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

// begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Obx(
              () => Column(
                children: [
                  Container(
                    height: height * 0.82,
                    width: size.width,
                    decoration: const BoxDecoration(
                        // color: Colors.green.shade200,
                        ),
                    child: CarouselSlider.builder(
                      carouselController: _controller,
                      itemCount: controller.tempImageList.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r)),
                          image: DecorationImage(
                              image: NetworkImage(
                                controller.tempImageList[itemIndex],
                              ),
                              fit: BoxFit.cover),
                        ),
                        width: size.width,
                        // child: Image.network(
                        //   widget.userModel.photos![itemIndex],
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      options: CarouselOptions(
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                          height: size.height,
                          enlargeCenterPage:
                              true, // This will make the current page larger
                          autoPlay: false,
                          animateToClosest: true,
                          enableInfiniteScroll: false,
                          viewportFraction: 0.85,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          aspectRatio: 16 / 8),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        controller.tempImageList.asMap().entries.map((entry) {
                      return GestureDetector(
                        // onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                                      _current == entry.key ? 0.9 : 0.4)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50.h,
              child: Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 16.r,
                  child: Center(
                    child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Get.back();
                        }),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 20,
                child: SizedBox(
                  width: size.width,
                  child: Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var itemIndex = 0;
                              itemIndex < controller.tempImageList.length;
                              itemIndex++)
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 10.h),
                                  child: SizedBox(
                                    height: 70.h,
                                    width: 70.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        controller.tempImageList[itemIndex],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Visibility(
                                      visible: itemIndex != 0,
                                      child: Container(
                                          height: 30.h,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                appBarColor.withRed(10),
                                                const Color.fromARGB(
                                                        255, 190, 54, 72)
                                                    .withGreen(10)
                                              ],
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              size: 12.sp,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              controller.deletePhotos(
                                                  index: itemIndex,
                                                  endUserModel:
                                                      widget.endUserModel,
                                                  userProvider: userProvider);
                                            },
                                          )),
                                    ))
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                height: 20.h,
                child: AdWidget(ad: profileBanner),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
