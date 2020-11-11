import 'package:cloud_firestore/cloud_firestore.dart';

class UserId{
  final int userGoogleId;
  UserId({this.userGoogleId});
 factory UserId.fromDocument(DocumentSnapshot doc){
    return UserId(
      userGoogleId: doc['']
    );
  }
}