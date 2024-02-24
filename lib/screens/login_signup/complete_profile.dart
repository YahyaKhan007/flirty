import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../controllers/constants/ui_constants.dart';

import '../../controllers/controllers.dart';
import '../../models/models.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../utils/ad_helper.dart';
import '../widgets/interest_selection.dart';
import '../widgets/widgets.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.isEdit});

  final UserModel? userModel;
  final bool isEdit;
  final User? firebaseUser;

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

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

class _CompleteProfileState extends State<CompleteProfile> {
  final _formkey = GlobalKey<FormState>();

  FocusNode fullName = FocusNode();
  FocusNode bio = FocusNode();
  FocusNode city = FocusNode();
  FocusNode country = FocusNode();

  late FirebaseAuthController firebaseController;

  late bool editing;
  late TextEditingController fullNameController;
  late TextEditingController bioController;
  late TextEditingController cityController;
  late TextEditingController countryController;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.

// ! Location feature which is currently disable
  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   var position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   firebaseController.latitude.value = position.latitude;
  //   firebaseController.longitude.value = position.longitude;
  //   log(position.latitude.toString());
  //   log(position.longitude.toString());

  //   log("Fire base latitude  --- ?? ${firebaseController.latitude.toString()}");
  //   log("Fire base longitude  --- ??  ${firebaseController.longitude.toString()}");

  //   firebaseController.city.value = await getCityNameFromCoordinates(
  //     latitude: firebaseController.latitude.value,
  //     longitude: firebaseController.longitude.value,
  //   );

  //   log("The city is   --- ? ${firebaseController.city.value}");

  //   return position;
  // }

  // late Completer<void> locationCompleter;

  Future<File> downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/$filename');
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  changeImage({required String address}) async {
    // Assuming imageUrl is the URL of your network image
    firebaseController.image.value = await downloadFile(address, "image.jpg");
  }

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    widget.isEdit ? loadAppOpenAd() : null;

    firebaseController = Get.find();
    fullNameController = TextEditingController();
    bioController = TextEditingController();
    countryController = TextEditingController();
    cityController = TextEditingController();
    if (widget.isEdit) {
      firebaseController.selectGender.value = widget.userModel!.gender!;
      firebaseController.selectInterest.value = widget.userModel!.interestedIn!;
      firebaseController.age.value = widget.userModel!.age!;
      // firebaseController.city.value = widget.userModel!.city!;
      // firebaseController.country.value = widget.userModel!.country!;

      changeImage(address: widget.userModel!.profilePicture!);
    }
    fullNameController.text = widget.isEdit ? widget.userModel!.fullName! : '';
    bioController.text = widget.isEdit ? widget.userModel!.bio! : '';
    countryController.text = widget.isEdit ? widget.userModel!.country! : '';
    cityController.text = widget.isEdit ? widget.userModel!.city! : '';
    // firebaseController.showValue();
    getToken();

    super.initState();

