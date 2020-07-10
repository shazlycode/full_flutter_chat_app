import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text("Account Settings"),
        centerTitle: true,
      ),
      body: SettingsWidget(),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  TextEditingController nickNameTextEditingController;
  TextEditingController aboutMeTextEditingController;

  SharedPreferences preferences;
  String id;
  String nickname;
  String photoUrl;
  String aboutMe;
  File ImageFileAvatar;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    photoUrl = preferences.getString("photoUrl");
    aboutMe = preferences.getString("aboutMe");
    nickNameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);
    GoogleSignIn googleSignIn = GoogleSignIn();

    setState(() {});
  }

  getImage() async {
    File newImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        ImageFileAvatar = newImage;
        isLoading = true;
      });
      uploadImageToFireStore();
    }
  }

  Future<Null> uploadImageToFireStore() async {
    String mFileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask uploadTask = storageReference.putFile(ImageFileAvatar);
    var urlPath = await (await uploadTask.onComplete).ref.getDownloadURL();
    photoUrl = urlPath;
    Firestore.instance
        .collection("user")
        .document(id)
        .updateData({"photoUrl": photoUrl});
    await preferences.setString("photoUrl", photoUrl).catchError((e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: e.toString());
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> UpdateInfo() async {
    await Firestore.instance.collection("user").document(id).updateData(
        {"photoUrl": photoUrl, "nickname": nickname, "aboutMe": aboutMe});
    await preferences.setString("photoUrl", photoUrl);
    await preferences.setString("nickname", nickname);
    await preferences.setString("aboutMe", aboutMe);

//        .catchError((e) {
//      print("Error: $e");
//    });
    Fluttertoast.showToast(msg: "UpdatedSuccessfully");
  }

  GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logOutUser() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    firebaseAuth.signOut();

    setState(() {
      isLoading = false;
    });
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (ImageFileAvatar == null)
                          ? (photoUrl != "")
                              ? Material(
                                  // Display Image From network already exist
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.deepOrange),
                                        strokeWidth: 2,
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.grey,
                                )
                          : Material(
                              // Display new Image from file* Mobile Galary*
                              child: Image.file(
                                ImageFileAvatar,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white54.withOpacity(.3),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        iconSize: 200.0,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.red,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),
              Text(
                "Profile Info.",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  controller: nickNameTextEditingController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: "Enter Nickname"),
                  onChanged: (value) {
                    nickname = value;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  controller: aboutMeTextEditingController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: "About Me"),
                  onChanged: (value) {
                    aboutMe = value;
                  },
                ),
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      UpdateInfo();
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                    highlightColor: Colors.grey,
                    color: Colors.lightGreen,
                    splashColor: Colors.transparent,
                  ),
                  FlatButton(
                    onPressed: () {
                      logOutUser();
                    },
                    child: Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.white),
                    ),
                    highlightColor: Colors.grey,
                    color: Colors.redAccent,
                    splashColor: Colors.transparent,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
