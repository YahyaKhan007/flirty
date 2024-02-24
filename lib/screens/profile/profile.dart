// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flirty_updated/screens/profile/delete_photos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../controllers/chatroom_controller.dart';
import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../pages.dart';
import '../../utils/ad_helper.dart';
import '../chatscreen/chatroom.dart';

import 'package:image_picker/image_picker.dart';

import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:flutter_glow/flutter_glow.dart';

// import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final bool endUser;
  final UserModel userModel;
  final double distance;
  const Profile(
      {super.key,
      required this.endUser,
      required this.userModel,
      required this.distance});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  var controller = Get.find<FirebaseAuthController>();

  late ProgressDialog pr;

  final ImagePicker _picker = ImagePicker();

  late UserProvider userProvider;

  @override
  void initState() {
    pr = ProgressDialog(context: context);
    userProvider = Provider.of<UserProvider>(context, listen: false);

    initializeBannerAd();
    initializeRewardedAd();
    loadRewadedAd();
    super.initState();
  }

  getTime() {
    var authController = Get.put(FirebaseAuthController());
    // print(widget.userModel.lastActive);
    Timestamp firebaseTimestamp = widget.userModel.lastActive!;

    // Calculate the time difference
    authController.lastActive.value = firebaseTimestamp;

    print(
        'Time ago: ${authController.getFormattedTimeAgo(lastActive: firebaseTimestamp)}');
  }

  void uploadImages() async {
    pr.show(max: 100, msg: 'Uploading Images');

    try {
      List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        // widget.userModel.photos!.clear();
        // add existing profile photo
        widget.userModel.photos!.add(widget.userModel.profilePicture);

        int completed = 0;

        for (var image in images) {
          Reference ref =
              FirebaseStorage.instance.ref().child('images/${DateTime.now()}');

          UploadTask task = ref.putFile(File(image.path));

          String url = await (await task).ref.getDownloadURL();

          widget.userModel.photos!.add(url);

          completed++;

          /* Update Progress Indicator */
          pr.update(
            msg: '$completed/${images.length} done!',
          );
        }

        // all uploads done
        pr.close();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userModel.uid)
            .update({'photos': widget.userModel.photos}).then(
                (value) => userProvider.updateUser(widget.userModel));

        setState(() {});
      } else {
        pr.close();
        pr.close();
        pr.close();
        pr.close();
        // Get.back();
      }
    } catch (e) {
      pr.close();
      print(e);
    }
  }

  RewardedAd? rewardedAd;

  void initializeRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAd(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() {
          rewardedAd = ad;
          // controller.rewardedFreeMessages.value ++;
        }),
        onAdFailedToLoad: (error) => setState(() {
          rewardedAd = null;
          print('rewarded Ad failed to load: $error');
        }),
      ),
    );
  }

  void loadRewadedAd() {
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          // onAdImpression: (reward){
          //   controller.rewardedFreeMessages.value = controller.rewardedFreeMessages.value + 1;
          // },
          onAdDismissedFullScreenContent: (ad) {
        // ad.dispose();
        initializeRewardedAd();
      }, onAdFailedToShowFullScreenContent: (ad, err) {
        // ad.dispose();
        initializeRewardedAd();
      });
    }
    rewardedAd = null;
  }

  showRewardedAd() {
    rewardedAd!.show(onUserEarnedReward: (ad, reward) async {
      controller.rewardedFreeMessages.value =
          controller.rewardedFreeMessages.value + 1;
      controller.isChatOpen.value = true;

      var chatroomController = Get.find<ChatroomController>();
      ChatRoomModel? chatRoom = await chatroomController.getChatroomModel(
          targetUser: widget.userModel, userModel: userProvider.userModel!);
      controller.isChatOpen.value = false;
      Get.back();
      Get.to(
        () => Chatroom(
            enduser: widget.userModel,
            firebaseUser: FirebaseAuth.instance.currentUser!,
            chatRoomModel: chatRoom!,
            currentUserModel: userProvider.userModel!),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 500),
      );
    });
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
    getTime();
    print(widget.userModel.age);
    // UserProvider userProvider = Provider.of<UserProvider>(context);
    Size size = MediaQuery.of(context).size;

    // widget.userModel.sender!.contains(FirebaseAuth.instance.currentUser!.uid)
    //     ? print("You are existed in his receiver list")
    //     : print("You are not existed in his receiver list");

    // FirebaseAPI().initNotification();

    return Scaffold(
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
          alignment: Alignment.bottomLeft,
          children: [
            Column(
              children: [
                Container(
                  height:
                      widget.endUser ? size.height * 0.65 : size.height * 0.75,
                  width: size.width,
                  decoration: const BoxDecoration(
                      // color: Colors.green.shade200,
                      ),
                  child: CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: widget.userModel.photos!.length,
                    itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) =>
                        Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.r),
                            bottomRight: Radius.circular(30.r)),
                        image: DecorationImage(
                            image: NetworkImage(
                              widget.userModel.photos![itemIndex],
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
                      widget.userModel.photos!.asMap().entries.map((entry) {
                    return GestureDetector(
                      // onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            Positioned(
                top: 0,
                child: Container(
                  margin: EdgeInsets.only(top: 30.h),
                  height: 80.h,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
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
                        // Text(
                        //   "Profile",
                        //   style: GoogleFonts.blackOpsOne(
                        //     fontSize: 26.sp,
                        //     textStyle: Theme.of(context).textTheme.bodyMedium,
                        //     decorationColor: Colors.black,
                        //     // backgroundColor: Colors.grey.shade100,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        const SizedBox(),
                        !widget.endUser
                            ? Visibility(
                                visible: !widget.endUser,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.w),
                                  child: CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: Colors.grey,
                                    child: Center(
                                      child: PopupMenuButton<String>(
                                        color: const Color(0xffEC755A),
                                        constraints: BoxConstraints(
                                            minWidth: size.width * 0.2,
                                            maxWidth: size.width * 0.4),
                                        padding: EdgeInsets.zero,
                                        icon: Image.asset(
                                          "assets/edit.png",
                                          height: 18.sp,
                                          color: Colors.white,
                                        ),
                                        onSelected: (value) async {
                                          if (value == 'logout') {
                                            Get.dialog(
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.2,
                                                    vertical:
                                                        size.height * 0.35),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent
                                                      .withOpacity(0.3),
                                                ),
                                                child: Center(
                                                  child: spinkit(
                                                      color: Colors.white,
                                                      size: 35.sp),
                                                ),
                                              ),
                                            );
                                            controller.signoutUser();
                                          } else if (value == 'editProfile') {
                                            // Handle edit profile
                                            Get.to(() => CompleteProfile(
                                                userModel: widget.userModel,
                                                firebaseUser: FirebaseAuth
                                                    .instance.currentUser,
                                                isEdit: true));
                                          } else if (value == 'add') {
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            // ~ Add More Photos
                                            uploadImages();

                                            // try {
                                            //   List<XFile>? images =
                                            //       await _picker.pickMultiImage();

                                            //   if (images.isNotEmpty) {
                                            //     widget.userModel.photos!.clear();
                                            //     widget.userModel.photos!.add(
                                            //         widget.userModel
                                            //             .profilePicture);

                                            //     Get.dialog(
                                            //       Container(
                                            //         margin: EdgeInsets.symmetric(
                                            //             horizontal:
                                            //                 size.width * 0.2,
                                            //             vertical:
                                            //                 size.height * 0.35),
                                            //         decoration: BoxDecoration(
                                            //           color: Colors.transparent
                                            //               .withOpacity(0.3),
                                            //         ),
                                            //         child: Center(
                                            //           child: spinkit(
                                            //               color: Colors.white,
                                            //               size: 35.sp),
                                            //         ),
                                            //       ),
                                            //     );

                                            //     images.forEach((image) async {
                                            //       log('came');
                                            //       Reference ref = FirebaseStorage
                                            //           .instance
                                            //           .ref()
                                            //           .child(
                                            //               'images/${DateTime.now()}');

                                            //       UploadTask uploadTask = ref
                                            //           .putFile(File(image.path));

                                            //       TaskSnapshot snapshot =
                                            //           await uploadTask;

                                            //       String downloadURL =
                                            //           await snapshot.ref
                                            //               .getDownloadURL();

                                            //       widget.userModel.photos!
                                            //           .add(downloadURL);
                                            //     });

                                            //     await FirebaseFirestore.instance
                                            //         .collection('users')
                                            //         .doc(widget.userModel.uid)
                                            //         .update({
                                            //       'photos':
                                            //           widget.userModel.photos
                                            //     }).then((value) => Get.back());
                                            //     Future.delayed(
                                            //         const Duration(seconds: 3),
                                            //         () {
                                            //       setState(() {});
                                            //     });
                                            //   }
                                            // } catch (e) {
                                            //   log("Error ----->   $e");
                                            // }
                                          } else if (value == 'delete_photos') {
                                            Get.to(
                                              () => DeletePhotos(
                                                endUserModel: widget.userModel,
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return [
                                            PopupMenuItem(
                                              value: 'editProfile',
                                              child: FittedBox(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                      'assets/edit_profile.png',
                                                      height: 18.sp,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    const Text(
                                                      'Edit Profile',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'add',
                                              child: FittedBox(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      color: Colors.white,
                                                      size: 18.r,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    const Text(
                                                      'Add more photos',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete_photos',
                                              child: FittedBox(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .delete_sweep_outlined,
                                                      color: Colors.white,
                                                      size: 18.r,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    const Text(
                                                      'Delete Photos',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'logout',
                                              child: FittedBox(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.logout_outlined,
                                                      color: Colors.white,
                                                      size: 18.r,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    const Text(
                                                      'Logout',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ];
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.only(right: 15.w),
                                //   child: CircleAvatar(
                                //     backgroundColor: Colors.grey,
                                //     radius: 16.r,
                                //     child: CupertinoButton(
                                //         padding: EdgeInsets.zero,
                                //         child: Center(
                                //           child: Image.asset(
                                //             'assets/edit.png',
                                //             height: 18.h,
                                //           ),
                                //         ),
                                //         onPressed: () {

                                //           Get.find<FirebaseAuthController>()
                                //               .signoutUser();
                                //         }),
                                //   ),
                                // ),
                              )
                            : const SizedBox()
                      ]),
                )),
            Positioned(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Row(
                        children: [
                          Text(
                            widget.userModel.age.toString(),
                            style: GoogleFonts.lora(
                              letterSpacing: 1,

                              fontSize: 55.sp,
                              // textStyle: Theme.of(context).textTheme.bodyMedium,
                              fontWeight: FontWeight.w100,
                              decorationColor: Colors.black,
                              // backgroundColor: Colors.grey.shade100,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 30.w,
                          ),
                          Visibility(
                            visible: widget.endUser,
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/active_dot.png",
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  " ${controller.getFormattedTimeAgo(lastActive: widget.userModel.lastActive!)}",
                                  style: GoogleFonts.lora(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 15.sp),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Text(
                            widget.userModel.fullName!,
                            style: GoogleFonts.playfairDisplay(
                              letterSpacing: 1,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w100,
                              // textStyle: Theme.of(context).textTheme.bodyMedium,
                              decorationColor: Colors.black,
                              // backgroundColor: Colors.grey.shade100,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          widget.endUser
                              ? Text(
                                  "[ ${widget.distance.toStringAsFixed(0)}k - km-away ]",
                                  style: TextStyle(
                                      color: Colors.yellow, fontSize: 12.sp))
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          Text(
                            widget.userModel.city!,
                            style: GoogleFonts.playfairDisplay(
                              letterSpacing: 1,

                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              // textStyle: Theme.of(context).textTheme.bodyMedium,
                              decorationColor: Colors.black,
                              // backgroundColor: Colors.grey.shade100,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            ":",
                            style: GoogleFonts.playfairDisplay(
                              letterSpacing: 1,

                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              // textStyle: Theme.of(context).textTheme.bodyMedium,
                              decorationColor: Colors.black,
                              // backgroundColor: Colors.grey.shade100,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            widget.userModel.country.toString(),
                            style: GoogleFonts.playfairDisplay(
                              letterSpacing: 1,

                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              // textStyle: Theme.of(context).textTheme.bodyMedium,
                              decorationColor: Colors.black,
                              // backgroundColor: Colors.grey.shade100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.userModel.bio!.length <= 40
                              ? widget.userModel.bio!.replaceAll('\n', ' ')
                              : '${widget.userModel.bio!.substring(0, 40).replaceAll('\n', ' ')}...',
                          style: GoogleFonts.playfairDisplay(
                            letterSpacing: 1,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w100,
                            // textStyle: Theme.of(context).textTheme.bodyMedium,
                            decorationColor: Colors.black,
                            // backgroundColor: Colors.grey.shade100,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    widget.endUser
                        ? Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: controller.isChatOpen.value
                                      ? null
                                      : () async {
                                          // ~ Chatroom detection
                                          if (widget.userModel.liked!.contains(
                                              userProvider.userModel!.uid)) {
                                            log("click");
                                            controller.isChatOpen.value = true;

                                            var chatroomController =
                                                Get.find<ChatroomController>();
                                            ChatRoomModel? chatRoom =
                                                await chatroomController
                                                    .getChatroomModel(
                                                        targetUser:
                                                            widget.userModel,
                                                        userModel: userProvider
                                                            .userModel!);
                                            controller.isChatOpen.value = false;

                                            Get.to(
                                              () => Chatroom(
                                                  enduser: widget.userModel,
                                                  firebaseUser: FirebaseAuth
                                                      .instance.currentUser!,
                                                  chatRoomModel: chatRoom!,
                                                  currentUserModel:
                                                      userProvider.userModel!),
                                              transition: Transition
                                                  .rightToLeftWithFade,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                            );
                                          } else {
                                            Get.snackbar("Not Matched",
                                                "You can not message ${widget.userModel.fullName}, unless you both are matched",
                                                barBlur: 20);
                                          }
                                        },
                                  child: Container(
                                    height: 55.h,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        gradient: buttonGradient),
                                    child: Center(
                                        child: Text(
                                      "Write Me",
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
                                width: 15.w,
                              ),
                              Obx(
                                () => CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    print(widget.userModel.blockedUsers);
                                    if (widget.userModel.blockedUsers!.contains(
                                        FirebaseAuth
                                            .instance.currentUser!.uid)) {
                                      Get.dialog(
                                          barrierDismissible: false,
                                          transitionDuration:
                                              const Duration(milliseconds: 500),
                                          CupertinoButton(
                                            alignment: Alignment.bottomLeft,
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Container(
                                              height: size.height * 0.2,
                                              width: 300,
                                              margin: EdgeInsets.only(
                                                  bottom: size.height * 0.1,
                                                  right: size.width * 0.2),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          "Accept",
                                                          style: GoogleFonts
                                                              .cinzel(
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 15.w,
                                                        ),
                                                        CupertinoButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          onPressed: () {
                                                            Get.back();
                                                            // ! Add Mutual
                                                            controller.matched(
                                                                userProvider:
                                                                    userProvider,
                                                                opponentModel:
                                                                    widget
                                                                        .userModel);
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 22.r,
                                                            backgroundColor:
                                                                Colors.green,
                                                            child: Center(
                                                              child: controller
                                                                      .likeLoading
                                                                      .value
                                                                  ? spinkit(
                                                                      color: Colors
                                                                          .white,
                                                                      size: 25)
                                                                  : const Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 30.h,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          "Reject",
                                                          style: GoogleFonts
                                                              .cinzel(
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 15.w,
                                                        ),
                                                        CircleAvatar(
                                                          radius: 22.r,
                                                          backgroundColor:
                                                              Colors.red,
                                                          child:
                                                              CupertinoButton(
                                                            onPressed: () {
                                                              controller.rejectLike(
                                                                  opponentModel:
                                                                      widget
                                                                          .userModel,
                                                                  userProvider:
                                                                      userProvider);

                                                              Get.back();
                                                            },
                                                            padding:
                                                                EdgeInsets.zero,
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                              // color: Colors.white,
                                            ),
                                          ));
                                    } else if (widget.userModel.liked!.contains(
                                            userProvider.userModel!.uid) ||
                                        userProvider.userModel!.liked!
                                            .contains(widget.userModel.uid)) {
                                      controller.unMatch(
                                          isBlock: false,
                                          opponentModel: widget.userModel,
                                          userProvider: userProvider);
                                    } else if (widget.userModel.reciever!
                                            .contains(FirebaseAuth
                                                .instance.currentUser!.uid) ||
                                        userProvider.userModel!.blockedUsers!
                                            .contains(widget.userModel.uid)) {
                                      controller.unSendLike(
                                          opponentModel: widget.userModel,
                                          userProvider: userProvider);
                                    } else {
                                      log("click on Like button ..............................................");
                                      controller.like(
                                          endUser: widget.userModel,
                                          selfProvider: userProvider);
                                    }
                                  },
                                  child: controller.likeLoading.value
                                      ? spinkit(color: Colors.white, size: 15.r)
                                      : Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: widget.userModel.liked!
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: widget.userModel.blockedUsers!
                                                              .contains(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) ||
                                                          widget.userModel.reciever!
                                                              .contains(FirebaseAuth.instance.currentUser!.uid)
                                                      ? Colors.transparent
                                                      : Colors.white54),
                                              shape: BoxShape.circle),
                                          child: widget.userModel.blockedUsers!
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid) ||
                                                  widget.userModel.reciever!
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                              ? FittedBox(
                                                  child: Image.asset(
                                                      "assets/waiting.png"))
                                              : Center(
                                                  child: widget.userModel.liked!
                                                          .contains(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                      ? Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 30.sp,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .favorite_outline,
                                                          color: Colors.white54,
                                                        ),
                                                ),
                                        ),
                                ),
                              ),
                              Visibility(
                                visible: widget.userModel.liked!
                                        .contains(userProvider.userModel!.uid)
                                    ? false
                                    : true,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  child: InkWell(
                                      onTap: () {
                                        Get.dialog(
                                            barrierDismissible: false,
                                            const AlertDialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child:
                                                          CircularProgressIndicator())
                                                ],
                                              ),
                                            ));

                                        showRewardedAd();
                                      },
                                      child: GlowText(
                                        glowColor: Colors.yellow,
                                        "Free Message",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1,
                                        ),
                                      )),
                                ),
                              )
                            ],
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                          ),
                    SizedBox(
                      height: 40.h,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                height: 30.h,
                child: AdWidget(ad: profileBanner),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
