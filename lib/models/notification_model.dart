import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? notifyId;
  String? sender;
  String? reciever;
  String? theme;
  String? uid;

  Timestamp? createdOn;
  Timestamp? readTime;

// ! simple Constructor
  NotificationModel({
    this.notifyId,
    this.sender,
    this.reciever,
    this.theme,
    this.uid,
    this.createdOn,
  });

//  !  will be Used to change your Map/Json data into MessageModel
  NotificationModel.fromMap(Map<String, dynamic> map) {
    notifyId = map["notifyId"];

    sender = map["sender"];
    reciever = map["reciever"];

    createdOn = map["createdOn"];
    uid = map['uid'];
    theme = map['theme'];
  }

//  !  will be Used to change your MessageModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "notifyId": notifyId,
      "sender": sender,
      "reciever": reciever,
      "theme": theme,
      "uid": uid,
      "createdOn": createdOn,
    };
  }
}
