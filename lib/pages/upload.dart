import 'dart:io';
import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/home.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin{
//*************** our common Variable *************
  File file;
  String postId = Uuid().v4(); // this is for get unique id for this variable
  bool isUploading = false;
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File galleryFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = galleryFile;
    });
  }

  handleCameraImage() async {
    Navigator.pop(context);
    File cameraFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = cameraFile;
    });
  }

  selectImage(BuildContext parentDialog) {
    /*what is the main functionality of this function */
    // Navigator.pop(context);
    TextStyle _textStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 20,
      color: Colors.black,
    );
    showDialog(
      context: parentDialog,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(
            'Create Post',
            textAlign: TextAlign.center,
          ),
          children: [
            SimpleDialogOption(
              onPressed: handleCameraImage,
              child: Text(
                'Image with Camera',
                style: _textStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SimpleDialogOption(
              onPressed: handleChooseFromGallery,
              child: Text(
                'Image From Gallery',
                style: _textStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(parentDialog);
              },
              child: Text(
                'Cancel',
                style: _textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  selectImageCupertino(BuildContext parentDialog) {
    TextStyle _textStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 20,
      color: Colors.black,
    );
    return showCupertinoDialog(
        context: parentDialog,
        builder: (context) {
          return SimpleDialog(
            title: Text('create Post'),
            children: [
              SimpleDialogOption(
                onPressed: handleCameraImage,
                child: Text(
                  'Image with Camera',
                ),
              ),
              SimpleDialogOption(
                onPressed: handleChooseFromGallery,
                child: Text(
                  'Image From Gallery',
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(parentDialog);
                  /* when we used the context instead of the parentDialog the program crashed
                  * so we had to make special context for this showDialog ua_amer
                  * pop(parentDialog) = go one step back from this parentDialog ... and
                  * when it returns it will find the main context in front of him ..... so user will be
                  * in the mainContext
                  * */
                },
                child: Text(
                  'Cancel',
                ),
              ),
            ],
          );
        });
  }

  clearCamera() {
// Navigator.pop(context); /// THis is the common Error and this will crash all the program
    /*
    * when clearCamera function this will make the file== null and the buildMethod will call
    * the  SplachScreen*/
    setState(() {
      file = null;
    });
  }

  void compressImage() async {
    // File imageFile = await ImagePicker.pickImage();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);

    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    // Im.Image smallerImage = Im.copyResize(image, 500); // choose the size here, it will maintain aspect ratio

    var finalCompressedImage = new File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    setState(() {
      file = finalCompressedImage;
    });
  }

  /// the main Important function in this class ya_amer don't be faster
  Future<String> upLoadImage(File imageFile) async {
    StorageUploadTask storageUploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await storageUploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  /// the second Core function in our program ua_amer
  createPostInFirestore({
    String caption,
    String mediaUrl,
    String location,
  }) {
    ///// the SecondWay is ********************///////
    postsRef
        .document('${widget.currentUser.userId}')
        .collection('userPosts')
        .document(postId)
        .setData({
      'description': caption,
      'photoLocation': location,
      'photoUrl': mediaUrl,
      'username': currentUser.username,
      'postId': postId,
      'ownerId': widget.currentUser.userId,
      'timestamp': timestamp,
      'userPhoto': widget.currentUser.userPhoto,
      'likes': {},
    });

    allPosts.add(
        {
          'description': caption,
          'photoLocation': location,
          'photoUrl': mediaUrl,
          'username': currentUser.username,
          'postId': postId,
          'ownerId': widget.currentUser.userId,
          'timestamp': timestamp,
          'userPhoto': widget.currentUser.userPhoto,
          'likes': {},
        }

    );


    ///************** This is the way numberOne************
    // Firestore.instance
    //     .collection('posts')
    //     .reference()
    //     .document('${widget.currentUser.userId}')
    //     .collection('userPosts')
    //     .document(postId)
    //     .setData({
    //   'caption': caption,
    //   'photoLocation': location,
    //   'photoUrl': mediaUrl,
    // });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await upLoadImage(file);
    createPostInFirestore(
        caption: captionController.text,
        location: locationController.text,
        mediaUrl: mediaUrl);

    //////////************ clearing Step  Required ************
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
      /*this is necessary for not override the the old value of postId
         and This will change the postId after each Uploading operation
         */
    });
  }

bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    /* The main Idea From making File in the state is that if the file is equal to null
       we will return WidgetOne else we will return WidgetTwo
       1-) here widgetOne will be SplashScreen
       2-)here widgetTwo will be PageThat contains Form to fill the rest of the information
       3-) this condition is the core of this Page.... Amer
     */
  super.build(context);
    return file == null ? buildSplachScreen(context) : upLoadForm(context);
  }

  Widget upLoadForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearCamera,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(
                fontSize: 17,
                color: Colors.blueAccent,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          isUploading ? linearProgress(context) : Text(''),
          Column(
            children: [
              Container(
                // padding: EdgeInsets.only(top:8.0),
                height: MediaQuery.of(context).size.height * 0.31,
                width: MediaQuery.of(context).size.width * 0.95,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: FileImage(file))),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              ListTile(
                title: TextFormField(
                  controller: captionController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write your description....'),
                ),
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      widget.currentUser.userPhoto.toString()),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.add_location,
                  color: Colors.deepOrange,
                  size: 35.0,
                ),
                title: TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Location Where this photo taken....?',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: 200.0,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: Colors.blue,
                    onPressed: getUserCurrentLocation,
                    icon: Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    label: Text(
                      ' Location',
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSplachScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: RaisedButton(
              elevation: 0,
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              onPressed: () => selectImageCupertino(context),
              child: Text(
                'Upload Image',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    var placeMarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placeMark = placeMarks[0];
    String currentDevicePosition = """
${placeMark.name}
${placeMark.position}
${placeMark.administrativeArea}
${placeMark.isoCountryCode}
${placeMark.locality}
${placeMark.subAdministrativeArea}
${placeMark.subThoroughfare}  
""";

    /// small hint the ThoroughFare == road to this location ua_amer
    setState(() {
      locationController.text =
          '''${placeMark.country}/${placeMark.thoroughfare}/${placeMark.subLocality}/${placeMark.isoCountryCode}/${placeMark.postalCode}
  ''';
    });
  }
}
