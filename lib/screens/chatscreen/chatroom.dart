// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/chatroom_controller.dart';
import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/message_model.dart';
import '../../models/models.dart';
import '../../pages.dart';
import '../../utils/ad_helper.dart';

class Chatroom extends StatefulWidget {
  const Chatroom(
      {super.key,
      required this.enduser,
      required this.currentUserModel,
      required this.firebaseUser,
      required this.chatRoomModel});

  final ChatRoomModel chatRoomModel;
  final UserModel currentUserModel;
  final UserModel enduser;
  final User firebaseUser;

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final FocusNode _focusNode = FocusNode();

  getTime() {
    var authController = Get.put(FirebaseAuthController());
    // print(widget.userModel.lastActive);
    Timestamp firebaseTimestamp = widget.enduser.lastActive!;

    authController.lastActive.value = firebaseTimestamp;

    print(
        'Time ago: ${authController.getFormattedTimeAgo(lastActive: firebaseTimestamp)}');
  }

  // !  This is Widget in which we will show messages to the user

  Widget messageContainer(
      {required BuildContext context,
      required String? messageText,
      required String? image,
      required String time,
      required String sender}) {
    return Container(
      margin: EdgeInsets.only(
          top: 3.h,
          bottom: 3.h,
          left: sender == 'Client' ? 7.w : 70.w,
          right: sender == 'Client' ? 70.w : 7.w),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: sender == 'Client'
              ? Radius.circular(20.r)
              : Radius.circular(20.r),
          bottomRight:
              sender == 'Client' ? Radius.circular(20.r) : Radius.circular(0.w),
        ),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: sender == 'Client'
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          mainAxisAlignment: sender == 'Client'
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: sender == 'Client'
                          ? Radius.circular(0.w)
                          : Radius.circular(20.r),
                      bottomRight: sender == 'Client'
                          ? Radius.circular(20.r)
                          : Radius.circular(0.w),
                    ),
                    color: messageText == ''
                        ? Colors.transparent
                        : sender == 'Client'
                            ? Colors.green.shade100
                            : Colors.blue.shade100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: sender == 'Client'
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  mainAxisAlignment: sender == 'Client'
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    image != null
                        ? FutureBuilder<void>(
                            future: precacheImage(
                              NetworkImage(
                                image,
                                scale: 0.01,
                              ),
                              context,
                            ),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.r),
                                      topRight: Radius.circular(20.r),
                                    ),
                                  ),
                                  child: Center(
                                    child:
                                        spinkit(color: appBarColor, size: 30.r),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                // Handle the error
                                return const Text('Error loading image');
                              } else {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.r),
                                      topRight: Radius.circular(20.r),
                                      bottomLeft: messageText != ''
                                          ? Radius.circular(0.w)
                                          : Radius.circular(20.r),
                                      bottomRight: messageText != ''
                                          ? Radius.circular(0.r)
                                          : Radius.circular(20.w),
                                    ),
                                  ),
                                );
                              }
                            })
                        : const SizedBox(),
                    Visibility(
                      visible: messageText != '',
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 7.h, horizontal: 15.w),
                        child: Text(messageText.toString()),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 3.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                time,
                style: TextStyle(fontSize: 9.sp, color: Colors.black87),
              ),
            ),
          ]),
    );
  }

  @override
  void initState() {
    initilizeBannerAd();

    super.initState();
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
    UserProvider userProvider = Provider.of<UserProvider>(context);

    Size size = MediaQuery.of(context).size;
    var controller = Get.put(FirebaseAuthController());
    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(50.0),
        //   child: SizedBox(
        //     height: matchScreenBanner.size.height.toDouble(),
        //     width: matchScreenBanner.size.width.toDouble(),
        //     child: AdWidget(ad: matchScreenBanner),
        //   ),
        // ),
        // flexibleSpace: SizedBox(
        //   height: matchScreenBanner.size.height.toDouble(),
        //   width: matchScreenBanner.size.width.toDouble(),
        //   child: AdWidget(ad: matchScreenBanner),
        // ),
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        leadingWidth: 00,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.h),
            child: Center(
              child: PopupMenuButton<String>(
                color: appBarColor,
                constraints: BoxConstraints(
                    minWidth: size.width * 0.3, maxWidth: size.width * 0.6),
                padding: EdgeInsets.zero,
                icon: Transform.rotate(
                  angle: 45 * (3.141592653589793238462 / 90),
                  child: Image.asset(
                    "assets/edit.png",
                    height: 18.sp,
                    color: Colors.white,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'Block User') {
                    controller.unMatch(
                        isBlock: true,
                        opponentModel: widget.enduser,
                        userProvider: userProvider);
                  } else {
                    controller.deleteAllMessages(
                        chatroomId: widget.chatRoomModel.chatroomid!);
                    Get.dialog(
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.2,
                            vertical: size.height * 0.35),
                        decoration: BoxDecoration(
                          color: Colors.transparent.withOpacity(0.3),
                        ),
                        child: Center(
                          child: spinkit(color: Colors.white, size: 35.sp),
                        ),
                      ),
                    );
                  }

                  Get.back();
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      value: 'Block User',
                      child: FittedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.block_flipped,
                              color: Colors.white,
                              size: 18.r,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            const Text(
                              'Block User',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Delete Chat',
                      child: FittedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 18.r,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            const Text(
                              'Delete Chat',
                              style: TextStyle(color: Colors.white),
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
        ],
        title: Row(
          children: [
            CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                }),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Get.to(() {
                  return Profile(
                    endUser: true,
                    userModel: widget.enduser,
                    distance: Random().nextInt(100).toDouble(),
                    //  distanceBetween(
                    //     userLatitude: widget.enduser.latitude!,
                    //     userLongitude: widget.enduser.longitude!,
                    //     yourLatitude: widget.currentUserModel.latitude!,
                    //     yourLongitude: widget.currentUserModel.longitude!)
                  );
                });
              },
              child: CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(widget.enduser.liked!
                        .contains(FirebaseAuth.instance.currentUser!.uid)
                    ? widget.enduser.profilePicture!
                    : "https://i0.wp.com/www.stignatius.co.uk/wp-content/uploads/2020/10/default-user-icon.jpg?fit=415%2C415&ssl=1"),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Get.to(() {
                  return Profile(
                      endUser: true,
                      userModel: widget.enduser,
                      distance: Random().nextInt(100).toDouble()
                      //  distanceBetween(
                      //     userLatitude: widget.enduser.latitude!,
                      //     userLongitude: widget.enduser.longitude!,
                      //     yourLatitude: widget.currentUserModel.latitude!,
                      //     yourLongitude: widget.currentUserModel.longitude!)
                      );
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.enduser.fullName!,
                    style: GoogleFonts.cinzel(
                      fontSize: 16.sp,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontWeight: FontWeight.bold,
                      decorationColor: Colors.black,
                      // backgroundColor: Colors.grey.shade100,
                      color: Colors.white,
                    ),
                  ),
                  Visibility(
                    visible: widget.enduser.liked!
                            .contains(FirebaseAuth.instance.currentUser!.uid) ||
                        widget.currentUserModel.liked!
                            .contains(widget.enduser.uid),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/active_dot.png",
                          height: 10.h,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          controller.getFormattedTimeAgo(
                              lastActive: widget.enduser.lastActive!),
                          style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10.sp),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .where("users",
                          arrayContains: widget.currentUserModel.uid)
                      .orderBy("updatedOn", descending: true)
                      .snapshots(),
                  builder: ((context, snapshot) {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("chatrooms")
                            .doc(widget.chatRoomModel.chatroomid)
                            .collection("messages")
                            .orderBy("createdOn", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData) {
                              QuerySnapshot dataSnapshot =
                                  snapshot.data as QuerySnapshot;
                              return dataSnapshot.docs.isNotEmpty
                                  ? ListView.builder(
                                      reverse: true,
                                      itemCount: dataSnapshot.docs.length,
                                      itemBuilder: ((context, index) {
                                        MessageModel currentMessage =
                                            MessageModel.fromMap(
                                                dataSnapshot.docs[index].data()
                                                    as Map<String, dynamic>);

                                        String messgaeDate = DateFormat(
                                                "EEE,dd MMM   hh:mm a")
                                            .format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    currentMessage.createdOn!
                                                        .millisecondsSinceEpoch));

                                        // currentMessage.sender == currentUserModel.uid
                                        //     ? spinkit(color: Colors.blue)
                                        //     :
                                        return Column(
                                          crossAxisAlignment: currentMessage
                                                      .sender ==
                                                  widget.currentUserModel.uid
                                                      .toString()
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          mainAxisAlignment: currentMessage
                                                      .sender ==
                                                  widget.currentUserModel.uid
                                                      .toString()
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          children: [
                                            messageContainer(
                                                context: context,
                                                image: currentMessage.image !=
                                                        ""
                                                    ? currentMessage.image
                                                    : null,
                                                messageText:
                                                    currentMessage.text == ""
                                                        ? ""
                                                        : currentMessage.text
                                                            .toString(),
                                                sender: currentMessage.sender ==
                                                        widget.currentUserModel
                                                            .uid
                                                    ? 'Advocate'
                                                    : 'Client',
                                                time: messgaeDate),
                                          ],
                                        );
                                      }))
                                  : const Center(
                                      child: Text("No messages yet"),
                                    );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text("Internet Issue"),
                              );
                            } else {
                              return const Center(
                                child: Text("Say hi! to start a conversation"),
                              );
                            }
                          } else {
                            return Center(
                              child: spinkit(color: appBarColor, size: 30),
                            );
                          }
                        });
                  })),
            ),
            widget.enduser.liked!.contains(widget.currentUserModel.uid) ||
                    controller.rewardedFreeMessages.value > 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                        color: appBarColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    // color: Colors.blue,
                    child: Row(
                      children: [
                        CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 16.r,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white70,
                                  size: 18.r,
                                )),
                            onPressed: () {
                              // sendMessage();

                              // provider.randomNameChanger(value: provider.randomName + 1);
                              // randomName = provider.randomName;
                              // setState(() {});
                              Get.find<FirebaseAuthController>()
                                  .showPhotoOption(
                                      context: context,
                                      chatRoomModel: widget.chatRoomModel,
                                      currentUserModel: widget.currentUserModel,
                                      endUserModel: widget.enduser,
                                      isChat: true);
                            }),
                        Flexible(
                            child: TextFormField(
                          controller: Get.find<ChatroomController>()
                              .messageController
                              .value,
                          focusNode: _focusNode,
                          // enabled: false,
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black87),
                          cursorColor: Colors.black87,
                          maxLines: 2,
                          minLines: 1,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 15.w, right: 10.w),
                              hintText: "Type a messgae ...".tr,
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none),
                        )),
                        CupertinoButton(
                            child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 18.r,
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18.r,
                                )),
                            onPressed: () {
                              if (!widget.enduser.liked!
                                      .contains(widget.currentUserModel.uid) &&
                                  controller.rewardedFreeMessages.value > 0) {
                                controller.rewardedFreeMessages.value--;
                                var chatroomController =
                                    Get.find<ChatroomController>();
                                _focusNode.unfocus();
                                chatroomController.sendMessage(
                                    currentUserModel: widget.currentUserModel,
                                    endUserModel: widget.enduser,
                                    msg: chatroomController
                                        .messageController.value.text,
                                    chatRoomModel: widget.chatRoomModel);
                                // sendMessage(
                                //     msg: messageController.text.trim(),
                                //     emotion: widget.currentUserModel.sendEmotion!
                                //         ? widget.modeProvider.mode
                                //         : null);
                                // widget.modeProvider.emotionList.clear();
                                // _focusNode.unfocus();
                              } else {
                                var chatroomController =
                                    Get.find<ChatroomController>();
                                _focusNode.unfocus();
                                chatroomController.sendMessage(
                                    currentUserModel: widget.currentUserModel,
                                    endUserModel: widget.enduser,
                                    msg: chatroomController
                                        .messageController.value.text,
                                    chatRoomModel: widget.chatRoomModel);
                                // sendMessage(
                                //     msg: messageController.text.trim(),
                                //     emotion: widget.currentUserModel.sendEmotion!
                                //         ? widget.modeProvider.mode
                                //         : null);
                                // widget.modeProvider.emotionList.clear();
                                // _focusNode.unfocus();
                              }
                            })
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      children: [
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                        const Text(
                            "You Can't reply to this Conversation any more!"),
                      ],
                    ),
                  ),
            SizedBox(
              height: 20,
              width: matchScreenBanner.size.width.toDouble(),
              child: AdWidget(ad: matchScreenBanner),
            ),
          ],
        ),
      ),
    );
  }
}
