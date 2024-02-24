// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../pages.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../screens/login_signup/login_with_mobile.dart';
import 'chatroom_controller.dart';
import 'constants/ui_constants.dart';
import 'controllers.dart';
import 'firebase_api.dart';

class FirebaseAuthController extends GetxController {
  // ~ variables

  // UserProvider userProvider = Provider.of<UserProvider>(context);
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  var rewardedFreeMessages = 0.obs;

  var isChatOpen = false.obs;
  var selectedIndex = 0.obs;

  var isLoading = false.obs;
  var likeLoading = false.obs;
  final Rx<File?> image = Rx<File?>(null);
  var latitude = 0.01.obs;
  var longitude = 0.01.obs;
  var city = "".obs;
  var pushToken = "".obs;
  var country = "".obs;
  var age = 18.obs;
  var showShimmer = true.obs;
  var opacity = 0.1.obs;

  Rx<Timestamp?> lastActive = Rx<Timestamp?>(null);

  var showPassword = true.obs;

  changeShowPassword({required bool value}) {
    showPassword.value = value;
  }

  // ! *************************************************
  // ! *************************************************

  //!  Gender Selection
  // ~ Gender Type
  var genderTypes = [
    'Male',
    'Female',
  ].obs;

  RxString selectGender = 'Male'.obs;

  changeGender({required String gender}) {
    selectGender.value = gender;
    update();
  }

//!  Gender Selection
  // ~ Gender Type
  var interestTypes = ['Male', 'Female', 'Both'].obs;

  RxString selectInterest = 'Both'.obs;

  changeInterest({required String gender}) {
    selectInterest.value = gender;
    update();
  }

  // ! *************************************************
  restoreToDefault() {
    isChatOpen = false.obs;
    isLoading = false.obs;
    likeLoading = false.obs;
    image.value = null;
    latitude = 0.01.obs;
    longitude = 0.01.obs;
    city = "".obs;
    pushToken = "".obs;
    country = "".obs;
    age = 18.obs;
  }
  // ! *************************************************

  // ~ user Model object
  var userModel = UserModel(
      age: 0,
      latitude: 0.01,
      longitude: 0.01,
      uid: null,
      fullName: "",
      email: "",
      bio: "",
      memberSince: Timestamp.now(),
      // accountType: "",
      pushToken: "",
      isVarified: false,
      profilePicture: "",
      gender: '',
      liked: [],
      interestedIn: 'Female',
      city: '',
      sender: [],
      reciever: [],
      country: '',
      premium: false,
      notifications: 0,
      lastActive: Timestamp.now(),
      photos: [],
      blockedUsers: []).obs;

  // ~ update user function
  updateUser({required UserModel newUser}) {
    try {
      log("Email of the new User ${newUser.email}");
      userModel.value = newUser; //
      update();
      //  Set the clientModel here
      if (userModel.value.email != "") {
        log("Client Model not Empty ---->  ${userModel.value.email.toString()}");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  getToken() async {
    try {
      await messaging.requestPermission();

      await messaging.getToken().then((t) {
        if (t != null) {
          pushToken.value = t;
          log("Push Token ----->   $t");
        }
      });
    } catch (e) {
      log("$e");
    }

    // log("Push Token ----->   $messaging.getToken()");
  }

// ~ Signup with Google

  anonymous() async {
    log('1');
    await FirebaseAuth.instance.signInAnonymously();
    log('2');
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ], hostedDomain: 'gmail.com');

  signInWithGoogle({required UserProvider userProvider}) async {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            height: 60,
            width: 60,
            color: Colors.transparent,
            child: spinkit(color: appBarColor, size: 40.sp),
          ),
        ),
        barrierDismissible: false,
      );
      log('1');

      // Check if there's already a signed-in user
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        // User is already signed in, handle the sign-in process accordingly
        log("User is already signed in");
        final GoogleSignInAuthentication googleAuth =
            await currentUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        log('2');
        User? user = userCredential.user;