    // locationCompleter = Completer<void>();
    // _determinePosition().then((value) => {
    //       firebaseController.latitude.value = value.latitude,
    //       firebaseController.longitude.value = value.longitude,
    //       log(value.latitude.toString()),
    //       log(value.longitude.toString())
    //     });
  }

  static Future<void> getToken() async {
    try {
      await messaging.requestPermission();

      await messaging.getToken().then((t) {
        if (t != null) {
          Get.find<FirebaseAuthController>().pushToken.value = t;
          log("Push Token ----->   $t");
        }
      });
    } catch (e) {
      log("$e");
    }

    // log("Push Token ----->   $messaging.getToken()");
  }

  @override
  Widget build(BuildContext context) {
    if(bioController.text.isEmpty){
      bioController.text = 'Hello there I am Using Flirty !';
    }
    Size size = MediaQuery.of(context).size;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      // backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios_new))),
      body: Obx(
        () => InkWell(
          onTap: () {
            fullName.unfocus();
            bio.unfocus();
            country.unfocus();
            city.unfocus();
          },
          child: Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/back_design.png'),
                    fit: BoxFit.cover)),
            child: Form(
                key: _formkey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        // gradient: const LinearGradient(
                        //   colors: [Color(0xFFEE4D7E), Color(0xFFFF6A7F)],
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        // ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.r),
                          bottomRight: Radius.circular(25.r),
                        ),
                      ),
                      height: size.height * 0.22,
                      width: size.width,
                      child: CupertinoButton(
                          onPressed: () {
                            // provider.changeLoading(value: false);

                            // showPhotoOption();
                            firebaseController.showPhotoOption(
                                context: context,
                                chatRoomModel: null,
                                currentUserModel: widget.userModel,
                                endUserModel: null,
                                isChat: false);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // boxShadow: [avatarShadow]
                            ),
                            child: CircleAvatar(
                              backgroundColor: appBarColor,
                              radius: 65.r,
                              backgroundImage: (firebaseController
                                          .image.value !=
                                      null)
                                  ? FileImage(firebaseController.image.value!)
                                  : null,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 80.r,
                                    backgroundColor: Colors.transparent,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 50.r,
                                      child: (firebaseController.image.value ==
                                              null)
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 85.r,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                      top: 10,
                                      right: 10,
                                      child: CircleAvatar(
                                        radius: 13.r,
                                        backgroundColor: Colors.black,
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: Colors.white,
                                          size: 13.r,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: size.width,
                      height: 45.h,
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        // boxShadow: [shadow],
                        border: Border.all(color: Colors.black),
                        // color: Colors.pink.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        child: TextFormField(
                          focusNode: fullName,
                          controller: fullNameController,
                          cursorColor: Colors.black,
                          cursorHeight: 17.sp,
                          validator: (value) {
                            if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value!)) {
                              return "Enter Correct Name";
                            } else {
                              return null;
                            }
                          },
                          // controller: ,
                          style:
                              TextStyle(color: Colors.black, fontSize: 12.sp),
                          decoration: InputDecoration(
                            hintText: 'Full Name'.tr,
                            hintStyle: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                            // label: Text(
                            //   'Email',
                            //   style: TextStyle(
                            //       color: Colors.black, fontSize: 13.sp),
                            // ),
                            border: InputBorder.none,
                            // enabledBorder: kTextFieldBorder,
                            // focusedBorder: kTextFieldBorder
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Row(
                        children: [
                          Expanded(
                            // decoration: BoxDecoration(
                            //   boxShadow: [shadow],
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                  // color: Colors.pink.shade100,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                focusNode: bio,
                                controller: bioController,
                                cursorColor: Colors.black,
                                cursorHeight: 17.sp,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 13.sp),
                                maxLines: 10,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Something About Your self'.tr,
                                  hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic),
                                  // label: Text(
                                  //   'Email',
                                  //   style: TextStyle(
                                  //       color: Colors.black, fontSize: 13.sp),
                                  // ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.pink.shade200),
                                  ),
                                  // Add focused underline border
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    FittedBox(
                      child: Container(
                        height: 45.h,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            // color: Colors.pink.shade200,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Select Gender",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                              genderSelection(
                                  size: size,
                                  context: context,
                                  firebaseAuthController: firebaseController),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    FittedBox(
                      child: Container(
                        height: 45.h,
                        width: size.width,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                          // gradient: const LinearGradient(
                          //   colors: [Color(0xFFEE4D7E), Color(0xFFFF6A7F)],
                          //   begin: Alignment.topCenter,
                          //   end: Alignment.bottomCenter,
                          // ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "How Old are you ",
                              style: TextStyle(
                                  fontSize: 13.sp, fontWeight: FontWeight.bold),
                            ),
                            DropdownButton<int>(
                              menuMaxHeight: size.height * 0.4,
                              dropdownColor: appBarColor,
                              borderRadius: BorderRadius.circular(10),
                              value: firebaseController.age.value,
                              items: List<DropdownMenuItem<int>>.generate(
                                45,
                                (index) => DropdownMenuItem<int>(
                                  value: 18 + index,
                                  child: Text((18 + index).toString()),
                                ),
                              ),
                              onChanged: (value) {
                                firebaseController.age.value = value!;
                                log("YOu are ${firebaseController.age.value} Old");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    FittedBox(
                      child: Container(
                        height: 45.h,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            // color: Colors.pink.shade200,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Interested In",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                              interestSelection(
                                  size: size,
                                  context: context,
                                  firebaseAuthController: firebaseController),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Row(
                        children: [
                          Expanded(
                            // decoration: BoxDecoration(
                            //   boxShadow: [shadow],
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                  // color: Colors.pink.shade100,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                focusNode: city,
                                controller: cityController,
                                cursorColor: Colors.black,
                                cursorHeight: 17.sp,
                                style: TextStyle(
                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 13.sp),
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'City Name',
                                  hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic),
                                  // label: Text(
                                  //   'Email',
                                  //   style: TextStyle(
                                  //       color: Colors.black, fontSize: 13.sp),
                                  // ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.pink.shade200),
                                  ),
                                  // Add focused underline border
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Row(
                        children: [
                          Expanded(
                            // decoration: BoxDecoration(
                            //   boxShadow: [shadow],
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                  // color: Colors.pink.shade100,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                focusNode: country,
                                controller: countryController,
                                cursorColor: Colors.black,
                                cursorHeight: 17.sp,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 13.sp),
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Country Name',
                                  hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic),
                                  // label: Text(
                                  //   'Email',
                                  //   style: TextStyle(
                                  //       color: Colors.black, fontSize: 13.sp),
                                  // ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.pink.shade200),
                                  ),
                                  // Add focused underline border
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    firebaseController.isLoading.value
                        ? spinkit(color: appBarColor, size: 30.0)
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.2),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                // log(firebaseController.city.value);

                                // if (firebaseController.city.value == '') {
                                //   Get.showSnackbar(const GetSnackBar(
                                //     snackPosition: SnackPosition.TOP,
                                //     backgroundColor: Colors.red,
                                //     animationDuration: Duration(seconds: 2),
                                //     titleText: Text(
                                //       'Location not Picked',
                                //       style: TextStyle(color: Colors.white),
                                //     ),
                                //     messageText: Text(
                                //       "You cannot create your profile untill the location is picked",
                                //       style: TextStyle(color: Colors.white),
                                //     ),
                                //   ));
                                // } else {
                                firebaseController.checkValues(
                                    context: context,
                                    userModel: widget.userModel,
                                    userProvider: userProvider,
                                    fullName: fullNameController.text,
                                    bio: bioController.text,
                                    city: cityController.text,
                                    country: countryController.text);
                                // }
                              },
                              child: Container(
                                height: 55.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: buttonGradient),
                                child: Center(
                                    child: Text(
                                  "Finish",
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
                      height: 20.h,
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
