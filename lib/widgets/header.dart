import 'package:flutter/material.dart';

Widget header(BuildContext context, String title) {

  ///************* These things just for checking for some Screens******************
  bool isHome = true;
  bool includeBackBtn=true;
  if(title=='AmerFlutterShare'||title=='profile'){
  isHome=true;
  }else{
    isHome=false;
  }
  if(title=='setup your Profile'){
    includeBackBtn=false;
  }

  return AppBar(
    automaticallyImplyLeading:includeBackBtn ,
    elevation: 2,
    backgroundColor: Theme.of(context).primaryColor,
    centerTitle: isHome?true:false,
    title: Text(
      title,
      style: isHome
          ? TextStyle(fontSize: 50, fontFamily: 'Signatra',)
          : TextStyle(fontSize: 22),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