        if (user != null) {
          Get.back();
          log(user.uid);
          UserModel? tempUser =
              await FirebaseHelper.getClientModelById(user.uid);
          userProvider.updateUser(tempUser);
          log('\n\n\n\n\t\t\t\t====================\t\t\t${userProvider.userModel!.uid}\n\n\n\t\t\t\t\t==================');
          log('Done');
          Get.to(() => HomePage(userModel: userProvider.userModel!));
        }
      } else {
        getToken();
        // User is not signed in, proceed with sign-in
        log("User is not signed in");
        _googleSignIn.disconnect(); // Clear cached credentials
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        log('2');
        if (googleUser == null) {
          log("null");
          throw Exception('googleUser is null');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        log('3');

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        log('4');

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        log('5');
        User? user = userCredential.user;

        if (user != null) {
          if (userCredential.additionalUserInfo!.isNewUser) {
            UserModel tempUserModel = UserModel(
                uid: user.uid,
                lastActive: Timestamp.now(),
                photos: [user.photoURL],
                premium: false,
                country: 'Unknown',
                fullName: user.displayName,
                age: 18,
                city: 'Unknown',
                interestedIn: interestTypes[2].toString(),
                latitude: 0.0,
                longitude: 0.0,
                email: user.email,
                bio: 'Hello there I am Using Flirty !',
                gender: genderTypes[0].toString(),
                sender: [],
                reciever: [],
                liked: [],
                memberSince: Timestamp.now(),
                notifications: 0,
                pushToken: pushToken.value,
                isVarified: false,
                profilePicture: user.photoURL,
                blockedUsers: []);

            FirebaseFirestore.instance
                .collection('users')
                .doc(tempUserModel.uid)
                .set(tempUserModel.toMap())
                // .then((value) => Get.back())
                .then((value) => userProvider.updateUser(tempUserModel))
                .then((value) => Get.offAll(() => CompleteProfile(
                    isEdit: false,
                    firebaseUser: user,
                    userModel: userProvider.userModel!)))
                .then((value) => Get.showSnackbar(
                      GetSnackBar(
                        backgroundColor: Colors.green,
                        icon: Icon(
                          Icons.check,
                          size: 25.r,
                        ),
                        titleText: Text(
                          'Logged With Google',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        messageText: Text(
                          'Please Go to your Profile, and update your preferences',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ));

            log('6');
          } else {
            log("Not New User");

            UserModel? tempUser =
                await FirebaseHelper.getClientModelById(user.uid);

            userProvider.updateUser(tempUser);

            print(tempUser);
            print(tempUser!.email);
            print(tempUser.age);
            print(tempUser.blockedUsers);
            print(tempUser.interestedIn);
            print(tempUser.lastActive);

            Get.offAll(() => HomePage(userModel: tempUser))!
                .then((value) => log('Done'));
          }
        }
      }
      Get.back();
    } catch (error) {
      Get.back();
      log(error.toString());
    }
  }

// ~ Signup user
  signupUser({
    required String email,
    required String password,
    required String accountType,
    required UserProvider userProvider,
  }) async {
    try {
      isLoading.value = true;
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.toLowerCase(), password: password.toString());

      String uid = credential.user!.uid;

      UserModel newUser = UserModel(
          age: age.value,
          interestedIn: 'Female',
          latitude: latitude.value,
          longitude: longitude.value,
          // gender: selectGender.value,
          gender: '',
          uid: uid,
          fullName: "",
          email: email,
          profilePicture: "",
          // accountType: "Client User",
          bio: "",
          pushToken: "",
          memberSince: Timestamp.now(),
          isVarified: true,
          liked: [],
          city: '',
          sender: [],
          reciever: [],
          country: '',
          premium: false,
          notifications: 0,
          lastActive: Timestamp.now(),
          photos: [],
          blockedUsers: []);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(
            newUser.toMap(),
          )
          .then((value) => updateUser(newUser: newUser))
          .then((value) => userProvider.updateUser(newUser))
          .then((value) => userProvider.updateFirebaseUser(
                FirebaseAuth.instance.currentUser!,
              ))
          .then((value) => isLoading.value = false)
          .then(
            (value) => Get.offAll(
                () => CompleteProfile(
                      isEdit: false,
                      firebaseUser: FirebaseAuth.instance.currentUser!,
                      userModel: newUser,
                    ),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500)),
          );
    } on FirebaseException catch (e) {
      isLoading.value = false;

      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 6),
        message: e.toString(),
      ));
    }
  }

