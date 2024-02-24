import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/models.dart';
import 'controllers.dart';

class UserProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;

  // ~userModel
  UserModel? get userModel => _userModel;
  void updateUser(UserModel? value) {
    _userModel = value;
    notifyListeners();

    log("============================>>> user has been updated ");
  }

  // ~ update firebase user

  User? get firebaseUser => _firebaseUser!;
  void updateFirebaseUser(User value) {
    _firebaseUser = value;
    notifyListeners();
  }

  //~  change Screen index
  int _screenIndex = 0;
  int get screenIndex => _screenIndex;
  void changeScreenIndex(int value) {
    _screenIndex = value;
    notifyListeners();
  }

// ~ changing Language
  String _langCode = 'en';
  String get langCode => _langCode;
  void changeLanguageCode(String value) {
    _langCode = value;
    notifyListeners();
  }

  String _countryCode = 'US';
  String get countryCode => _countryCode;
  void changeCountryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

  // ! getting all users
  var authConroller = Get.find<FirebaseAuthController>();
  final List<UserModel> _users = [];
  List<UserModel> get users => _users;
  Future<List<UserModel>?> getAllUsers() async {
    try {
      // log("\n\n\t\tUser mode is interested in ${userModel!.interestedIn}\n\n");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      _users.clear(); // Clear the existing list.
      for (var doc in querySnapshot.docs) {
        // log("\n\n\t\t *********************  The Gender is  ${UserModel.fromSnapshot(doc).gender}\n\n");

        if (UserModel.fromSnapshot(doc).gender == userModel!.interestedIn) {
          // log("\n\n\t\tThe interest is in Females\n\n");
          _users.add(UserModel.fromSnapshot(doc));
        }
        else if(userModel!.interestedIn == authConroller.interestTypes[2]){
          _users.add(UserModel.fromSnapshot(doc));
        }

        // //~  ratings
        // List<dynamic>? ratings = UserModel.fromSnapshot(doc).ratings;
        // if (ratings != null) {
        //   var sum = 0.0;
        //   var time = 0;
        //   for (var rating in ratings) {
        //     if (rating.runtimeType == double) {
        //       sum = sum + rating;
        //       time += 1;
        //     } else if (rating.runtimeType == int) {
        //       sum = sum + rating;
        //       time += 1;
        //     }
        //   }

        //   authConroller.avgRatingCalculator(times: time, value: sum);
        // }

        // ~ ************************
      }
      notifyListeners();
      return _users;
    } catch (e) {
      log('Error fetching users: $e');
      return null;
    }
  }
}
