import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/create_account.dart';
import 'package:amer_share/pages/profile.dart';
import 'package:amer_share/pages/search.dart';
import 'package:amer_share/pages/timeline.dart';
import 'package:amer_share/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'activity_feed.dart';

//##########some global variables needed for this file###########
final usersRef = Firestore.instance.collection('users');
final  postsRef=Firestore.instance.collection('posts');
final commentsRef=Firestore.instance.collection('comments');
final feedsRef=Firestore.instance.collection('feeds');
final followersRef=Firestore.instance.collection('followers');
final followingRef=Firestore.instance.collection('following');
// final timelineRef=Firestore.instance.collection('timeline');
final allPosts=Firestore.instance.collection('allPosts');

final GoogleSignIn googleSignIn = GoogleSignIn();
final DateTime timestamp = DateTime.now();
final storageRef=FirebaseStorage.instance.ref();
 User currentUser;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //#################Our variables#############
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0; // the First Page to displayed ua_amer
  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
       handleSignIn(account);
    }, onError: (error) {
      print('Error signingIn $error');
    });
    // ReAuthenticate user when app is opened
    googleSignIn.signInSilently(
      suppressErrors: false,
    ).then((account) {
      handleSignIn(account);
    }).catchError((error) {
      print('Error signingIn $error');
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

//################ The start of Auth section ##########################
  // creating some google Methods for login and logout
  login() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
    // that's great right now ya_amer solved ..
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      // we need function to create user in the firestore
      createUserInFirestore();
      print('A new user signedIn!:$account');
      setState(() {
        isAuth = true;
      });
    } else {
      print('The account equal null');
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    User addedUser;
    //########## Steps #########
    final GoogleSignInAccount user = googleSignIn.currentUser;
    // 1)check if the users exists in the usersCollection in the database before or not
    final DocumentSnapshot singleUserDoc =
    await usersRef.document(user.id).get();
    // 2) if not exists we will go to create it by taking them to create accountPage
    if (!singleUserDoc.exists) {
      final String username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
// 3) get username from CreateAccountPage and use it as userName of the new account
      usersRef.document(user.id).setData({
        'username': username,
        'displayName': user.displayName,
        'userId': user.id,
        'userPhoto': user.photoUrl,
        'bio': "",
        'userEmail': user.email,
        'timestamp': timestamp,
      });

// User amerUser=User.fromDocument(doc);
      DocumentSnapshot  doc=await usersRef.document(user.id).get();
       addedUser = User.fromDocument(doc);
    } else {
       addedUser = User.fromDocument(singleUserDoc);
      // print(addedUser.username);
      // print(addedUser.displayName);
      // print(addedUser.timestamp);
      // print(addedUser.userEmail);
    } // the ends if Not found the user
setState(() {
  currentUser=addedUser;
});
  }

//################################### End the Auth section ua_amer ###############

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.75),
              Theme.of(context).accentColor,
              Colors.pink,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'AmerShare\nMostafa Alaa\nAlaaAdel \nMO_amer',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Signatra', fontSize: 60),
            ),
            GestureDetector(
              onTap: () => login(),
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/google_signin_button.png'),
                  fit: BoxFit.cover,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int currentPage) {
          // Third the setState Method will change the pageIndex
          setState(() {
            pageIndex = currentPage;

            /// this will change the value of pageIndex in order to use it in the tabBar
          });
        },
        // note that the OnPageChanged gives us int
        controller: pageController,
        children: [
          Timeline(timelineUser: currentUser,),
          // Center(child:Text('This is the Time Line')),
          // buildLogoutBtn(),
          ActivityFeed(),
          Upload(currentUser:currentUser),
          Search(),
          Profile(profileId: currentUser?.userId,),  // this is very important trice .. and it the first time for us to use it ua_amer
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex, // the First thing done
        activeColor: Theme.of(context).accentColor,
        onTap: (int currentIndex) {
          //responsible for changing the page on the pageView
          pageController.animateToPage(currentIndex,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          // second you will jump to the page
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  Widget buildLogoutBtn() {
    return RaisedButton(
        child: Text('Logout'),
        onPressed: () {
          googleSignIn.signOut();
        });
  }
}
