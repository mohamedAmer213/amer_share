import 'dart:async';

import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/comments.dart';
import 'package:amer_share/pages/profile.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:amer_share/pages/home.dart';
import 'package:flutter/rendering.dart';

import 'custom_image.dart';

// var postsRef =Firestore.instance.collection('posts').reference();
class Post extends StatefulWidget {
  /*small hint this the first time to use this technique ua_amer It's important */
  final String description;
  final String ownerId;
  final String photoLocation;
  final String photoUrl;
  final String postId;
  final String username;
  final String userPhoto;
  Map likes;

  Post({
    this.description,
    this.likes,
    this.ownerId,
    this.photoLocation,
    this.photoUrl,
    this.postId,
    this.username,
    this.userPhoto,
  });

  // let's go to create factory Method ua_Amer
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      description: doc['description'],
      likes: doc['likes'],
      ownerId: doc['ownerId'],
      photoUrl: doc['photoUrl'],
      photoLocation: doc['photoLocation'],
      postId: doc['postId'],
      username: doc['username'],
      userPhoto: doc['userPhoto'],
    );
  }

// so we need to makes method to count the likes ua_Amer ....
  int getLikesCount(likes) {
    int count = 0;
    if (this.likes == null) {
      count = 0;
    } else {
      likes.values.forEach((value) {
        if (value == true) {
          count += 1;
        }
      });
    }
    return count;
  }

  @override
  _PostState createState() => _PostState(
        description: this.description,
        photoLocation: this.photoLocation,
        photoUrl: this.photoUrl,
        likes: this.likes,
        ownerId: this.ownerId,
        postId: this.postId,
        username: this.username,
        countLikes: getLikesCount(this.likes),
      );
}

class _PostState extends State<Post> {
  /* we have to create the variables in this in class to use them during passing to the constructor of this class*/
  final String description;
  final String ownerId;
  final String photoLocation;
  final String photoUrl;
  final String postId;
  final String username;
  final String userPhoto;
  final String currentUserId = currentUser?.userId;
  int countLikes;
  Map likes;
  bool showHeart = false;

  // bool _isLiked;
  bool isLikedDBState;

  /* the likes is a Map and we need {key: value}==> here
  the key will be the userId  of The App
  2- ##This is required to know if the user already Liked this
  post before or not liked it
   */

// hint the same variables preferred to be used for not confusing ourselves ua_amer
  _PostState( // now we have named constructor for this class and this is good
      {
    this.description,
    this.likes,
    this.ownerId,
    this.photoLocation,
    this.photoUrl,
    this.postId,
    this.countLikes,
    this.username,
    this.userPhoto,
  });

//############ some Required parameters for this class for the favourite Icon #######

