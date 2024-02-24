// ignore_for_file: must_be_immutable, avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../pages.dart';

import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  final UserModel userModel;
  const HomePage({super.key, required this.userModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // var items = [
  //   'https://upload.wikimedia.org/wikipedia/en/b/b4/Sharbat_Gula.jpg',
  //   'https://upload.wikimedia.org/wikipedia/en/b/b4/Sharbat_Gula.jpg',
  //   'https://upload.wikimedia.org/wikipedia/en/b/b4/Sharbat_Gula.jpg',
  // ];

  late FirebaseAuthController firebaseController;
  late UserProvider userProvider;

  final RateMyApp ratemMyApp = RateMyApp(
      minDays: 0,
      minLaunches: 1,
      remindDays: 0,
      remindLaunches: 2,
      googlePlayIdentifier: 'com.panothi.flirty_updated');

  @override
  void initState() {
    // ^ For leaving a review
    ratemMyApp.init().then((value) => {
          ratemMyApp.conditions.forEach((element) {
            if (element is DebuggableCondition) {
              print(element.valuesAsString);
            }
          }),
          if (ratemMyApp.shouldOpenDialog)
            {
              ratemMyApp.showRateDialog(context,
                  title: "Rate this app",
                  message:
                      "If you like this app please take a little bit of your time to review it !\nIt really helps us and it shouldn't take you more than one minute",
                  rateButton: "RATE",
                  // noButton: 'NO THANKS',
                  laterButton: "MAY BE LATER",
                  // dialogTransition:
                  //     DialogTransition(transitionType: TransitionType.rotation),
                  onDismissed: () => ratemMyApp
                      .callEvent(RateMyAppEventType.laterButtonPressed))
            }
        });

    // ^ Normal app functionalities

    firebaseController = Get.find<FirebaseAuthController>();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    // log(userProvider.userModel!.fullName.toString());
    super.initState();

    Future.delayed(const Duration(seconds: 2),
        () => firebaseController.isLoading.value = false);
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(const Duration(seconds: 5), ()=> Get.dialog(widget,
    //     barrierColor: Colors.green,
    //     useSafeArea: true
    // ));

    print(widget.userModel.fullName.toString());
    Size size = MediaQuery.of(context).size;

    var pages = [
      // ! Find Match Screen Started
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: FindMatch(
          size: size,
          userModel: widget.userModel,
          firebaseController: firebaseController,
        ),
      ),
      // ~ Find Match Screen Ended

      // ! Notification Screen Started
      NotificationScreen(userModel: widget.userModel),
      // ~  Notification Screen Ended

      // ! Chats Screen Started
      ChatScreen(userModel: widget.userModel),
      // ~ Chats Screen Ended

      // ! Matched Screen Started
      MatchedUsers(currentUserModel: widget.userModel),
      // ~ Matched Screen Ended
    ];

    // final MyController controller = MyController();

    return DefaultTabController(
      length: 4,
      animationDuration: const Duration(milliseconds: 400),
      child: Scaffold(
          // backgroundColor: Colors.pink.shade100,
          appBar: AppBar(
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(10), child: SizedBox()),
            leadingWidth: 80,
            leading: CupertinoButton(
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              onPressed: () {
                Get.to(() => Profile(
                    distance: Random().nextInt(100).toDouble(),
                    // distanceBetween(
                    //     userLatitude: widget.userModel.latitude!,
                    //     userLongitude: widget.userModel.longitude!,
                    //     yourLatitude: myLatitude,
                    //     yourLongitude: myLongitude),
                    endUser: false,
                    userModel: userProvider.userModel!));
              },
              child: FutureBuilder<void>(
                future: precacheImage(
                  NetworkImage(
                    widget.userModel.profilePicture == ''
                        ? 'https://static.thenounproject.com/png/55168-200.png'
                        : widget.userModel.profilePicture.toString(),
                    scale: 0.01,
                  ),
                  context,
                ),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Center(
                        child: spinkit(color: appBarColor, size: 20.r),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Handle the error
                    return const Text('Error loading image');
                  } else {
                    // Image is loaded, display it
                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.userModel.profilePicture!,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            // actions: [
            //   IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.gift, color: Colors.white,),)
            // ],
            title: Image.asset(
              "assets/logo.png",
              color: Colors.white,
              width: size.height * 0.15,
            ),
            centerTitle: true,
            backgroundColor: appBarColor,
          ),
          body: Obx(() => pages[firebaseController.selectedIndex.value]),
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              selectedLabelStyle:
                  GoogleFonts.cinzel(fontWeight: FontWeight.bold),
              type: BottomNavigationBarType.shifting,
              currentIndex: firebaseController.selectedIndex.value,
              selectedItemColor: appBarColor,
              showUnselectedLabels: true,
              unselectedItemColor: Colors.black,
              showSelectedLabels: true,
              onTap: (index) {
                firebaseController.selectedIndex.value = index;
              },
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/match.png',
                    height: 16.h,
                    color: firebaseController.selectedIndex.value == 0
                        ? appBarColor
                        : Colors.grey.shade800,
                  ),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: userProvider.userModel?.notifications != 0
                        ? true
                        : false,
                    badgeStyle:
                        const badges.BadgeStyle(badgeColor: Colors.green),
                    badgeContent: Center(
                        child: Text(
                      userProvider.userModel!.notifications!.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    )),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: firebaseController.selectedIndex.value == 1
                          ? appBarColor
                          : Colors.grey.shade800,
                    ),
                  ),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.chat_bubble_2,
                    color: firebaseController.selectedIndex.value == 2
                        ? appBarColor
                        : Colors.grey.shade800,
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.heart_circle,
                    color: firebaseController.selectedIndex.value == 3
                        ? appBarColor
                        : Colors.grey.shade800,
                  ),
                  label: 'Matches',
                ),
              ],
            ),
          )),
    );
  }
}

