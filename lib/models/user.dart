import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String bio;
  String displayName;
  String timestamp;
  String userEmail;
  String userId;
  String userPhoto;
  String username;

  User({this.bio,
    this.displayName,
    this.timestamp,
    this.userEmail,
    this.userId,
    this.userPhoto,
    this.username}); // we need to create simple named and optional constructor for this class


  // we need to create convenient constructor for this class ua_amer
  // and consider the factory method some thing like static method us_Amer
  // so we can access this method without taking anyObject from this class
  factory User.fromDocument(DocumentSnapshot doc){
return User(
  bio:doc['bio'].toString(),
  username: doc['username'].toString(),
  userEmail: doc['userEmail'].toString(),
  userId: doc['userId'].toString(),
  userPhoto: doc['userPhoto'].toString(),
  timestamp: doc['timestamp'].toString(),
  displayName: doc['displayName'].toString(),
);
  }
  // we can also make the convenient constructor by using this way
User.fromMap(DocumentSnapshot doc){
  this.bio=doc['username'];
  this.username= doc['username'];
  this.userEmail= doc['userEmail'];
  this.userId= doc['userId'];
  this.userPhoto= doc['userPhoto'];
  this.timestamp= doc['timestamp'];
  this.displayName= doc['displayName'];
}

// this is very Simple task to implement our class inorder to use it in the widgets

}
