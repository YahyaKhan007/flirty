// ~ Start of Chat Screen

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/constants/ui_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../utils/ad_helper.dart';
import '../widgets/widgets.dart';
import 'chatroom.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userModel;

  const ChatScreen({super.key, required this.userModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late UserProvider userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    initilizeBannerAd();
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.userModel!.uid)
        .update({'lastActive': Timestamp.now()});
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: chatScreenBanner.size.height.toDouble(),
        width: chatScreenBanner.size.width.toDouble(),
        child: AdWidget(ad: chatScreenBanner),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("users", arrayContains: userProvider.userModel!.uid)
              .orderBy("updatedOn", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // !   *************************

                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return chatRoomSnapshot.docs.isNotEmpty
                    ? ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          // ! we also need a target user model in Order to show the detail of the target user on the HomePage

                          Map<String, dynamic> chatrooms =
                              chatRoomModel.participants!;

                          List<String> participantKey = chatrooms.keys.toList();

                          participantKey.remove(userProvider.userModel!.uid);

                          return FutureBuilder(
                              future: FirebaseHelper.getClientModelById(
                                participantKey[0],
                              ),
                              builder: (context, userData) {
                                if (userData.hasData) {
                                  final endUser = userData.data;
                                  return GestureDetector(
                                      // onLongPress: () {
                                      //   // Get.find<FirebaseAuthController>()
                                      //   //     .deleteChatroom(
                                      //   //         chatroomId:
                                      //   //             chatRoomModel.chatroomid!);
                                      //   Get.dialog(
                                      //     Container(
                                      //       margin: EdgeInsets.symmetric(
                                      //           horizontal: size.width * 0.2,
                                      //           vertical: size.height * 0.35),
                                      //       decoration: BoxDecoration(
                                      //         color: Colors.transparent
                                      //             .withOpacity(0.3),
                                      //       ),
                                      //       child: Center(
                                      //         child: spinkit(
                                      //             color: Colors.white,
                                      //             size: 35.sp),
                                      //       ),
                                      //     ),
                                      //   );
                                      // },
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Get.to(() => Chatroom(
                                              enduser: endUser,
                                              firebaseUser: FirebaseAuth
                                                  .instance.currentUser!,
                                              chatRoomModel: chatRoomModel,
                                              currentUserModel:
                                                  widget.userModel));
                                        },
                                        leading: CircleAvatar(
                                          radius: 23.r,
                                          backgroundColor: Colors.grey.shade500,
                                          backgroundImage:
                                              // AssetImage('assets/emotion/happy.png')

                                              NetworkImage(endUser!.liked!
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                  ? endUser.profilePicture!
                                                  : "https://i0.wp.com/www.stignatius.co.uk/wp-content/uploads/2020/10/default-user-icon.jpg?fit=415%2C415&ssl=1"),
                                        ),
                                        title: Text(
                                          endUser.fullName!,
                                          overflow: TextOverflow.fade,
                                          style: GoogleFonts.cinzel(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chatRoomModel.lastMessage != ""
                                                  ? chatRoomModel.lastMessage!
                                                              .length <=
                                                          25
                                                      ? chatRoomModel
                                                          .lastMessage!
                                                          .replaceAll('\n', ' ')
                                                      : '${chatRoomModel.lastMessage!.substring(0, 25).replaceAll('\n', ' ')}...'
                                                  : "Say hi! to start conversation",
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.roboto(
                                                fontSize:
                                                    chatRoomModel.lastMessage !=
                                                            ""
                                                        ? 12.sp
                                                        : 11.sp,
                                                fontStyle: FontStyle.italic,
                                                // fontStyle: FontStyle.italic,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                                fontWeight: FontWeight.normal,

                                                // backgroundColor: Colors.grey.shade100,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            // Text(
                                            //   "  ,  ",
                                            //   style: TextStyle(
                                            //       color: Colors.black,
                                            //       fontSize: 10.sp),
                                            // ),
                                            Text(
                                              DateFormat(" hh:mm  , dd MMM")
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          chatRoomModel
                                                              .updatedOn!
                                                              .millisecondsSinceEpoch)),
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontStyle: FontStyle.italic,
                                                  color: appBarColor),
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
                                        // : const CircleAvatar(
                                        //     backgroundColor: Colors.blue,
                                        //     radius: 7,
                                        //   ),
                                      ),
                                      Divider(
                                          endIndent: 20.w,
                                          indent: 70.w,
                                          height: 0,
                                          thickness: 0.5,
                                          color: Colors.black38)
                                    ],
                                  ));
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

                                //  AdvocateModel userModel =
                                //                     userData.data as AdvocateModel;
                                // AdvocateModel advocateModel =
                                //     userData.data as AdvocateModel;
                              });
                        })
                    : Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/noMessageTransparent_icon.png',
                            width: size.width * 0.4,
                            color: appBarColor,
                          ),
                          Image.asset(
                            'assets/noMessageTransparent.png',
                            width: size.width * 0.6,
                          ),
                        ],
                      ));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                );
              } else {
                Center(
                    child: Image.asset(
                  'assets/noMessageTransparent.png',
                  width: size.width * 0.1,
                ));
              }
            } else {
              return spinkit(color: Colors.blue, size: 30);
            }
            return Center(
                child: Image.asset('assets/noMessageTransparent.png'));
          },
        ),
      ),
    );
  }
}
// !End of Chat Screen