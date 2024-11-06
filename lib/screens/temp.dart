import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Temp extends StatelessWidget {
  const Temp({super.key});
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app_rounded),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
      body: const Center(
        child: Text("Wassup"),
      ),
    );
  }
}
