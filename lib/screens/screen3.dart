import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pennywise/modals/friend.dart';
import 'package:pennywise/widgets/friends_list.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() {
    return _Screen3();
  }
}

class _Screen3 extends State<Screen3> {
  bool isAuthenticating = false;
  bool isFetching = false;
  final TextEditingController userName = TextEditingController();
  late final String uuid;
  List<Friend> friends = [];
  double totalAmount = 0;
  Color colorofAmount = Colors.blue;

  @override
  void initState() {
    super.initState();
    final currentuser = FirebaseAuth.instance.currentUser!;
    uuid = currentuser.uid;
    getFriendsFromFireStore();
  }

  Future<void> getFriendsFromFireStore() async {
    setState(() {
      isFetching = true;
    });
    try {
      final userData =
          await FirebaseFirestore.instance.collection('users').doc(uuid).get();
      List usernamesofFriends = userData.data()?['friends'] ?? [];
      List amountofFriends = userData.data()?['amount'] ?? [];

      final List<Friend> loadedFriends = [];
      double atm = 0;

      for (int i = 0; i < usernamesofFriends.length; i++) {
        final friendSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userName', isEqualTo: usernamesofFriends[i])
            .get();

        if (friendSnapshot.docs.isNotEmpty) {
          final friendUid = friendSnapshot.docs.first.id;
          final friendData = await FirebaseFirestore.instance
              .collection('users')
              .doc(friendUid)
              .get();

          double amount = (amountofFriends[i] is int)
              ? (amountofFriends[i] as int).toDouble()
              : amountofFriends[i];
          atm += amount;

          loadedFriends.add(Friend(
            userName: usernamesofFriends[i],
            name: friendData.data()!['name'],
            amount: amount,
            imageUrl: friendData.data()!['imageUrl'],
          ));
        }
      }

      setState(() {
        totalAmount = atm;
        friends = loadedFriends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Load List: $e')),
      );
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalAmount > 0) {
      colorofAmount = Colors.green;
    }
    if (totalAmount < 0) {
      colorofAmount = Colors.red;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      appBar: AppBar(
        title: Text(
          totalAmount.toString(),
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colorofAmount,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 209, 167, 125),
        actions: [
          IconButton(
            onPressed: () {
              getFriendsFromFireStore();
            },
            icon: const Icon(Icons.refresh),
            color: Colors.black,
          ),
          IconButton(
            onPressed: showLogoutDialogBox1,
            icon: const Icon(Icons.logout_outlined),
            color: Colors.black,
          ),
        ],
      ),
      body: isFetching
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : FriendsList(
              friends: friends,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddnewUserDialogBox,
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
    );
  }

  void showLogoutDialogBox1() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    userName.dispose();
    super.dispose();
  }

  Future<int> checkIfUsernameExists(String inputUserName) async {
    try {
      // Check if the user is trying to add themselves
      final currentUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(uuid).get();

      String currentUserName = currentUserDoc.data()?['userName'] ?? '';

      if (currentUserName == inputUserName) {
        return 3; // Adding themselves
      }

      // Check if the friend already exists in their list
      List<dynamic> friends = currentUserDoc.data()?['friends'] ?? [];
      if (friends.contains(inputUserName)) {
        return 2; // Friend already exists
      }

      // Check if the username exists in the database
      final userData = await FirebaseFirestore.instance
          .collection('userNames')
          .doc(inputUserName)
          .get();

      if (userData.exists) {
        return 1; // Username exists
      } else {
        return 0; // Username does not exist
      }
    } catch (e) {
      print("Error checking username existence: $e");
      return -1; // Error
    }
  }

  void addFriends(String userNameofFriend) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uuid).update({
        'friends': FieldValue.arrayUnion([userNameofFriend]),
      });

      final userdoc =
          await FirebaseFirestore.instance.collection('users').doc(uuid).get();
      List<dynamic> currentAmounts = userdoc.data()?['amount'] ?? [];
      currentAmounts.add(0);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uuid)
          .update({'amount': currentAmounts});

      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userNameofFriend)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        final friendUid = friendSnapshot.docs.first.id;
        final friendData = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendUid)
            .get();

        double amount = 0.0;

        setState(() {
          friends.add(Friend(
            userName: userNameofFriend,
            name: friendData.data()!['name'],
            amount: amount,
            imageUrl: friendData.data()!['imageUrl'],
          ));
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${friendData.data()!['name']} has been added as a friend!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend: $e')),
      );
    }
  }

  void checkforuserName() async {
    setState(() {
      isAuthenticating = true;
    });

    if (userName.text.trim().isEmpty || userName.text.trim().length < 4) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username must be at least 4 characters"),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
      return;
    }

    int userNameExists = await checkIfUsernameExists(userName.text.trim());
    setState(() {
      isAuthenticating = false;
    });

    // Handle the different cases
    switch (userNameExists) {
      case 0:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username does not exist")),
        );
        return;
      case 1:
        addFriends(userName.text.trim());
        break;
      case 2:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Friend already exists!")),
        );
        return;
      case 3:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Can't add yourself!")),
        );
        return;
      default:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error occurred")),
        );
        return;
    }

    userName.clear();
    Navigator.of(context).pop();
  }

  void showAddnewUserDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Add New User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: TextFormField(
            controller: userName,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.account_circle_rounded),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: checkforuserName,
              child: isAuthenticating
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }
}
