import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/modals/friend.dart';
import 'package:pennywise/screens/screen5.dart';
import 'package:pennywise/screens/screen6.dart';

class Screen4 extends StatefulWidget {
  const Screen4({super.key, required this.friend , required this.index});
  final Friend friend;
  final int index;
  @override
  State<Screen4> createState() {
    return _Screen4();
  }
}

class _Screen4 extends State<Screen4> {
  final currentuserid = FirebaseAuth.instance.currentUser!.uid;
  late String currusername;
  late Future<String> currusernameFuture;
  int currindex = 0;
  int whichScreen = 5; //5=>Screen5 , 6=>Screen6

  @override
  void initState() {
    super.initState();
    currusernameFuture = getuserName();
  }

  Future<String> getuserName() async {
    final dataofcurruser = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentuserid)
        .get();
    return dataofcurruser.data()!['userName'];
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 209, 167, 125),
          onTap: (newindex) {
            setState(() {
              currindex = newindex;
              if (whichScreen == 5) {
                whichScreen = 6;
              } else {
                whichScreen = 5;
              }
            });
          },
          currentIndex: currindex,
          items: const [
            BottomNavigationBarItem(
                label: 'Expense', icon: Icon(Icons.monetization_on)),
            BottomNavigationBarItem(label: 'Chats', icon: Icon(Icons.chat)),
          ]),
      body: FutureBuilder(
          future: currusernameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              currusername = snapshot.data!;
              return (whichScreen == 5)
                  ? Screen5(
                      friend: widget.friend,
                      currusername: currusername,
                      index: widget.index,
                    )
                  : Screen6(
                      friend: widget.friend,
                      currusername: currusername,
                    );
            }
          }),
    );
  }
}