// ~ Start of Find Match Screen
class FindMatch extends StatefulWidget {
  final Size size;
  final UserModel userModel;

  final FirebaseAuthController firebaseController;
  const FindMatch({
    super.key,
    required this.size,
    required this.userModel,
    required this.firebaseController,
  });

  @override
  State<FindMatch> createState() => _FindMatchState();
}

class _FindMatchState extends State<FindMatch> {
  late UserProvider userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    super.initState();
    Future.delayed(
      const Duration(seconds: 4),
      () => Get.find<FirebaseAuthController>().restoreToDefault(),
    );

    userProvider.getAllUsers();

    if (userProvider.userModel?.lastActive != Timestamp.now()) {
      userProvider.userModel?.lastActive = Timestamp.now();
      // Update 'lastActive' in Firebase or perform other actions
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.userModel?.uid)
        .update({'lastActive': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = Provider.of<UserProvider>(context).users;
    return Scaffold(
      body: allUsers.isNotEmpty
          ? SizedBox(
              child: CarouselSlider.builder(
                itemCount: allUsers.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  print('All User are   --->  ${allUsers.length}');
                  return SizedBox(
                    height: widget.size.height,
                    width: widget.size.width * 0.82,
                    // color: Colors.blue,
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: widget.size.height * 0.7,
                                width: widget.size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: appBarColor),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        allUsers[itemIndex].profilePicture!,
                                      ),
                                      fit: BoxFit.cover),
                                ),
                                child: FutureBuilder<void>(
                                  future: precacheImage(
                                    NetworkImage(
                                      allUsers[itemIndex]
                                          .profilePicture
                                          .toString(),
                                    ),
                                    context,
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<void> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: spinkit(
                                            color: Colors.pink, size: 30.r),
                                      );
                                    } else if (snapshot.hasError) {
                                      // Handle the error
                                      return const Text('Error loading image');
                                    } else {
                                      // Image is loaded, display it
                                      return Image.network(
                                        allUsers[itemIndex].profilePicture!,
                                      );
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: widget.size.width,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          color: appBarColor),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.h,
                                            left: 13.w,
                                            bottom: 5.h,
                                            right: 50.w),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Name :   ${allUsers[itemIndex].fullName}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                            Text(
                                              "Sex : ${allUsers[itemIndex].gender}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                            Text(
                                              "${allUsers[itemIndex].city} : ${allUsers[itemIndex].country}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                            Text(
                                              "Age : ${allUsers[itemIndex].age}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                            Text(
                                              "Interested in : ${allUsers[itemIndex].interestedIn}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 00.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    height: 30.h,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.r),
                                                    ),
                                                    child: CupertinoButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        child: Center(
                                                          child: Text(
                                                            "View Profile",
                                                            style: GoogleFonts
                                                                .cinzel(
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium,
                                                                    decorationColor:
                                                                        Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    // backgroundColor: Colors.blue.shade100,
                                                                    color:
                                                                        appBarColor,
                                                                    fontSize:
                                                                        10.sp),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Get.to(() {
                                                            return Profile(
                                                                endUser: true,
                                                                userModel:
                                                                    allUsers[
                                                                        itemIndex],
                                                                distance: Random()
                                                                    .nextInt(
                                                                        100)
                                                                    .toDouble()
                                                                //  distanceBetween(
                                                                //     userLatitude:
                                                                //         allUsers[itemIndex]
                                                                //             .latitude!,
                                                                //     userLongitude:
                                                                //         allUsers[itemIndex]
                                                                //             .longitude!,
                                                                //     yourLatitude: widget
                                                                //         .userModel
                                                                //         .latitude!,
                                                                //     yourLongitude: widget
                                                                //         .userModel
                                                                //         .longitude!)
                                                                );
                                                          });
                                                        }),
                                                  ),
                                                  Obx(
                                                    () => CircleAvatar(
                                                      radius: 20.r,
                                                      backgroundColor: allUsers[
                                                                      itemIndex]
                                                                  .reciever!
                                                                  .contains(widget
                                                                      .userModel
                                                                      .uid) ||
                                                              allUsers[
                                                                      itemIndex]
                                                                  .blockedUsers!
                                                                  .contains(widget
                                                                      .userModel
                                                                      .uid) ||
                                                              allUsers[
                                                                      itemIndex]
                                                                  .liked!
                                                                  .contains(widget
                                                                      .userModel
                                                                      .uid)
                                                          ? Colors.white
                                                          : Colors.red,
                                                      child: widget
                                                              .firebaseController
                                                              .likeLoading
                                                              .value
                                                          ? spinkit(
                                                              color:
                                                                  Colors.black,
                                                              size: 15.sp)
                                                          : CupertinoButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              child: Icon(
                                                                Icons
                                                                    .favorite_sharp,
                                                                size: 27.r,
                                                                color: allUsers[itemIndex].reciever!.contains(widget.userModel.uid) ||
                                                                        allUsers[itemIndex].blockedUsers!.contains(widget
                                                                            .userModel
                                                                            .uid) ||
                                                                        allUsers[itemIndex].liked!.contains(widget
                                                                            .userModel
                                                                            .uid)
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                // log(userProvider
                                                                //     .userModel
                                                                //     .toString());
                                                                if (allUsers[
                                                                        itemIndex]
                                                                    .blockedUsers!
                                                                    .contains(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)) {
                                                                  recievedSnakbar(
                                                                      userModel:
                                                                          allUsers[
                                                                              itemIndex]);
                                                                } else if (allUsers[
                                                                        itemIndex]
                                                                    .reciever!
                                                                    .contains(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)) {
                                                                  redSnakbar(
                                                                      userModel:
                                                                          allUsers[
                                                                              itemIndex]);
                                                                } else if (allUsers[
                                                                        itemIndex]
                                                                    .liked!
                                                                    .contains(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)) {
                                                                  matchSnakbar(
                                                                      userModel:
                                                                          allUsers[
                                                                              itemIndex]);
                                                                } else {
                                                                  widget.firebaseController.like(
                                                                      endUser:
                                                                          allUsers[
                                                                              itemIndex],
                                                                      selfProvider:
                                                                          userProvider);
                                                                }

                                                                // snakbar(
                                                                //     userModel:
                                                                //         allUsers[
                                                                //             itemIndex]);
                                                              },
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                    height: widget.size.height,
                    enableInfiniteScroll: false,
                    reverse: false,
                    viewportFraction: 0.85,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    aspectRatio: 16 / 8),
              ),
            )
          : Center(
              child: spinkit(color: appBarColor, size: 30.sp),
            ),
    );
  }
}
// ! end of Find Match Screen