// ~  User Signout Function
  var showDialog = false.obs;
  signoutUser() async {
    showDialog.value = true;

    await FirebaseAuth.instance.signOut().then((value) => Get.back());
    isLoading.value = false;

    Get.offAll(() => LoginPage());

    Get.snackbar(
      "Sign Out".tr,
      "User has been SignOut!".tr,
    );
    // Get.showSnackbar(const GetSnackBar(
    //   title: "Sign Out",
    //   message: "User has been SignOut!",
    //   duration: Duration(seconds: 1),
    //   snackPosition: SnackPosition.TOP,
    // ));
    // "Sign Out", "User has been SignOut!"));
  }

  // ~ Login Function
  loginUser({
    required String email,
    required String password,
    required UserProvider userProvider,
  }) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.toString(), password: password.toString());

      String uid = userCredential.user!.uid;

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);

        userProvider.updateUser(userModel);
        userProvider.updateFirebaseUser(currentUser);

        Get.showSnackbar(GetSnackBar(
          message: "User Logged in".tr,
          duration: const Duration(seconds: 1),
        ));

        Get.offAll(() => HomePage(userModel: userModel),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 500));
      }
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 1),
          message: 'Resolve the Issue'.tr,
        ),
      );
      return false;
    }
  }

// ! Complete Profile
  // ~ Check Values
  void checkValues({
    required BuildContext context,
    required UserModel? userModel,
    required UserProvider userProvider,
    required String fullName,
    required String bio,
    required String city,
    required String country,
  }) {
    if (fullName == "" ||
            image.value == null ||
            bio == "" ||
            city == '' ||
            country == ''
        // ||
        // token == ""
        ) {
      Get.snackbar("Missing Fields".tr, "Entered all the data".tr);
    } else {
      uploadProfileData(
          city: city,
          country: country,
          userModel: userModel,
          userProvider: userProvider,
          image: image.value!,
          context: context,
          name: fullName,
          age: age.value,
          bio: bio);
    }
  }

  // ~ Upload Data
  uploadProfileData(
      {required UserModel? userModel,
      required UserProvider userProvider,
      required String name,
      required String bio,
      required String city,
      required String country,
      required int age,
      required File image,
      required BuildContext context}) async {
    try {
      isLoading.value = true;
      update();

// !  **************************8
// ^ for Client
      if (userModel != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("profilePictures")
            .child(userModel.uid.toString())
            .putFile(image);

        TaskSnapshot snapshot = await uploadTask;

        // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
        String imageUrl = await snapshot.ref.getDownloadURL();

        userModel.fullName = name.toString();

        userModel.bio = bio.toString();
        userModel.profilePicture = imageUrl;
        userModel.pushToken = pushToken.value;
        userModel.interestedIn = selectInterest.value;
        userModel.gender = selectGender.value;
        userModel.latitude = latitude.value;
        userModel.longitude = longitude.value;
        userModel.city = city;
        userModel.age = age;
        userModel.country = country;

        print('check 1');

        if (userModel.photos!.isEmpty) {
          userModel.photos!.add(imageUrl);
        } else if (userModel.photos!.isNotEmpty) {
          userModel.photos![0] = imageUrl;
        }
        print('check 2');

        // userModel.userModel.accountType = "Client";
        // widget.userModel.pushToken = token!;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel.uid!)
            .set(userModel.toMap())
            .then((value) => userProvider.updateUser(userModel))
            .then((value) => userProvider
                .updateFirebaseUser(FirebaseAuth.instance.currentUser!))
            .then((value) => isLoading.value = false)
            .then((value) => Get.offAll(
                  () => HomePage(
                    userModel: userProvider.userModel!,
                  ),
                ));
      }
      isLoading.value = false;
      update();
      Get.snackbar(
          "Profile Created".tr, "Profile has been Successfully created".tr);
    } catch (e) {
      isLoading.value = false;

      Get.snackbar("Error", "what is this  ===>  $e");
    }
  }

