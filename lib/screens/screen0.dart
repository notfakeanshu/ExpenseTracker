import 'package:flutter/material.dart';
import 'package:pennywise/screens/screen1.dart';
import 'package:pennywise/screens/screen2.dart';

class Screen0 extends StatelessWidget {
  const Screen0({super.key});

  @override
  Widget build(BuildContext context) {
    void openloginScreen() {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Screen1();
      }));
    }

    void openSignupScreen() {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Screen2();
      }));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      // body: Center(
      //   child: Container(
      //     margin: const EdgeInsets.symmetric(
      //         //   horizontal: double.infinity,
      //         //   vertical: double.infinity
      //         ),
      //     // height: 900,
      //     width: 390,
      //     child: Image.asset('assets/kelpo.jpeg'),
      //   ),
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Allows Column to take only as much space as needed 
            children: [
              // Logo and illustration (if any)
              const SizedBox(
                  height:
                      40), // Uncomment if you have space needed before greeting text

              // Greeting text
              Image.asset('assets/kelpo.jpeg'),
              const SizedBox(height: 90), // Space between text and buttons

              // Login and Signup buttons
              ElevatedButton(
                onPressed: openloginScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 107,
                  ),
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: openSignupScreen,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust the radius as needed
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal:
                        100, // Adjust the horizontal padding for desired button width
                  ),
                ),
                child: const Text(
                  'SIGNUP',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
