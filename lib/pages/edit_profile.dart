import 'package:amer_share/models/user.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import 'home.dart';

class EditProfile extends StatefulWidget {
  final String currentProfileId;
  User currentProfileUser;

  EditProfile({this.currentProfileId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController displayBioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // this is using for bringing the data from the firebase
  bool isLoading = true;
  bool isDuringLoading=false;
  bool isValidName = true;
  bool isValidBio = true;
  String userFeedback = '';
  User currentUserModel;

  @override
  initState() {
    super.initState();
    getUserProfileData();
  }

  getUserProfileData() async {
    DocumentSnapshot doc =
        await usersRef.document('${widget.currentProfileId}').get();
    User userModel = User.fromDocument(doc);
    setState(() {
      currentUserModel = userModel;
      isLoading = false;
      displayBioController.text = currentUserModel.bio;
      displayNameController.text = currentUserModel.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user;
    setState(() {
      widget.currentProfileUser = user;
      /* this line when we need to use the Future Builder function
       but it is preferred to use getUserProfileData method because we need to download the
       data just one time instead of using downloading or updating the data many times .....
       its very important Step to notice
       */
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.green,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: isLoading
          ? circularProgress(context)
          : buildEditProfileBody(currentUserModel),
    );
  }

  buildEditProfileBody(User user) {
    return ListView(
      shrinkWrap: true,
      children: [
        isDuringLoading?linearProgress(context):Text(''),
        Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              minRadius: 20,
              maxRadius: 60,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.userPhoto),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [buildDisplayNameField(), buildBioField()],
          ),
        ),
        buildUpdateButton(),
        buildLogoutButton(),
      ],
    );
  }

  buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            icon: Icon(
              Icons.cancel,
              color: Colors.deepOrange,
            ),
            onPressed: logOut,
            label: Text(
              'Logout',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  logOut(){
    googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(
      builder: (context){
        return Home();
      }
    ));
  }
  updateProfileData() {
    //// This is just validation Method ua_Amer solved
    setState(() {
      (displayNameController.text.isEmpty ||
              displayNameController.text.length < 3)
          ? isValidName = false
          : isValidName = true;

      (displayBioController.text.isEmpty ||
              displayBioController.text.length > 100)
          ? isValidBio = false
          : isValidBio = true;
    });
    // to upload the data we need to make checking for the values of isValidName and isValidBio
    if (isValidName && isValidBio == true) {
      usersRef.document('${currentUserModel.userId}').updateData({
        'displayName': displayNameController.text,
        'Bio': displayBioController.text,
      }).then(
          (value){
           setState(() {
             isDuringLoading=true;
           });
          }
      ).then((value) {
        setState(() {
          Future.delayed(Duration(seconds: 2),(){
            setState(() {
              isDuringLoading=false;
            });
          });
        });
      });
      SnackBar snackBar=SnackBar(content: Text('Your data is updated Correctly'),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

  }

  buildUpdateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: RaisedButton(
            elevation: 0,
            color: Colors.deepOrange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: updateProfileData,
            child: Text(
              'Update Profile',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  buildDisplayNameField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DisplayName',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          TextFormField(
            decoration: InputDecoration(
                errorText: isValidName ? null : 'displayName is too short',
                hintText: 'Update displayName...'),
            controller: displayNameController,
          ),
        ],
      ),
    );
  }

  buildBioField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Bio',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          TextFormField(
            decoration: InputDecoration(
                errorText: isValidBio ? null : 'The Bio is too Long',
                hintText: 'Update Bio...'),
            controller: displayBioController,
          ),
        ],
      ),
    );
  }

  FutureBuilder<DocumentSnapshot> getUserProfileDataFuture(User user) {
    return FutureBuilder(
        future: usersRef.document('${widget.currentProfileId}').get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> profileSnapshot) {
          // this is the main line of this widget ... because we will need its properties
          switch (profileSnapshot.connectionState) {
            case ConnectionState.none:
              return circularProgress(context);
            case ConnectionState.waiting:
              return circularProgress(context);
            case ConnectionState.active:
            case ConnectionState.done:
              if (!profileSnapshot.hasData) return circularProgress(context);
              user = User.fromDocument(profileSnapshot.data);
              displayNameController.text = user.displayName;
              displayBioController.text = user.bio;
              return buildEditProfileBody(user);
          }
          return Container();
        });
  }
}
