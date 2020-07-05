import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  HomePage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Home Screen"),
              RaisedButton.icon(
                  onPressed: () {
                    logOutUser();
                  },
                  icon: Icon(Icons.close),
                  label: Text("SignOut")),
            ],
          ),
        ),
      ),
    );
  }

  GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> logOutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
