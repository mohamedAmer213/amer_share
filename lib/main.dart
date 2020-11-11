import 'dart:ffi';

import 'package:amer_share/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
 //* this step is required for enabling timeStamp in the firebase ua_amer solved*//
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then(
    (_) {
      print('TimeStamps enabled in snapshots \n');
    },
    onError: (_){
      print('Error enabling in the timestamp ');
    }
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal,
          accentColor: Colors.purple),
      title: 'Alaa_Share',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
