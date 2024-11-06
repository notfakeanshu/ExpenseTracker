//Sign up Screen
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/widgets/user_image_picker.dart';

final firebaseAuth = FirebaseAuth.instance;

class Screen2 extends StatefulWidget {
  const Screen2({super.key});
  @override
  State<Screen2> createState() {
    return _Screen2State();
  }
}

class _Screen2State extends State<Screen2> {
  String enteredEmail = "";
  String userName = "";
  String name = "";
  File? selectedImage;
  bool isAuthenticating = false;

  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void onPickImage(File pickedImage) {
    setState(() {
      selectedImage = pickedImage;
    });
  }

  Future<bool> checkIfUsernameExists(String userName) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('userNames')
          .doc(userName)
          .get();
      return userData.exists;
    } catch (e) {
      print("Error yes NIGGAAA NIGGAAA checking username existence: $e");
      return false;
    }
  }

  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid || selectedImage == null) {
      return;
    }
    formKey.currentState!.save();

    setState(() {
      isAuthenticating = true;
    });

    bool userNameExists = await checkIfUsernameExists(userName);
    if (userNameExists) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username Already Exists")));
      setState(() {
        isAuthenticating = false;
      });
      return;
    }

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: enteredEmail, password: passwordController.text);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('userProfilePic')
          .child('$userName.jpeg');
      await storageRef.putFile(selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userName': userName,
        'name': name,
        'email': enteredEmail,
        'imageUrl': imageUrl,
        'friends': [],
        'amount':[],
      });

      await FirebaseFirestore.instance
          .collection('userNames')
          .doc(userName)
          .set({
        'userName': userName,
      });
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? "Authentication Failed!")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
        });
        firebaseAuth.signOut();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account Creation is Successful")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        UserImagePicker(
                          onPickImage: onPickImage,
                          isAuthenticating: isAuthenticating,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.account_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return "Username must be at least 4 characters";
                            }
                            if (value.trim().length > 20) {
                              return "Username must be less than 20 characters";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            userName = value!.trim();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.account_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return "Name must be at least 4 characters";
                            }
                            if (value.trim().length > 20) {
                              return "Name must be less than 20 characters";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            name = value!.trim();
                          },
                        ),
                        const SizedBox(height: 12),
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
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredEmail = value!.trim();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
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
                              return "Password must be at least 6 characters long";
                            }
                            if (value.trim().length > 20) {
                              return "Password must be less than 20 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim() != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
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
                              'SIGN UP',
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
