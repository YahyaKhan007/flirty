import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? country;
  double? latitude;
  double? longitude;
  String? fullName;
  String? email;
  String? pushToken;
  String? profilePicture;
  String? city;
  String? gender;
  String? interestedIn;
  List? liked;
  List? blockedUsers;
  List? photos;
  int? age;
  List? sender;
  List? reciever;
  String? bio;
  Timestamp? memberSince;
  bool? isVarified;
  bool? premium;
  int? notifications;
  Timestamp? lastActive;
  // bool? sendEmotion;
// ! simple Constructor
  UserModel(
      {required this.uid,
      required this.lastActive,
      required this.photos,
      required this.premium,
      required this.country,
      required this.fullName,
      required this.age,
      required this.city,
      required this.interestedIn,
      required this.latitude,
      required this.longitude,
      required this.email,
      required this.bio,
      required this.gender,
      required this.sender,
      required this.reciever,
      required this.liked,
      required this.blockedUsers,
      required this.memberSince,
      required this.notifications,
      // required this.accountType,
      required this.pushToken,
      required this.isVarified,
      required this.profilePicture});

//  !  will be Used to change your Map/Json data into UserModel
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    photos = map["photos"];
    lastActive = map["lastActive"];
    premium = map["premium"];
    age = map["age"];
    city = map["city"];
    country = map["country"];
    // latitude = map["latitude"];
    // latitude = map["latitude"];
    // longitude = map["longitude"];
    latitude = map["latitude"].toDouble();
    longitude = map["longitude"].toDouble();
    fullName = map["fullName"];
    interestedIn = map["interestedIn"];
    email = map["email"];
    gender = map["gender"];
    liked = map["liked"];
    blockedUsers = map["blockedUsers"];
    reciever = map["reciever"];
    memberSince = map["memberSince"];
    pushToken = map["pushToken"];
    // accountType = map["accountType"];
    isVarified = map['isVarified'];
    profilePicture = map["profilePicture"];
    bio = map["bio"];
    notifications = map["notifications"];
    // sendEmotion = map["sendEmotion"];
  }

//  !  will be Used to change your UserModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "photos": photos,
      "lastActive": lastActive,
      "premium": premium,
      "country": country,
      "age": age,
      "city": city,
      "interestedIn": interestedIn,
      "latitude": latitude,
      "longitude": longitude,
      "fullName": fullName,
      "email": email,
      "gender": gender,
      "liked": liked,
      "sender": sender,
      "reciever": reciever,
      "memberSince": memberSince,
      // "accountType": accountType,
      "profilePicture": profilePicture,
      "pushToken": pushToken,
      'isVarified': isVarified,
      "bio": bio,
      "notifications": notifications,
      "blockedUsers": blockedUsers,
      // "sendEmotion": sendEmotion
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      interestedIn: data['interestedIn'],
      photos: data['photos'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      uid: snapshot.id,
      fullName: data['fullName'],
      email: data['email'],
      pushToken: data['pushToken'],
      profilePicture: data['profilePicture'],
      // accountType: data['accountType'],
      gender: data['gender'],
      bio: data['bio'],
      memberSince: data['memberSince'],
      isVarified: data['isVarified'],
      liked: data['liked'], city: data['city'], age: data['age'],
      sender: data['sender'],
      reciever: data['reciever'],
      country: data['country'],
      premium: data['premium'],
      notifications: data['notifications'],
      lastActive: data['lastActive'],
      blockedUsers: data['blockedUsers'],
      // Add more properties here as needed
    );
  }
}
