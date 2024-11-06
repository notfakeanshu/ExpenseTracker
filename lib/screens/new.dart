import 'package:flutter/material.dart';

class New extends StatelessWidget {
  const New({super.key});

  @override
  Widget build(context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Hello asdadorld!",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
