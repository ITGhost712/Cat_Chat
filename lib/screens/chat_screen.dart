import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String messageText='';
  final _auth=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  late User loggedInuser;
  String? currentUser = '';
  void getCurrentUser() async{
    try{
    final user= await _auth.currentUser;
    if(user!=Null){
      loggedInuser=user!;
      currentUser=loggedInuser.email;
      print(loggedInuser.email);
      print(currentUser);
    }
    }
    catch(e) {
      print(e);
    }
    }
   /* void getMessages() async{
    final messages = await _firestore.collection('messages').get();
    for(var message in messages.docs){
      print(message.data());
    }
    }*/
  void messagesStream() async{
    await for(var snapshot in _firestore.collection('messages').snapshots()){
      for(var message in snapshot.docs){
        print(message.data());
      }
    }
  }
  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Center(child: Text('🐱️ Chat')),
        backgroundColor: Colors.grey.shade500,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context,snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
                  final messages = snapshot.data!.docs;
                  List<Widget> messageWidgets = [];
                  for(var message in messages){
                    if(snapshot.hasData){
                    final messageText = (message.data() as Map)['text'].toString();
                    final messageSender = (message.data() as Map)['sender'].toString();
                    final messageWidget =
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child:
                        Column(
                          crossAxisAlignment: messageSender == currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start ,
                          children: [
                            Text('$messageSender',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                              ) ,),
                            Material(
                              elevation: 8.0,
                              borderRadius: messageSender == currentUser ? BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)) : BorderRadius.only(topRight: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
                              color: messageSender == currentUser ? Colors.grey.shade600: Colors.teal,
                              child:
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                  child: Text('$messageText',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),),
                                ),
                            ),
                          ],
                        ),
                    );
                    messageWidgets.add(messageWidget);
                    }
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageWidgets,
                    ),
                  );
                throw("error");
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      color: Colors.black54,
                      child: TextField(
                        controller: messageController,
                        onChanged: (value) {
                          messageText=value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.grey.shade600,
                    child: TextButton(
                      onPressed: () {
                        //Implement send functionality. messages=sender+text
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInuser.email,
                        });
                        messageController.clear();
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
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
