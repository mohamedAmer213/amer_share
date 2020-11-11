import 'dart:developer';

import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/home.dart';
import 'package:amer_share/widgets/header.dart';
import 'package:amer_share/widgets/post.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final userRef = Firestore.instance.collection('users');
int _count = 0;

class Timeline extends StatefulWidget {
  final User timelineUser;

  Timeline({this.timelineUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    // getAllUsersPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, 'AmerFlutterShare'),
        // body: RefreshIndicator(
        //     onRefresh: getAllUsersPosts,
        // child: ListView(
        //   children: allPostList,
        // ),
        // )
///############################

        body: StreamBuilder(
            stream: allPosts.limit(10)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> allPostSnapshot) {
              List<Post> amerList = [];
              if (!allPostSnapshot.hasData) {
                return circularProgress(context);
              } else {
              allPostSnapshot.data.documents
                    .forEach((DocumentSnapshot element) {
                  amerList.add(Post.fromDocument(element));
                });
              }
              return ListView(
                children: amerList,
              );
            })
        );
  }

  //Method for getting all the posts
 // getAllUsersPosts() async {
 //    QuerySnapshot snapshot=await allPosts
 //        .orderBy('timestamp', descending: true)
 //        .getDocuments();
 //
 //  snapshot.documents.forEach((DocumentSnapshot element) {
 //    allPostList.add(Post.fromDocument(element));
 //  });
 //  }
 //  buildTimelineFunction(){
 //    if(allPostList ==null){
 //      return circularProgress(context);
 //    }else{
 //      return ListView(
 //        children: allPostList,
 //      ) ;
 //    }
 //  }


  List<Widget> _getItems() {
    var items = <Widget>[];
    for (int i = _count; i < _count + 4; i++) {
      var item = new Column(
        children: <Widget>[
          new ListTile(
            title: new Text("Item $i"),
          ),
          new Divider(
            height: 2.0,
          )
        ],
      );

      items.add(item);
    }
    return items;
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));

    setState(() {
      _count += 5;
    });

    return null;
  }
}