// ! End Complete Profile

  // ! login with Mobile phone
  loginWithMobilePhone({required String mobileNumber}) async {
    try {
      isLoading.value = true;
      var auth = FirebaseAuth.instance;
      auth.verifyPhoneNumber(
          phoneNumber: mobileNumber,
          verificationCompleted: (_) {
            isLoading.value = false;
          },
          verificationFailed: (e) {
            isLoading.value = false;

            Get.snackbar('Error', e.toString());
          },
          codeSent: (String varificationId, int? token) {
            isLoading.value = false;
            Get.to(() => VarifyNumber(
                  varificationId: varificationId,
                ));
          },
          codeAutoRetrievalTimeout: (e) {
            isLoading.value = false;

            Get.snackbar(
                'Timed Out', 'Time out for the OTP, generate a new One');
          });
    } catch (e) {
      isLoading.value = false;

      Get.snackbar('Error', e.toString());
    }
  }

  // ! varify phone number
  varifyPhoneNumber(
      {required String varificationId, required String code}) async {
    try {
      isLoading.value = true;
      var auth = FirebaseAuth.instance;

      var credential = PhoneAuthProvider.credential(
          verificationId: varificationId, smsCode: code);

      await auth.signInWithPhoneNumber(credential.toString());

      Get.off(() => CompleteProfile(
            userModel: null,
            firebaseUser: FirebaseAuth.instance.currentUser,
            isEdit: false,
          ));
    } catch (e) {
      print(e);
    }
  }

  // * *********************************************************

  // ^ showPhotoOption
  showPhotoOption(
      {required BuildContext context,
      required bool isChat,
      required UserModel? endUserModel,
      required UserModel? currentUserModel,
      required ChatRoomModel? chatRoomModel}) {
    Get.defaultDialog(
      backgroundColor: appBarColor,
      title: "Choose Photo".tr,
      titleStyle: GoogleFonts.blackOpsOne(
        fontSize: 20.sp,

        // textStyle: Theme.of(context).textTheme.bodyMedium,
        decorationColor: Colors.white,

        // backgroundColor: Colors.grey.shade100,
        color: Colors.white,
      ),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          onTap: () {
            selectImage(
                context: context,
                currentUserModel: currentUserModel,
                endUserModel: endUserModel,
                chatRoomModel: chatRoomModel,
                isChat: isChat,
                imageSource: ImageSource.gallery);
            Get.back();
          },
          title: Text(
            "Select from Gallery".tr,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: const Icon(
            Icons.photo_album,
            color: Colors.white,
          ),
        ),
        ListTile(
          onTap: () {
            selectImage(
                context: context,
                currentUserModel: currentUserModel,
                endUserModel: endUserModel,
                chatRoomModel: chatRoomModel,
                isChat: isChat,
                imageSource: ImageSource.camera);

            Get.back();
          },
          title: Text(
            "Take a Photo".tr,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          leading: const Icon(
            Icons.camera,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }

  // ^ Select Image
  selectImage(
      {required BuildContext context,
      required UserModel? endUserModel,
      required UserModel? currentUserModel,
      required ChatRoomModel? chatRoomModel,
      required bool isChat,
      required ImageSource imageSource}) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: imageSource);
    if (pickedFile != null) {
      var img = File(pickedFile.path);
      image.value = await compressImage(img);
      update();

      if (isChat && currentUserModel != null) {
        sendPhoto(
            context: context,
            endUserModel: endUserModel,
            currentUserModel: currentUserModel,
            chatRoomModel: chatRoomModel);
      }
      log('Picture has been taken');
      // ! we are cropping the image now
      // cropImage(pickedFile);
    }
  }

  // ! Compress the image
  Future<File?> compressImage(File imageFile) async {
    try {
      // Read the image file
      List<int> imageBytes = await imageFile.readAsBytes();
      img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

      // Compress the image with a quality factor (0 to 100)
      img.Image compressedImage = img.copyResize(image, width: 500);

      // Save the compressed image to a new file
      File compressedFile =
          File(imageFile.path.replaceAll('.jpg', '_compressed.jpg'));
      compressedFile
          .writeAsBytesSync(Uint8List.fromList(img.encodeJpg(compressedImage)));
      log("this is a compressed image $compressedFile");
      return compressedFile;
    } catch (e) {
      Get.snackbar('JPG formate', 'File formate should be JPG');
      return null;
    }
  }

  // ^ Crop the image here
  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 40);
    if (croppedImage != null) {
      // ! we need "a value of File Type" so here we are converting the from CropperdFile to File
      final File croppedFile = File(
        croppedImage.path,
      );
// ~ image value updated
      image.value = croppedFile;
      log("Image value updated");
    }
  }

