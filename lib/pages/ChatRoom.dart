import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  QuerySnapshot snapShot;
  ChatRoom({Key key, this.snapShot}) : super(key: key);
  @override
  _ChatRoomState createState() => _ChatRoomState(snapShot: snapShot);
}

class _ChatRoomState extends State<ChatRoom> {
  QuerySnapshot snapShot;
  final String currentUserId;

  _ChatRoomState({Key key, @required this.currentUserId, this.snapShot});
  TextEditingController _msgController = TextEditingController();

  sendMessage() {
    Firestore.instance
        .collection("chatrooms")
        .document(snapShot.documents[0].data["nickname"] + currentUserId)
        .updateData({"msg": _msgController.text}).catchError((err) {
      print("$err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snapShot.documents[0].data["nickname"]),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(child: ListView()),
            Container(
              margin: EdgeInsets.only(bottom: 20, right: 5, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Enter Message",
                        suffixIcon: IconButton(
                            color: Colors.red,
                            icon: Icon(Icons.send),
                            onPressed: () {
                              sendMessage();
                              print("okkkk");
                            }),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
