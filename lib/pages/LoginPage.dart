import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_full_chat_app/pages/HomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_full_chat_app/Widgets/ProgressWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  SharedPreferences preferences;
  FirebaseUser currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();

    if (isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage(currentUserId: preferences.getString("id"));
      }));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightGreenAccent, Colors.greenAccent[400]],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/chatlogo.png",
              fit: BoxFit.cover,
              width: 300,
            ),
            Text(
              "Shazly Chat",
              style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SquadaOne"),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                controlSignIn();
              },
              child: Image.asset(
                "assets/images/signwithgoogle.png",
                width: 300,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: isLoading ? circularProgress() : Container(),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);
    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      try {
        setState(() {
          isLoading = false;
        });
      } catch (e, s) {
        print(s);
      }
      // check if google user data already saved in firestore
      Fluttertoast.showToast(msg: "SignedIn Successfully");
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .getDocuments();
      List<DocumentSnapshot> documentSnapshot = resultQuery.documents;
      if (documentSnapshot.length == 0) {
        Firestore.instance
            .collection("user")
            .document(firebaseUser.uid)
            .setData({
          "nickname": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoUrl,
          "id": firebaseUser.uid,
          "aboutMe": "Iam Using Shazly Chat",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });
        currentUser = firebaseUser;
        await preferences.setString("id", currentUser.uid);
        await preferences.setString("nickname", currentUser.displayName);
        await preferences.setString("photoUrl", currentUser.photoUrl);
      } else {
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshot[0]["id"]);
        await preferences.setString(
            "nickname", documentSnapshot[0]["nickname"]);
        await preferences.setString(
            "photoUrl", documentSnapshot[0]["photoUrl"]);
        await preferences.setString("aboutMe", documentSnapshot[0]["aboutMe"]);
      }
      Fluttertoast.showToast(msg: "Congratulations, signed in Successfully");
      setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage(currentUserId: firebaseUser.uid);
      }));
    } else {
      Fluttertoast.showToast(msg: "SignIn Failed");
      setState(() {
        isLoading = false;
      });
    }
  }
}
