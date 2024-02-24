// ~ Start of Notification Screen
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../pages.dart';
import '../../utils/ad_helper.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel userModel;
  const NotificationScreen({super.key, required this.userModel});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    initilizeBannerAd();
    super.initState();
    widget.userModel.notifications = 0;
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .update({'notifications': 0});
  }

  // ! Google Ads Banner
  late BannerAd notificationBanner;
  void initilizeBannerAd() async {
    notificationBanner = BannerAd(
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
    await notificationBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: notificationBanner.size.height.toDouble(),
        width: notificationBanner.size.width.toDouble(),
        child: AdWidget(ad: notificationBanner),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userModel.uid)
              .collection("notifications")
              .orderBy("createdOn", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // !   *************************
                // CollectionReference ref =
                //     FirebaseFirestore.instance.collection('users');

                // !   *************************

                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return chatRoomSnapshot.docs.isNotEmpty
                    ? ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: ((context, index) {
                          // ! we need a chatroom model in Order to show it on the HomePage

                          NotificationModel notificationModel =
                              NotificationModel.fromMap(
                                  chatRoomSnapshot.docs[index].data()
                                      as Map<String, dynamic>);

                          // ! we also need a target user model in Order to show the detail of the target user on the HomePage

                          // !                here we finally get the target user UID
                          // !                No we can fetch target user Model

                          return FutureBuilder(
                              future: FirebaseHelper.getClientModelById(
                                  notificationModel.sender ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? notificationModel.reciever!
                                      : notificationModel.sender!),
                              builder: (context, userData) {
                                print(
                                    "the sender is ${notificationModel.sender}");
                                print(
                                    "the receiver is ${notificationModel.reciever}");
                                if (userData.connectionState ==
                                    ConnectionState.done) {
                                  UserModel userModel =
                                      userData.data as UserModel;
                                  print(
                                      "Notifications   -->  ${userModel.fullName.toString()}");

                                  // !   This Container will be shown on the Homepage as a chatroom

                                  return InkWell(
                                    splashColor:
                                        appBarColor, // Customize the color when tapped
                                    highlightColor: Colors.transparent,

                                    onTap:
                                        //  notificationModel.sender ==
                                        //         widget.userModel.uid
                                        //     ? null
                                        //     :
                                        () {
                                      print(userModel.sender ??
                                          widget.userModel.uid);
                                      Get.to(() {
                                        return Profile(
                                            endUser: true,
                                            userModel: userModel,
                                            distance:
                                                Random().nextInt(100).toDouble()
                                            // distanceBetween(
                                            //     userLatitude:
                                            //         userModel.latitude!,
                                            //     userLongitude:
                                            //         userModel.longitude!,
                                            //     yourLatitude:
                                            //         widget.userModel.latitude!,
                                            //     yourLongitude: widget
                                            //         .userModel.longitude!)
                                            );
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10.w, right: 10),
                                          child: ListTile(
                                              minVerticalPadding: -100,
                                              // dense: true,

                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      bottom: 0,
                                                      right: 10,
                                                      left: 0),
                                              leading: CircleAvatar(
                                                radius: 30.r,
                                                backgroundColor:
                                                    Colors.grey.shade500,
                                                backgroundImage:
                                                    // AssetImage('assets/emotion/happy.png')
                                                    NetworkImage(userModel
                                                        .profilePicture!),
                                              ),
                                              trailing: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 25.h),
                                                child: Text(
                                                  "Flirty",
                                                  style: GoogleFonts.cinzel(
                                                    fontSize: 12.sp,
                                                    color: appBarColor,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: notificationModel.theme ==
                                                      'Liked'
                                                  ? FittedBox(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      fit: BoxFit.none,
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text: notificationModel
                                                                        .theme ==
                                                                    'Liked'
                                                                ? notificationModel.sender ==
                                                                        widget
                                                                            .userModel
                                                                            .uid
                                                                    ? "You liked\t\t"
                                                                    : "${userModel.fullName} liked you "
                                                                : "You dis-Liked\t\t",
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 14.sp,
                                                                color: notificationModel.sender ==
                                                                        widget
                                                                            .userModel
                                                                            .uid
                                                                    ? Colors
                                                                        .black54
                                                                    : Colors
                                                                        .black54),
                                                            children: [
                                                              TextSpan(
                                                                  text: notificationModel
                                                                              .sender ==
                                                                          widget
                                                                              .userModel
                                                                              .uid
                                                                      ? userModel
                                                                          .fullName
                                                                      : "",
                                                                  style: TextStyle(
                                                                      // fontWeight:
                                                                      //     FontWeight
                                                                      //         .bold,
                                                                      fontStyle: FontStyle.italic,
                                                                      fontSize: 13.sp,
                                                                      color: notificationModel.sender == widget.userModel.uid ? Colors.black54 : Colors.black54)),
                                                              // TextSpan(
                                                              //     text:
                                                              //         "   :   Flirty",
                                                              //     style: TextStyle(
                                                              //         fontWeight:
                                                              //             FontWeight
                                                              //                 .bold,
                                                              //         fontSize:
                                                              //             13.sp,
                                                              //         color: Colors
                                                              //             .black))
                                                            ]),
                                                      ),
                                                    )
                                                  : notificationModel.theme ==
                                                          'Rejected'
                                                      ? FittedBox(
                                                          fit: BoxFit.cover,
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            !notificationModel
                                                                    .sender!
                                                                    .contains(
                                                                        userModel
                                                                            .uid!)
                                                                ? "You Rejected ${widget.userModel.fullName} proposal"
                                                                : "${userModel.fullName} rejected your proposal",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 13.sp,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        )
                                                      : FittedBox(
                                                          fit: BoxFit.none,
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "You both are now matched",
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 13.sp,
                                                                color: Colors
                                                                    .green
                                                                    .shade800),
                                                          ),
                                                        ),
                                              subtitle: Row(
                                                children: [
                                                  Text(
                                                    DateFormat(" hh:mm").format(
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                            notificationModel
                                                                .createdOn!
                                                                .millisecondsSinceEpoch)),
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  Text(
                                                    DateFormat(" , dd MMM yyy")
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                notificationModel
                                                                    .createdOn!
                                                                    .millisecondsSinceEpoch)),
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Divider(
                                            endIndent: 20.w,
                                            indent: 70.w,
                                            height: 0,
                                            thickness: 0.5,
                                            color: Colors.black38)
                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.h),
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4),
                                        subtitle: Container(
                                            height: 3,
                                            color: Colors.white,
                                            width: 50),
                                      ),
                                    ),
                                  );
                                }
                              });
                        }))
                    : Center(
                        child: Image.asset(
                        "assets/no_notification.png",
                        width: size.width * 0.35,
                      ));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    "No Chats Yet",
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                );
              }
            } else {
              return Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: spinkit(color: appBarColor, size: 30.sp),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
// ! End Of Notification Screen