/*   ############# This is the old timeLine class ua_amer
class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    //************small hint putting function in the initial Method will execute it when the tree rebuild immediately************
    // getUser();
    // getUserById();
    // getPosts();
    // getLimitUser();
    // getUserOrdered();
    // getAllUsers();
    // addUserUsingAdd();
    // addUserUsingSet();
    // updateUser();
    // deleteUser();
    // correctUpdateUser();
    // correctDeleteUser();
  }

  //######################## Methods for getting users and Using Queries ###############
  getUserById() async {
    final String docId = "SoLmpnT1YXcmvGWIgsbM"; // this is just hardcoded
    DocumentSnapshot userData =
        await Firestore.instance.collection('users').document(docId).get();
    print(userData.data);
    print(userData.exists);
    print(userData.documentID); // this for printing the id of the doc
  }

  //Getting user by using query OR .... using query for getting user,... or specific users solved
  ///  Getting the the admin users... using [Single where]
  getUser() async {
    final QuerySnapshot snapshot =
        await userRef.where('isAdmin', isEqualTo: true).getDocuments();
    snapshot.documents.forEach((element) {
      print(element.data);
      print(element.documentID);
      print(element.exists);
    });

    // userRef.getDocuments().then((QuerySnapshot snapShot) {
    //   snapShot.documents.forEach((DocumentSnapshot doc) {
    //     print(doc.data); /// all the data in the document
    //     print(doc.documentID);// this for printing the id of the doc
    //     print(doc.exists); /// this will be true or false
    //   });
    // });
  }

  ///using the query[Multiple Where query ]to get the users whose posts greater than five posts
  getPosts() async {
    QuerySnapshot postSnapshot = await userRef
        .where('postCount', isLessThan: 2)
        .where('username', isEqualTo: 'mohamed')
        .where('isAdmin', isEqualTo: true)
        .getDocuments();
    postSnapshot.documents.forEach((DocumentSnapshot doc) {
      print(doc.documentID);
      print(doc.data);
      print(doc.exists);
    });
  }

  // using Where with limit functions in the query##############
  getLimitUser() async {
    QuerySnapshot snapshot =
        await userRef.where('isAdmin', isEqualTo: true).limit(1).getDocuments();
    snapshot.documents.forEach((DocumentSnapshot doc) {
      print(doc.data);
    });
  }

  getUserOrdered() async {
    QuerySnapshot snapshot =
        await userRef.orderBy('postCount', descending: false).getDocuments();
    snapshot.documents.forEach((element) {
      print(element.data);
      print(element.documentID);
    });
  }

  ///############################################### End of Queries section ##############
  // @override
  // Widget build(context) {
  //   return Scaffold(
  //       appBar: header(context, 'AmerFlutterShare'),
  //       body: allUsersStreamBuilder());
  // }

  ///################# Listing all the users by looping on the List ,,, using Stream and Future Functionality #########
  Container allUserFutureBuilder(BuildContext context) {
    // note that in this function we have to use switch case because the FutureBuilder
    // takes time to get data from the internet solved
    return Container(
      child: FutureBuilder(
        future: userRef.getDocuments(),
        builder: (context, AsyncSnapshot<QuerySnapshot> amerSnapshot) {
          // separating Creating children Variable to hold the the coming data
          switch (amerSnapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return circularProgress(context);
            case ConnectionState.active:
            case ConnectionState.done:
              List<ListTile> children =
                  amerSnapshot.data.documents.map((DocumentSnapshot doc) {
                return ListTile(
                  leading: IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      userRef.document(doc.documentID).delete();
                    },
                  ),
                  title: Text(
                    doc.data['username'].toString(),
                  ),
                );
              }).toList();

              if (!amerSnapshot.hasData) {
                return circularProgress(context);
              } else {
                return ListView(children: children);
              }
          }
          return Container();
        },
      ),
    );
  }

  Container allUsersStreamBuilder() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            return ListView(
                children: snapshot.data.documents.map((DocumentSnapshot amer) {
              // hint that amer here will hold one document and to get inside the document
              // you need to choose the .data property
              return ListTile(
                  trailing: IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      userRef.document(amer.documentID).delete();
                    },
                  ),
                  title: Text(amer.data['username'].toString()));
            }).toList());
          }),
    );
  }

// now its time time to to use the data in the Widgets
  Future<List> getAllUsers() async {
    QuerySnapshot snapshot = await userRef.getDocuments();
    setState(() {
      users = snapshot.documents;
    });
    print(users[3]['username'].toString());
    return users;
  }

  ///####################### The end of this section #####################

///////////########## Important section using complete CRUD operations #################

  addUserUsingAdd() async {
    /* 1-using add method will give us some thing from FutureDocument
       2- it generates the AutoId for this document
       3- and this method rebuilds itself with the tree ua_amer each Time solved
     */
    DocumentReference doc = await userRef.add({
      'username': 'Ammar',
      'isAdmin': false,
      'postCount': 7,
    });
    return doc;
  }

  addUserUsingSet() {
    /*
    * 1- setData method Contains parameter called isMerge that will merge the data if the document
    * exists before
    * 2- setData doesn't return anything or returns void function
    * */
    userRef.document('amerDocument').setData({
      'username': 'Salma',
      'postCount': 45,
      'isAdmin': true,
      'desc': 'The leader of S21 Project',
    });
  }

  updateUser() {
    // all what we need for the update Methods is the documentId solved .. and List the New map
    userRef.document('amerDocument').updateData({
      'username': 'salma',
      'postCount': 10,
      'isAdmin': false,
      'desc': 'The leader of S21 Project',
    });
  }

  deleteUser() {
    // just all what we need here is the document Id not more solved
    userRef.document('amerDocument').delete();
  }

  correctUpdateUser() async {
    DocumentSnapshot doc = await userRef.document('amerDocument').get();
    if (doc.exists) {
      // hint don't forget to use reference ua_amer this is right thing to update
      doc.reference.updateData({
        'username': 'Mo_amer',
        'postCount': 10,
        'isAdmin': false,
        'desc': 'The leader of S21 Project',
      });
    }
  }

  correctDeleteUser() async {
    final DocumentSnapshot amer = await userRef.document('amerDocument').get();
    if (amer.exists) {
      amer.reference.delete();
    }
  }
}

 */

 */