  //*****************LET'S BUILD OUR WIDGETS FOR THIS SCREEN UA_AMER SOLVED*****//
  handleLikeButton() {
    /*
    ##### Small hint the default value of the _isLiked var will be the value in the likes map of the currentUser ###
    * 1] we need to check if the current user already liked this post before or not
    * 2] if liked we will not going to make any changing in the map
    * 3] if not we will go and update the value in his map to true
    * */
    bool _isLiked = (likes[currentUserId] ==
        true); //only If this condition true The _isLiked will be true
    if (_isLiked) {
      removeLikeFromActivityFeed();
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({
        'likes': {
          currentUserId: false,
        }
      });
      setState(() {
        countLikes -= 1;
        isLikedDBState = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      handleAddLikeToActivityFeeds();
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({
        'likes': {
          currentUserId: true,
        }
      });
      setState(() {
        countLikes += 1;
        isLikedDBState = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedsRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((DocumentSnapshot value) {
        /*we have first check if the value exist or not exists in the database ua_Amer solved */
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  handleAddLikeToActivityFeeds() {
    /*
    * add notifications to the postOwner's activity feed only if comment
    * made by other user (to avoid getting notification for our own like
    * we need to compare the currentUserId with the ownerId
    * */


    bool isNotPostOwner = currentUserId != ownerId;
    /* if amer == true we will send notification that Another user like THis post*/
    if (isNotPostOwner) {
      feedsRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        /* it's important hint currentUser comes from the home file ua_Amer solved */
        'type': 'like',
        'username': currentUser.username, // hint this comes from the home
        'photoUrl': photoUrl,
        'postId': postId,
        'ownerId': ownerId,
        'userId': currentUser.userId,
        'userAvatarUrl': currentUser.userPhoto,
        'timestamp': timestamp,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*  this line to get the Stored value in likes[currentUserId]
    and set it to isLikedDBState variable*/
    isLikedDBState = likes[currentUserId] == true;
    /* what this means ?
   this means that the default value of the likes[currentUser]=false
    */
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: [
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }

  /* ************* The end of the new items ua_amer ********************* */

  buildPostFooter() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0, top: 40.0),
            ),
            GestureDetector(
              onTap: handleLikeButton,
              child: Icon(
                isLikedDBState ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () {
                print(postId);
                handleCommentButton(
                  context,
                  ownerId: ownerId,
                  postId: postId,
                  photoUrl: photoUrl,
                  username: username,
                  userPhoto: userPhoto,
                );
              },
              child: Icon(
                Icons.chat,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$countLikes likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$username',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10),
                child: Text(
                  '$description',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Divider(
              height: 0.0,
            ),
          ],
        ),
      ],
    );
  }

  getAllPostInfo() async {
    DocumentSnapshot doc = await postsRef.document('ownerId').get();
    Post postModel = Post.fromDocument(doc);
  }

  buildPostImage() {
    return GestureDetector(
        onDoubleTap: handleLikeButton,
        child: Container(
          // height: 250,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomCachedNetworkImage(photoUrl.toString()),
              showHeart
                  ? Icon(
                      Icons.favorite,
                      size: 200,
                      color: Colors.red.withAlpha(100),
                    )
                  : Text(''),
            ],
          ),
        ));
  }

  buildPostHeader() {
    bool isPostOwner = currentUser.userId == ownerId;
    return FutureBuilder(
        future: usersRef.document(ownerId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> amer) {
          if (!amer.hasData) {
            return circularProgress(context);
          }
          User user = User.fromDocument(amer.data);
          print('amer is testing users');
          print(user);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.userPhoto.toString()),
                ),
                title: GestureDetector(
                  onTap: ownerId == user.userId
                      ? null
                      : () => handleShowingCompleteProfile(context,
                          userId: user.userId),
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Text(photoLocation.toString()),
                trailing: isPostOwner
                    ? IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => handleDeletingPost(context),
                      )
                    : Text(''),
              ),
            ],
          );
        });
  }

  handleDeletingPost(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Removing Post..?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () => DeletePost(context),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  DeletePost(context) async {
    // Navigator.pop(context);
    //first we need to delete this post from postsCollection
    await postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //second we need to delete comments of this post from the CommentsCollection
    await commentsRef
        .document(postId)
        .collection('userPosts')
        .getDocuments()
        .then((QuerySnapshot commentsQuerySnapshot) {
      commentsQuerySnapshot.documents.forEach((DocumentSnapshot element) {
        element.reference.delete();
      });
    });
    // third we need to delete the Image from the storage
    //### To keep all Photos about the users (Top Secret)######
    // await storageRef.child('post_$postId.jpg').delete();

    // Fourth we need to delete the All ActivityFeed Notifications of this post
    await feedsRef
        .document(ownerId)
        .collection('userFeeds')
        .where(postId, isEqualTo: postId)
        .getDocuments()
        .then((QuerySnapshot feedsQuerySnapshot) {
      feedsQuerySnapshot.documents.forEach((DocumentSnapshot doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
    Navigator.pop(context);
  }

  handleCommentButton(BuildContext context,
      {String photoUrl,
      String postId,
      String ownerId,
      String username,
      String userPhoto}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          print(postId);
          return Comments(
            username: username,
            postId: postId,
            photoUrl: photoUrl,
            ownerId: ownerId,
            userPhoto: userPhoto,
          );
        },
      ),
    );
  }

  handleShowingCompleteProfile(BuildContext context,
      {String username, String userId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Profile(
        profileId: userId,
      );
    }));
  }
}