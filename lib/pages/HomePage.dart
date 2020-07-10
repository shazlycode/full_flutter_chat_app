import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_chat_app/Models/user.dart';
import 'package:flutter_full_chat_app/Widgets/ProgressWidget.dart';
import 'package:flutter_full_chat_app/pages/ChatRoom.dart';
import 'package:flutter_full_chat_app/pages/SettingsPage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  HomePage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(currentUserId);
}

class _HomePageState extends State<HomePage> {
  String currentUserId;
  _HomePageState(this.currentUserId);
  // _HomePageState({Key key, this.currentUserId});
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  clearTextFormField() {
    searchTextEditingController.clear();
  }

  // controlSearching() {
  //   Future<QuerySnapshot> allusers = Firestore.instance
  //       .collection("user")
  //       .where("nikename", isGreaterThanOrEqualTo: userName)
  //       .getDocuments();
  //   return allusers;

  //   setState(() {
  //     futureSearchResults = allusers;
  //   });
  //   return futureSearchResults;
  // }

  getAllUsers() {
    var result = Firestore.instance.collection("user").snapshots();
    return result;
  }

  DisplayNoUser() {
    return Container(
      child: ListView(
        children: <Widget>[
          Icon(
            Icons.group,
            size: 200.0,
            color: Colors.teal,
          ),
          Text(
            "Search users",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // DisplaySearchResults() {
  //   return StreamBuilder(
  //       stream,: Firestore.instance.collection("user").snapshots();
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           print(Error);
  //         }
  //         switch (snapshot.connectionState) {
  //           case ConnectionState.waiting:
  //             return Container(
  //               child: Text("Loadding ......"),
  //             );
  //             break;
  //           default:
  //             return ListView.builder(
  //                 itemCount: snapshot.data.documents.length,
  //                 itemBuilder: (context, index) {
  //                   return ListTile(
  //                     title:
  //                         Text(snapshot.data.documents[index].data["nikename"]),
  //                   );
  //                 });
  //         }
  //       });
  // }
  QuerySnapshot searchSnapshot;
  streamResult() {
    if (searchTextEditingController.text.length > 0) {
      Firestore.instance
          .collection("user")
          .where("nickname",
              isGreaterThanOrEqualTo: searchTextEditingController.text)
          .getDocuments()
          .then((value) {
        setState(() {
          searchSnapshot = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              }),
        ],
        title: Container(
          margin: EdgeInsets.only(
            bottom: 4,
          ),
          child: TextFormField(
            controller: searchTextEditingController,
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            decoration: InputDecoration(
              hintText: "Search here ...",
              hintStyle: TextStyle(
                color: Colors.white,
              ),
              prefix: Icon(
                Icons.person_pin,
                size: 30,
              ),
              suffix: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    streamResult();
                  }),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
            ),
//              onFieldSubmitted: getAllUsers(),
          ),
        ),
      ),
      body: searchSnapshot != null
          ? ListView.separated(
              shrinkWrap: true,
              itemCount: searchSnapshot.documents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Map<String, dynamic> chatInfo = {
                      "username2":
                          searchSnapshot.documents[index].data["nickname"],
                      "username1": currentUserId,
                      "date": DateTime.now(),
                      "msg": ""
                    };
                    Firestore.instance
                        .collection("chatrooms")
                        .document(
                            searchSnapshot.documents[index].data["nickname"] +
                                currentUserId)
                        .setData(chatInfo);

                    Navigator.push(
                        context,
                        (MaterialPageRoute(builder: (context) {
                          return ChatRoom(
                            snapShot: searchSnapshot,
                          );
                        })));
                  },
                  leading: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
                          strokeWidth: 2,
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(20.0),
                      ),
                      imageUrl:
                          searchSnapshot.documents[index].data["photoUrl"],
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(125)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  title: Text(searchSnapshot.documents[index].data["nickname"]),
                  subtitle: Text(
                    searchSnapshot.documents[index].data["aboutMe"],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 16,
                );
              })
          : SingleChildScrollView(
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.group,
                        size: 200.0,
                        color: Colors.green,
                      ),
                      Text(
                        "Search Friends",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
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

// CachedNetworkImage(
//                       imageUrl:
//                           Searchsnapshot.documents[index].data["photoUrl"],
//                       fit: BoxFit.cover,
//                       width: 50,
//                       height: 50,
//                     ),
//StreamBuilder(
//stream: Firestore.instance.collection("user").snapshots(),
//builder: ((context, AsyncSnapshot snapshot) {
//if (snapshot.data == null) {
//return CircularProgressIndicator();
//}
//switch (snapshot.connectionState) {
//case ConnectionState.waiting:
//return Container(
//child: CircularProgressIndicator(),
//);
//break;
//default:
//return ListView.builder(
//itemCount: snapshot.data.documents.length,
//itemBuilder: (context, index) {
//return ListTile(
//onTap: () {
//Firestore.instance
//    .collection("chatrooms")
//    .document(snapshot
//    .data.documents[index].data["nickname"] +
//currentUserId)
//    .setData({
//"username1":
//snapshot.data.documents[index].data["nickname"],
//"username2": currentUserId,
//"date": DateTime.now(),
//"msg": "",
//});
//Navigator.push(
//context,
//(MaterialPageRoute(builder: (context) {
//return ChatRoom();
//})));
//},
//title: Text(
//snapshot.data.documents[index].data["nickname"]),
//subtitle: Text(snapshot
//    .data.documents[index].data["createdAt"]
//    .toString()),
//);
//});
//}
//})),

//
//        FutureBuilder(
//          future: Firestore.instance
//              .collection("user")
//              .where("nickname",
//                  isGreaterThanOrEqualTo: searchTextEditingController.text)
//              .getDocuments(),
//          builder: ((context, snapshot) {
//            return ListView.builder(
//                itemCount: Searchsnapshot.documents.length,
//                itemBuilder: (context, index) {
//                  return ListTile(
//                    title:
//                        Text(Searchsnapshot.documents[index].data["nickname"]),
//                  );
//                });
//          }),

// futureSearchResults == null
//     ? DisplayNoUser()
// DisplaySearchResults(),

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
              ),
              title: Text(
                eachUser.nickname,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Joined at: " +
                    DateFormat("dd MMMM, yyyy - hh,mm,aa").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(eachUser.createdAt),
                      ),
                    ),
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic),
              ),
            ),
          )
        ],
      ),
    );
  }
}
