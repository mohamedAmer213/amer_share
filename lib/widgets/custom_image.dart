import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget CustomCachedNetworkImage(String photoUrl) {
  return CachedNetworkImage(
    imageUrl: photoUrl,
    fit: BoxFit.cover,
    placeholder: (BuildContext context, String photoUrl) {
      return Padding(
        padding: EdgeInsets.all(20.0),
        child: circularProgress(context),
      );
    },
    errorWidget:(context,String error,url){
      return Icon(Icons.error);
    }
  );
}
