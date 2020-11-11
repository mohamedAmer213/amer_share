import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/home.dart';
import 'package:amer_share/widgets/header.dart';
import 'package:amer_share/widgets/post.dart';
import 'package:amer_share/widgets/post_tile.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.userId;
  bool isFollowing =false;
  int followingNumber = 0;
  int followersNumber = 0;
  bool isLoading;
  String postOrientation = 'grid';
  int count = 0;
  List<Post> posts = [];
  List<Post> postsTwo = [];

  ///Important we need to get the state of isFollowing instead of setting it false everyTime
  /// we need to get the numberOfFollowers and Number of Followings

  @override
  void initState() {
    super.initState();
    print('Done');
    getProfilePosts(); //for bringing the data from APi
    getIsFollowingState(); // this is equal checkIfFollowing() method
    getFollowingNumber();
    getFollowersNumber();
  }

  getIsFollowingState() async {
   DocumentSnapshot doc= await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
   // this is good idea ua_amer
   setState(() {
     isFollowing=doc.exists;
   });
  print('AAAAAAAAAAAAA $isFollowing');
  }

  getFollowingNumber() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingNumber = snapshot.documents.length;
    });
  }

  getFollowersNumber() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followersNumber = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document('${widget.profileId}')
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    // QuerySnapshot snapshot = await Firestore.instance
    //     .collection('posts')
    //     .document(widget.profileId)
    //     .collection('userPosts')
    //     .orderBy('timestamp', descending: true)
    //     .getDocuments();
    print('done');
    setState(() {
      count = snapshot.documents.length;
      snapshot.documents.forEach((DocumentSnapshot element) {
        posts.add(Post.fromDocument(element));
      });

      ///*****************This way doesn't work with me so try to use forEach *****************
      // posts = snapshot.documents.map(( singleDocument) {
      //   Post.fromDocument(singleDocument); // this will be made every iteration.. and the final result will be List of
      //   // Posts .... I think know we are able to understand the nature of map() work
      //   // consider the map() has temp memory to store single items together and get
      //   // them at the final step as a completed list .... so no need of using posts.add()
      //   // or theNameOfList.add() ....... to add items to the list
      // }).toList();
      //

      isLoading = false;
    });

