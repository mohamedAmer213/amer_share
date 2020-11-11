import 'dart:async';

import 'package:amer_share/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username =
      ''; // this is needed to store the value of formField ua_amer
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  submit() {
    final form = _formKey.currentState;
    form.save();

    /// this for saving the value of the Field
    if (form.validate()) {
      SnackBar snackBar = SnackBar(
        content: Text('Welcome $username!'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, 'setup your Profile'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Create a username',
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (value) {
                        setState(() {
                          this.username = value;
                        });
                      },
                      validator: (value) {
                        if (value.trim().length < 3) {
                          return 'The userName is too short';
                        } else if (value.trim().length > 12) {
                          return 'The username is too Long';
                        } else if (value.trim().isEmpty) {
                          return 'The username is Empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Must be greater than 3 characters ',
                        labelStyle: TextStyle(fontSize: 15.0),
                        labelText: 'userName',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    GestureDetector(
                        onTap: submit,
                        child: Container(
                          margin: EdgeInsets.all(30),
                          alignment: Alignment.center,
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Theme.of(context).primaryColor),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
