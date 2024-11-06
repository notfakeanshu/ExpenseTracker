//Sign In Screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


final Firebase = FirebaseAuth.instance;

class Screen1 extends StatefulWidget {
  const Screen1({super.key});
  @override
  State<Screen1> createState() {
    return _Screen1();
  }
}

class _Screen1 extends State<Screen1> {
  String enteredEmail = "";
  String enteredPass = "";
  bool isAuthenticating = false;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void login() async {
      bool fucked = false;
      final isValid = formKey.currentState!.validate();
      if (!isValid) {
        return;
      }
      formKey.currentState!.save();
      setState(() {
        isAuthenticating = true;
      });

      try {
        final userCredentials = await Firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPass);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Welcome!")));
        setState(() {});
      } on FirebaseAuthException catch (error) {
        if (mounted) {
          fucked = true;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.message == null
                  ? "Authentication Failed!"
                  : error.message!)));
        }
      } finally {
        if (mounted) {
          setState(() {
            isAuthenticating = false;
          });
          if (!fucked) {
            Navigator.pop(context);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 167, 125),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 209, 167, 125)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return "Please enter a valid address";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredEmail = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "Password must be at least six characters long";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredPass = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (isAuthenticating) const CircularProgressIndicator(),
                        if (!isAuthenticating)
                          ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                                horizontal: 50,
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                      ],
                    ),
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
