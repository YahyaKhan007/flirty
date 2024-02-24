// import 'dart:convert';
// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

import '../models/user_model.dart';

class LocalNotificationServic {
  static String serveKey =
      'AAAAUkYZM_4:APA91bHXJFv9YoBXswV7cggyVTSccVMabv55565rFvR_rDvLYHQjqfea07ul91UqOndE7p_VGQZOrSv1Ojm5XCa1fr3ZbD8rQGs2_t2lAjv10o5QpPpREtal6ZV2TuOlfcar41IrF7Jr';

// !  methode 1
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/round_launcher"));

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // !  methode 2
  static void display(RemoteMessage message) async {
    try {
      Random random = Random();
      int id = random.nextInt(1000000000);
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails("chats", "my chats",
            importance: Importance.max, priority: Priority.high),
      );
      // print("My id is ---> ${id.toString()}");

      await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails);
    } on Exception catch (e) {
      print("Error ------->  $e");
    }
  }

  // !  methode 3
  static Future<void> sendPushNotificatio({
    required UserModel endUser,
    required UserModel currentUser,
    required String msg,
  }) async {
    try {
      print(currentUser.fullName);
      print(msg);
      final body = {
        "to": endUser.pushToken,
        "notification": {
          "title": currentUser.fullName,
          "body": msg,
          "android_channel_id": "chats"
        },
        "priority": 'high'
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$serveKey',
          },
          body: jsonEncode(
            body,
          ));

      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Send Notification  E --->      $e");
    }
  }

  // Request Notification
  static Future<void> sendRequestNotification({
    required UserModel endUser,
    required UserModel currentUser,
    required String msg,
  }) async {
    try {
      print(currentUser.fullName);
      print(msg);
      final body = {
        "to": endUser.pushToken,
        "notification": {
          "title": currentUser.fullName,
          "body": "${currentUser.fullName} send you a proposal",
          "android_channel_id": 'Likes'
        },
        "priority": 'high'
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$serveKey',
          },
          body: jsonEncode(
            body,
          ));

      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Send Notification  E --->      $e");
    }
  }

  // Request Notification
  static Future<void> sendMatchedNotification({
    required UserModel endUser,
    required UserModel currentUser,
    required String msg,
  }) async {
    try {
      print(currentUser.fullName);
      print(msg);
      final body = {
        "to": endUser.pushToken,
        "notification": {
          "title": "${currentUser.fullName}",
          "body": "You both are now matched ! Have FUN !!!",
          "android_channel_id": 'Likes'
        },
        "priority": 'high'
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$serveKey',
          },
          body: jsonEncode(
            body,
          ));

      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Send Notification  E --->      $e");
    }
  }

  static Future<void> sendRejectNotification({
    required UserModel endUser,
    required UserModel currentUser,
    required String msg,
  }) async {
    try {
      print(currentUser.fullName);
      print(msg);
      final body = {
        "to": endUser.pushToken,
        "notification": {
          "title": "Bad Luck",
          "body":
              "${currentUser.fullName} rejected your proposal ! Better Luck next time",
          "android_channel_id": 'Likes'
        },
        "priority": 'high'
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$serveKey',
          },
          body: jsonEncode(
            body,
          ));

      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Send Notification  E --->      $e");
    }
  }
}
