import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

StreamController<UserModel> userDataController = StreamController<UserModel>();

class FirebaseHelper {
  // ! Signup Details

  // ! Login Details

  // ! Getting User By ID

  static Future<UserModel?> getClientModelById(String uid) async {
    UserModel? userModel;
    log("===================================>>$uid");

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);

      log(userModel.fullName.toString());
    }

    return userModel;
  }

  // static void getUserData(String uid) async {
  //   DocumentSnapshot userSnapshot =
  //       await FirebaseFirestore.instance.collection('requests').doc(uid).get();
  //   ClientModel? clientModel;

  //   // Create a UserModel object from the retrieved user data
  //   if (userSnapshot.data() != null) {
  //     clientModel =
  //         ClientModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

  //     print(clientModel.fullName.toString());
  //   }

  //   // Add the UserModel object to the stream
  //   userDataController.add(clientModel!);
  // }
}
