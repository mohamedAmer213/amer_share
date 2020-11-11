import 'package:amer_share/pages/home.dart';
import 'package:amer_share/widgets/header.dart';
import 'package:amer_share/widgets/post.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;


  PostScreen({this.userId="", this.postId="",});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post',),
      centerTitle: true,),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: postsRef
              .document(userId)
              .collection('userPosts')
              .document(postId)
              .get(),
          builder:
              (context, AsyncSnapshot<DocumentSnapshot> singleDocumentSnapshot) {
            if(!singleDocumentSnapshot.hasData){
              return circularProgress(context);
            }
            // print(singleDocumentSnapshot.data['likes'][userId]);
            return Post.fromDocument(singleDocumentSnapshot.data);
          },
        ),
      ),
    );
  }
}
