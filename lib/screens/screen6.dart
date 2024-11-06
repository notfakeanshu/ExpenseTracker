//chat Screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/modals/friend.dart';

import '../modals/message.dart';

class Screen6 extends StatefulWidget {
  const Screen6({super.key, required this.friend , required this.currusername});
  final Friend friend;
  final String currusername;

  @override
  State<Screen6> createState() {
    return _Screen6();
  }
}

class _Screen6 extends State<Screen6> {
  final currentuserid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<String> getuserName() async {
    final dataofcurruser = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentuserid)
        .get();
    return dataofcurruser.data()!['userName'];
  }

  @override
  Widget build(context) {
    List<String> ids = [widget.friend.userName, widget.currusername];
    ids.sort();
    final String chatRoomId = ids.join('_');
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 209, 167, 125),
        body: Column(
          children: [
            Expanded(child: buildMessageList(chatRoomId)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 119, 103, 103),
                        hintStyle: const TextStyle(
                            color: Colors.white70), // Light hint color
                      ),
                      style: const TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.blue,
                    onPressed: () {
                      sendMessagefirebase(chatRoomId, widget.currusername);
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> sendMessagefirebase(
      String chatRoomId, String currusername) async {
    if (messageController.text.isEmpty) {
      return;
    }
    String tempmessage = messageController.text;
    messageController.clear();
    final Timestamp timestamp = Timestamp.now();
    Message message = Message(
      senderUsername: currusername,
      receiverUsername: widget.friend.userName,
      message: tempmessage,
      timestamp: timestamp,
    );
    try {
      await FirebaseFirestore.instance
          .collection('Room')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Message: $e')),
      );
    }
  }

  Stream<QuerySnapshot> getMessage(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('Room')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget buildMessageList(String chatRoomId) {
    return StreamBuilder(
        stream: getMessage(chatRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to Load Messages'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs.map((doc) {
              return buildMessageItem(doc);
            }).toList(),
          );
        });
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderUsername'] == widget.currusername;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.greenAccent : Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            data['message'],
            style: TextStyle(
              color: isCurrentUser ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