/////this is just for checking the value ua_amer
//    var singlePost= await Firestore.instance.collection('posts').document(widget.profileId).collection('userPosts').document('''
//     b5fdd739-90a9-49e4-acba-05c7b0570e05
//     ''').get();
//   postsTwo.add(Post.fromDocument(singlePost));
  }

  @override
  Widget build(BuildContext context) {
    bool isProfileOwner = widget.profileId == currentUser?.userId;
    print(isProfileOwner);
    final List<Widget> allPostList = [];
    posts.forEach((Post element) {
      allPostList.add(element);
    });
    print(allPostList);

    return Scaffold(
      appBar: header(context, 'profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(
            height: 0.0,
          ),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(context),
          // Column(
          //   children: allPostList
          // ),
        ],
      ),
    );
  }

  toggleOrientation(String direction) {
    setState(() {
      this.postOrientation = direction;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == 'grid' ? Colors.red : Colors.grey,
          ),
          onPressed: () => toggleOrientation('grid'),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: postOrientation == 'list' ? Colors.red : Colors.grey,
          ),
          onPressed: () => toggleOrientation('list'),
        )
      ],
    );
  }

  buildSplashProfileScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Theme.of(context).accentColor.withAlpha(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SvgPicture.asset(
                    'assets/images/no_content.svg',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No Posts',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*    This function Just for training ua_amer    */
  buildSecondProfilePosts() {
    if (isLoading == true) {
      return circularProgress(context);
    } else if (posts.isEmpty) {
      return buildSplashProfileScreen(context);
    } else if (postOrientation == 'list') {
      List<Widget> allPostList = [];
      posts.forEach((Post element) {
        allPostList.add(element);
      });
      print(allPostList);
      return Container(
        height: 20,
        width: 20,
        color: Colors.black,
      );
    } else {}
  }

  buildProfilePosts(BuildContext context) {
    print(posts);
    if (isLoading == true) {
      return circularProgress(context);
    } else if (posts.isEmpty) {
      return buildSplashProfileScreen(context);
    } else if (postOrientation == 'grid') {
      // ********** this is just for preparing the List to use it in the
      // GridView that we will build later ua_Amer
      List<GridTile> gridTiles = [];
      posts.forEach((Post singlePost) {
        gridTiles.add(GridTile(child: PostTile(singlePost)));
      });
      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
        padding: EdgeInsets.all(4.0),
        mainAxisSpacing: 5,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 2.0,
      );
    } else {
      // ignore: non_constant_identifier_names

      final List<Widget> allPostList = [];
      posts.forEach((Post element) {
        allPostList.add(element);
      });

      return Column(
        children: allPostList,
      );
    }
  }

  FutureBuilder<DocumentSnapshot> buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> profileSnapshot) {
          // this is the main line of this widget ... because we will need its properties
          print(widget.profileId);
          switch (profileSnapshot.connectionState) {
            case ConnectionState.none:
              return circularProgress(context);
            case ConnectionState.waiting:
              return circularProgress(context);
            case ConnectionState.active:
            case ConnectionState.done:
              if (!profileSnapshot.hasData) return circularProgress(context);
              User user = User.fromDocument(profileSnapshot.data);
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider('${user.userPhoto}'),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  buildCountColumn(
                                      label: 'posts', count: count),
                                  buildCountColumn(
                                      label: 'followers',
                                      count: followersNumber),
                                  buildCountColumn(
                                      label: 'following',
                                      count: followingNumber),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // buildEditProfileButton(user),
                                  profileButton(),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        user.username.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        user.displayName.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        user.bio.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
          return Container();
        });
  }

  // Container buildButton({String text, Function function}) {
  //   return Container(
  // padding: EdgeInsets.only(top: 2.0),
  //     child: FlatButton(
  //       onPressed:(){
  //         editProfile();
  //       } ,
  //       child: Container(
  //         height: 27.0,
  //         width: 200.0,
  //         alignment: Alignment.center,
  //         child: Text(text,style: TextStyle(
  //           color: Colors.white,
  //           fontWeight:
  //             FontWeight.bold
  //         ),),
  //         decoration: BoxDecoration(
  //           color: Colors.blue,
  //           borderRadius: BorderRadius.circular(5.0),
  //           border: Border.all(
  //             color: Colors.blue,
  //           )
  //         ),
  //       ),
  //     ),
  //   );
  // }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentProfileId: widget.profileId,
        ),
      ),
    );
  }

  profileButton() {
    // first we need to check if the current  id of this page is equal to the the account id
    // or not and hint that the account id exist in the home.dart file
    bool isProfileOwner = widget.profileId == currentUser?.userId;
    if (isProfileOwner == true) {
      return buildProfileButton(text: 'EditProfile', function: editProfile);
    } else if (isFollowing == true) {
      return buildProfileButton(text: 'UnFollow', function: handleUnFollowUser);
    } else if (isFollowing == false) {
      return buildProfileButton(text: 'Follow', function: handleFollowUser);
    } else {
      return Text('NotFound');
    }
  }

  handleUnFollowUser() {
    //############### The idea Follower or following is to update the documents in the same time#########

    // the Opposite will made to the handleFollowUser()
    setState(() {
      // 1] the first thing is to set the state of the isFollowing to true
      isFollowing = false;
    });
    //  2]
    followingRef
        .document(currentUserId)
        .collection(
            'userFollowing') //userFollowing = " غير متابع ل هذا المستخدم"
        .document(widget.profileId)
        .get()
        .then((document) {
      if (document.exists) document.reference.delete();
    });
    //3]
    followersRef
        .document(widget.profileId)
        .collection('userFollowing')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    /// step 4] is to delete Activity Feed to the postOwner not the currentUser
    feedsRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUser.userId)
        .get()
        .then((doc) {
      if (doc.exists) doc.reference.delete();
    });
  }

  handleFollowUser() {
    // this is going to help us in the home Page ua_amer solved
    /*what is the the steps for building this ua_amer
    *1) we will setState for the isFollowing var
    * 2) we will go to create collection in DB and it will named Following ... the same will be made for the
    * UnFollowUser
    **/
    setState(() {
      // 1] the first thing is to set the state of the isFollowing to true
      isFollowing = true;
    });
    //2] second adding empty data to followers with the name of currentUSerId
    followersRef
        .document(widget.profileId)
        .collection('userFollowers') // userFollower ="  متابعون هذا البروفايل "
        .document(currentUserId)
        .setData({
      /* it's important hint currentUser comes from the home file ua_Amer solved */
      // 'type': 'follow',
      // 'username': currentUser.username, // hint this comes from the home
      // 'photoUrl': currentUser.userPhoto,
      // 'userId': currentUser.userId,
      // 'userAvatarUrl': currentUser.userPhoto,
      // 'timestamp': timestamp,
    });

    ///3] Third we need to add empty data to the followingRef And this will be the opposite
    /// of the second Step ua_amer
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});

    /// step 4] is to add Activity Feed to the postOwner not the currentUser
    feedsRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUser.userId)
        .setData({
      /* it's important hint currentUser comes from the home file ua_Amer solved */
      'type': 'comment',
      'ownerId':widget.profileId,
      'username': currentUser.username, // hint this comes from the home
      'photoUrl': currentUser.userPhoto,
      'userId': currentUser.userId,
      'userAvatarUrl': currentUser.userPhoto,
      'timestamp': timestamp,
    });
  }

  buildProfileButton({String text, Function function}) {
    return Padding(
      padding: const EdgeInsets.only(top:15),
      child: SizedBox(
        height: 25,
        width: 200,
        child: FlatButton(
          color: isFollowing ? Colors.white : Colors.blue,
          splashColor: Colors.blue,
          padding: EdgeInsets.all(0),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 16, color: isFollowing ? Colors.black : Colors.white),
          ),
          onPressed: function,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
    );
  }

  buildCountColumn({String label, int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$count'.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
            margin: EdgeInsets.all(4),
            child: Text(
              label,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
            )),
      ],
    );
  }
}
