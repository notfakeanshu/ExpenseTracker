import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class UserImagePicker extends StatefulWidget {
  const  UserImagePicker({super.key, required this.onPickImage,required this.isAuthenticating});
  final void Function(File pickedImage) onPickImage;
  final bool isAuthenticating;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePicker();
  }
}

class _UserImagePicker extends State<UserImagePicker> {
  File? pickedImageFile;

  void pickImage1() async {
    final pickImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickImage == null) return;
    setState(() {
      pickedImageFile = File(pickImage.path);
    });

    widget.onPickImage(pickedImageFile!);
  }

  void pickImage2() async {
    final pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage == null) return;
    setState(() {
      pickedImageFile = File(pickImage.path);
    });
    widget.onPickImage(pickedImageFile!);
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          foregroundImage: pickedImageFile == null
              ? const AssetImage('assets/dp.jpg')
              : FileImage(pickedImageFile!),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed:  widget.isAuthenticating ?null : pickImage1,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  // side: const BorderSide(color: Colors.blue),
                ),
                shadowColor: Colors.black54,
                elevation: 5,
              ),
            ),
            const SizedBox(width: 25),
            TextButton.icon(
              onPressed: widget.isAuthenticating ?null : pickImage2,
              icon: const Icon(Icons.image, color: Colors.white),
              label: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  //    side: const BorderSide(color: Colors.black),
                ),
                shadowColor: Colors.black54,
                elevation: 5,
              ),
            ),
          ],
        )
      ],
    );
  }
}
