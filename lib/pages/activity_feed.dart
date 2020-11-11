import 'package:amer_share/pages/home.dart';
import 'package:amer_share/pages/post_screen.dart';
import 'package:amer_share/pages/profile.dart';
import 'package:amer_share/widgets/header.dart';
import 'package:amer_share/widgets/post.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  Future<QuerySnapshot> getActivityFeed() async {
    Future<QuerySnapshot> ourFeeds = feedsRef
        .document(currentUser.userId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    return ourFeeds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).accentColor.withAlpha(20),
      backgroundColor: Colors.orange,
      appBar: header(context, 'Activity Feeds'),
      body: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, AsyncSnapshot<QuerySnapshot> amerFeedsSnapshot) {
          if (!amerFeedsSnapshot.hasData) {
            return circularProgress(context);
          }
          List<ActivityFeedItem> activityItemsList = [];

          amerFeedsSnapshot.data.documents.forEach((DocumentSnapshot doc) {
            activityItemsList.add(ActivityFeedItem.fromDocument(doc));
          });
          return Center(
              child: ListView(
            children: activityItemsList,
          ));
        },
      ),
    );
  }
}

// this class will be represented as single ListTile or card ua_amer
class ActivityFeedItem extends StatelessWidget {
  final String commentContent;
  final String ownerId;
  final String photoUrl;
  final String postId;
  final timestamp;
  final String type;
  final String userAvatarUrl;
  final String userId;
  final String username;
  final String description;

  ActivityFeedItem(
      {this.commentContent,
      this.ownerId,
      this.photoUrl,
      this.postId,
      this.timestamp,
      this.type,
      this.userAvatarUrl,
      this.userId,
      this.username,
      this.description});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentContent: doc['commentContent'],
      ownerId: doc['ownerId'],
      photoUrl: doc['photoUrl'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      username: doc['username'],
      userAvatarUrl: doc['userAvatarUrl'],
      userId: doc['userId'],
      description: doc['description'],
    );
  }

  Widget ActivityItemPreview;
  String ActivityItemText;

  @override
  Widget build(BuildContext context) {
    // this is for execute your method .. and fill the values of the ActivityItemText and ActivityItemPreview..
    // to get them ready for us ua_amer
    configureMediaPreview(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        color: Colors.white70,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(userAvatarUrl.toString()),
          ),
          trailing: ActivityItemPreview,
          title: GestureDetector(
            onTap: () {
              handleShowingCompleteProfile(context, userId: userId);
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    text: username,
                  ),
                  TextSpan(
                      text: ' $ActivityItemText',
                      style: TextStyle(color: Colors.grey))
                ],
              ),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  showPost(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PostScreen(
        postId: postId,
        userId: ownerId,
      );
    }));
  }

  //This will be used for the Trailing of the LisTile ... this  is so good to handle your data and organise your code
  configureMediaPreview(BuildContext context) {
    if (type == 'like' || type == 'comment') {
      ActivityItemPreview = GestureDetector(
        onTap: () {
          print(userId);
        showPost(context,);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(photoUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      ActivityItemPreview = Text('');
    }
    if (type == 'like') {
      ActivityItemText = 'liked your post';
    } else if (type == 'follow') {
      ActivityItemText = 'followed you';
    } else if (type == 'comment') {
      ActivityItemText = 'replayed: $commentContent';
    } else {
      ActivityItemText = 'Error :$type';
    }
  }

  handleShowingCompletePost(BuildContext context,
      {String postId, String userId, String description}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostScreen(
            // description: description,
            userId: userId,
            postId: postId,
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

  showOtherProfile(
    BuildContext context, {
    String profileId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Profile(
          profileId: profileId,
        );
      }),
    );
  }
}