// ! sending photo
  sendPhoto(
      {required BuildContext context,
      required UserModel? endUserModel,
      required UserModel currentUserModel,
      required ChatRoomModel? chatRoomModel}) {
    TextEditingController messageNextController = TextEditingController();
    return Get.dialog(Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: Stack(
          // alignment: Alignment.topRight,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                width: MediaQuery.of(context).size.width,
                child: Image.file(
                  image.value!,
                  fit: BoxFit.contain,
                )),
            Positioned(
              top: 20,
              child: CupertinoButton(
                  child: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    image.value = null;
                    Get.back();
                  }),
            ),
            Positioned(
              bottom: 95,
              right: 25,
              left: 25,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                    border: Border.all(color: Colors.white54),
                    color: Colors.black),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: TextField(
                    maxLines: null,
                    controller: messageNextController,
                    style: TextStyle(fontSize: 11.sp, color: Colors.white),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add a Caption...",
                        hintStyle: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontStyle: FontStyle.italic)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20, bottom: 20,
              // height: ,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        endUserModel!.fullName!,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ),
                  CupertinoButton(
                      child: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.send),
                      ),
                      onPressed: () {
                        log("came ere");
                        // ! ********************
                        if (image.value != null) {
                          likeLoading.value = false;
                        }
                        log("came ere");
                        Get.find<ChatroomController>().sendMessage(
                            currentUserModel: currentUserModel,
                            endUserModel: endUserModel,
                            msg: messageNextController.text,
                            chatRoomModel: chatRoomModel!);

                        Get.back();
                      })
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

// ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// ^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// * ******************************************************
// ? ??????????????????????????????????????????????????????

  // ~  App Functionalities

  like({required UserProvider selfProvider, required UserModel endUser}) async {
    try {
      likeLoading.value = true;
      log(selfProvider.userModel!.fullName.toString());

      selfProvider.userModel!.blockedUsers!.add(endUser.uid);
      endUser.reciever!.add(FirebaseAuth.instance.currentUser!.uid);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(selfProvider.userModel!.uid!)
          .set(selfProvider.userModel!.toMap())
          .then((value) => FirebaseFirestore.instance
              .collection("users")
              .doc(endUser.uid!)
              .set(endUser.toMap()))
          .then((value) => selfProvider.updateUser(selfProvider.userModel!));

      var selfNotification = await getNotificationModel(
          endUser: endUser, currentUser: selfProvider.userModel!);

      print("self Notification");
      print(selfNotification!.sender.toString());
      print(selfNotification.reciever.toString());

      var endUserNotification = NotificationModel(
          createdOn: Timestamp.now(),
          // icon: const Icon(Icons.check),
          notifyId: const Uuid().v4(),
          reciever: selfProvider.userModel!.uid,
          sender: endUser.uid,
          theme: 'Liked');

      print("\n\nEnd User Notification");
      print(endUserNotification.sender.toString());
      print(endUserNotification.reciever.toString());

      endUser.notifications = endUser.notifications! + 1;

      FirebaseFirestore.instance
          .collection("users")
          .doc("${selfProvider.userModel!.uid}")
          .collection("notifications")
          .doc(selfNotification.notifyId)
          .set(selfNotification.toMap())
          .then((value) {
            return FirebaseFirestore.instance
                .collection("users")
                .doc(endUser.uid)
                .collection("notifications")
                .doc(selfNotification.notifyId)
                .set(selfNotification.toMap());
          })
          // .then((value) => sendPushNotificatio(widget.enduser, msg!));
          .then((value) => snakbar(userModel: endUser))
          .then(
            (value) => LocalNotificationServic.sendRequestNotification(
                currentUser: selfProvider.userModel!,
                endUser: endUser,
                msg: "like"),
          )
          .then((value) => FirebaseFirestore.instance
              .collection('users')
              .doc(endUser.uid)
              .set(endUser.toMap()));
      likeLoading.value = false;

      likeLoading.value = false;
    } catch (e) {
      likeLoading.value = false;

      log(e.toString());
    }
  }

  // ~ Get Notification
  Future<NotificationModel?> getNotificationModel(
      {required UserModel endUser, required UserModel currentUser}) async {
    // Loading.showLoadingDialog(context, "Creating");

    // Loading.showLoadingDialog(context, "Creating");

    NotificationModel notificationModel = NotificationModel(
        createdOn: Timestamp.now(),
        // icon: const Icon(Icons.check),
        notifyId: const Uuid().v4(),
        reciever: endUser.uid,
        sender: currentUser.uid,
        theme: 'Liked');

    log(notificationModel.notifyId.toString());

    return notificationModel;
  }

  matched(
      {required UserProvider userProvider, required UserModel opponentModel}) {
    try {
      likeLoading.value = true;
      log(userProvider.userModel!.fullName.toString());

      opponentModel.liked!.add(userProvider.userModel!.uid);
      opponentModel.blockedUsers!.remove(userProvider.userModel!.uid);
      opponentModel.reciever!.remove(userProvider.userModel!.uid);

      userProvider.userModel!.liked!.add(opponentModel.uid);

      userProvider.userModel!.reciever!.remove(opponentModel.uid);
      userProvider.userModel!.blockedUsers!.remove(opponentModel.uid);

      NotificationModel notificationModel = NotificationModel(
          createdOn: Timestamp.now(),
          // icon: const Icon(Icons.check),
          notifyId: const Uuid().v4(),
          reciever: opponentModel.uid,
          sender: userProvider.userModel!.uid,
          theme: 'Matched');

      opponentModel.notifications = opponentModel.notifications! + 1;

      FirebaseFirestore.instance
          .collection('users')
          .doc(opponentModel.uid)
          .set(opponentModel.toMap())
          .then((value) => FirebaseFirestore.instance
              .collection("users")
              .doc(userProvider.userModel!.uid)
              .set(userProvider.userModel!.toMap())
              .then(
                (value) => userProvider.updateUser(userProvider.userModel),
              )
              .then((value) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(opponentModel.uid)
                  .collection("notifications")
                  .doc(notificationModel.notifyId)
                  .set(notificationModel.toMap()))
              .then((value) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(userProvider.userModel!.uid)
                  .collection("notifications")
                  .doc(notificationModel.notifyId)
                  .set(notificationModel.toMap())))
          .then(
            (value) => LocalNotificationServic.sendMatchedNotification(
                currentUser: userProvider.userModel!,
                endUser: opponentModel,
                msg: "match"),
          )
          .then((value) => FirebaseFirestore.instance
              .collection('users')
              .doc(opponentModel.uid)
              .set(opponentModel.toMap()));

      Get.showSnackbar(GetSnackBar(
        icon: Icon(
          Icons.favorite,
          color: Colors.red,
          size: 50.sp,
        ),
        messageText: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "You Both are now matched",
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        barBlur: 3,
        borderRadius: 2000,
        titleText: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text("Matched",
              style: TextStyle(color: Colors.white, fontSize: 13.sp)),
        ),
        snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
      ));
      likeLoading.value = false;
    } catch (e) {
      likeLoading.value = false;
    }
  }

  unMatch(
      {required UserProvider userProvider,
      required bool isBlock,
      required UserModel opponentModel}) async {
    likeLoading.value = true;
    try {
      opponentModel.liked!.remove(userProvider.userModel!.uid);
      userProvider.userModel!.liked!.remove(opponentModel.uid);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(opponentModel.uid)
          .update({
        'liked': FieldValue.arrayRemove([userProvider.userModel!.uid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProvider.userModel!.uid)
          .update({
        'liked': FieldValue.arrayRemove([opponentModel.uid]),
      });

      userProvider.updateUser(userProvider.userModel);

      Get.showSnackbar(
        GetSnackBar(
          icon: Icon(
            Icons.heart_broken_outlined,
            color: Colors.white,
            size: 50.sp,
          ),
          messageText: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text(
              isBlock
                  ? "You Blocked ${opponentModel.fullName}"
                  : "You UnMatched ${opponentModel.fullName}",
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          barBlur: 3,
          borderRadius: 2000,
          titleText: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text("User Blocked",
                style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          ),
          snackStyle: SnackStyle.GROUNDED,
          snackPosition: SnackPosition.TOP,
        ),
      );
      likeLoading.value = false;
    } catch (e) {
      likeLoading.value = false;
    }
  }

// ! for Rejecting the Like of user

  rejectLike(
      {required UserProvider userProvider, required UserModel opponentModel}) {
    try {
      opponentModel.sender!.remove(userProvider.userModel!.uid);
      userProvider.userModel!.reciever!.remove(opponentModel.uid);

      NotificationModel notificationModel = NotificationModel(
          createdOn: Timestamp.now(),
          // icon: const Icon(Icons.check),
          notifyId: const Uuid().v4(),
          reciever: opponentModel.uid,
          sender: userProvider.userModel!.uid,
          theme: 'Rejected');
      opponentModel.notifications = opponentModel.notifications! + 1;

      FirebaseFirestore.instance
          .collection('users')
          .doc(opponentModel.uid)
          .set(opponentModel.toMap())
          .then((value) => FirebaseFirestore.instance
              .collection("users")
              .doc(userProvider.userModel!.uid)
              .set(userProvider.userModel!.toMap())
              .then(
                (value) => userProvider.updateUser(userProvider.userModel),
              )
              .then((value) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(opponentModel.uid)
                  .collection("notifications")
                  .doc(notificationModel.notifyId)
                  .set(notificationModel.toMap()))
              .then((value) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(userProvider.userModel!.uid)
                  .collection("notifications")
                  .doc(notificationModel.notifyId)
                  .set(notificationModel.toMap())))
          .then(
            (value) => LocalNotificationServic.sendRejectNotification(
                currentUser: userProvider.userModel!,
                endUser: opponentModel,
                msg: "reject"),
          )
          .then((value) => FirebaseFirestore.instance
              .collection('users')
              .doc(opponentModel.uid)
              .set(opponentModel.toMap()));

      Get.back();

      Get.showSnackbar(GetSnackBar(
        icon: Icon(
          Icons.heart_broken_outlined,
          color: Colors.white,
          size: 50.sp,
        ),
        messageText: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "You both are not a matched for each other",
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        barBlur: 3,
        borderRadius: 2000,
        titleText: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text("Rejected",
              style: TextStyle(color: Colors.white, fontSize: 13.sp)),
        ),
        snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
      ));
      likeLoading.value = false;
    } catch (e) {
      likeLoading.value = false;
    }
  }

// ! for Un sending Like
  unSendLike(
      {required UserProvider userProvider, required UserModel opponentModel}) {
    try {
      likeLoading.value = true;

      opponentModel.reciever!.remove(userProvider.userModel!.uid);
      userProvider.userModel!.blockedUsers!.remove(opponentModel.uid);

      FirebaseFirestore.instance
          .collection('users')
          .doc(opponentModel.uid)
          .set(opponentModel.toMap())
          .then((value) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(userProvider.userModel!.uid)
                  .set(userProvider.userModel!.toMap())
                  .then(
                    (value) => userProvider.updateUser(userProvider.userModel),
                  )
                  .then(
                    (value) => Get.showSnackbar(
                      GetSnackBar(
                        icon: Icon(
                          Icons.heart_broken_outlined,
                          color: Colors.white,
                          size: 50.sp,
                        ),
                        messageText: Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: Text(
                            "You UnLiked ${opponentModel.fullName}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.sp),
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                        barBlur: 3,
                        borderRadius: 2000,
                        titleText: Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: Text("Un Liked",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.sp)),
                        ),
                        snackStyle: SnackStyle.GROUNDED,
                        snackPosition: SnackPosition.TOP,
                      ),
                    ),
                  )
              // .then((value) => Get.back()),
              );

      likeLoading.value = false;
    } catch (e) {
      likeLoading.value = false;
    }
  }

  // ! getting all matched users

  // Create a reactive list of UserModels that can be null
  RxList<UserModel?> matchedUserList = <UserModel?>[].obs;

  // Getter to access the current value of the reactive list
  List<UserModel?> get matchedUsers => matchedUserList;

  // Setter to update the value of the reactive list

  getAllUsers({required UserModel userModel}) async {
    try {
      List<UserModel?> temUsers = [];
      List<String> ids = [];

      for (String doc in userModel.liked!) {
        if (ids.contains(doc)) {
        } else {
          ids.add(doc);
          temUsers.add(await FirebaseHelper.getClientModelById(doc));
        }
      }

      matchedUserList.value = temUsers;
      log("Total users @@@@@@@@@@@@@@@ ${matchedUserList.length}");
      return;
    } catch (e) {
      log('Error fetching users: $e');
      return null;
    }
  }

  String getFormattedTimeAgo({required Timestamp lastActive}) {
    DateTime currentTime = DateTime.now();
    DateTime lastActiveTime = lastActive.toDate();
    Duration difference = currentTime.difference(lastActiveTime);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Active now';
    }
  }

  Future<void> deleteChatroom({required String chatroomId}) async {
    // Delete messages associated with the chatroom

    await FirebaseFirestore.instance
        .collection('messages')
        .where('chatroomId', isEqualTo: chatroomId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    }).then((value) => Get.showSnackbar(const GetSnackBar(
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
              message: 'Deletd',
            )));
  }

  deleteAllMessages({required String chatroomId}) async {
// Delete the chatroom itself
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatroomId)
        .delete()
        .then((value) => Get.back());
  }

  var tempImageList = [].obs;
//  ~    Delete Photos
  Future<void> deletePhotos(
      {required int index,
      required UserModel endUserModel,
      required UserProvider userProvider}) async {
    tempImageList.removeAt(index);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(endUserModel.uid)
        .update({'photos': tempImageList}).then(
            (value) => userProvider.updateUser(endUserModel));
  }
}
