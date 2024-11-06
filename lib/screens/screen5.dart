import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/modals/friend.dart';
import 'package:pennywise/screens/addExpense_Screen.dart';

class Screen5 extends StatefulWidget {
  const Screen5(
      {super.key,
      required this.friend,
      required this.currusername,
      required this.index});
  final Friend friend;
  final String currusername;
  final int index;

  @override
  State<Screen5> createState() => _Screen5State();
}

class _Screen5State extends State<Screen5> {
  late Future<double> ttlamount;

  @override
  void initState() {
    super.initState();
    ttlamount = getTotalSum();
  }

  //void changeamount(double atm) async {}
  Future<double> getTotalSum() async {
    double totalAmount = 0;
    List<String> ids = [widget.friend.userName, widget.currusername];
    ids.sort();
    final String chatRoomId = ids.join('_');
    final data = await FirebaseFirestore.instance
        .collection('Room')
        .doc(chatRoomId)
        .collection('expenses')
        .get();
    for (var doc in data.docs) {
      double amount = doc['amount'];
      if (doc['paidBy'] != widget.currusername) {
        amount = -amount;
      }
      totalAmount += amount;
    }
    //updating the amount in the Friends List
    final currentuser = FirebaseAuth.instance.currentUser!;
    final uuid = currentuser.uid;
    // Retrieve the current 'amount' array from Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uuid).get();
    List<dynamic> amounts = userDoc['amount'];
// Replace the value at the index
    amounts[widget.index] = totalAmount;

// Update the modified array in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uuid)
        .update({'amount': amounts});

    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    List<String> ids = [widget.friend.userName, widget.currusername];
    ids.sort();
    final String chatRoomId = ids.join('_');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                friend: widget.friend,
                currusername: widget.currusername,
              ),
            ),
          );
          setState(() {
            ttlamount = getTotalSum();
          });
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<double>(
        future: ttlamount,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            double totalAmount = snapshot.data ?? 0;
            return Column(
              children: [
                Expanded(child: buildExpenseList(chatRoomId)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total: Rs $totalAmount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Stream<QuerySnapshot> getExpenses(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('Room')
        .doc(chatRoomId)
        .collection('expenses')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget buildExpenseList(String chatRoomId) {
    return StreamBuilder<QuerySnapshot>(
      stream: getExpenses(chatRoomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to Load Expenses'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Expenses Found'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return buildExpenseItem(doc);
          }).toList(),
        );
      },
    );
  }

  Widget buildExpenseItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderUsername'] == widget.currusername;
    double amount = data['amount'];
    Color amountColor = (data['paidBy'] == widget.currusername)
        ? const Color.fromARGB(255, 0, 255, 8)
        : const Color.fromARGB(255, 255, 17, 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color.fromARGB(255, 207, 140, 24)
                : Colors.blueAccent,
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
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                data['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$amount Rs',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${data['date']} ${data['time']}',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.black54 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
