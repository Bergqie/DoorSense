import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/welcome_page.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

// for top bar
class _SettingsPageState extends State<SettingsPage> {
  String username = '';
  String imageUrl = '';

  TextEditingController nameController = TextEditingController();

  Future<void> getUserInformation() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await userRef.get();
    setState(() {
      username = "${userDoc['firstName']} ${userDoc['lastName']}" ?? "NULL";
      imageUrl = userDoc['imageUrl'];
    });
  }

  void getUserInfo() async {
    await getUserInformation();
  }

  Future<void> pickImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadImage(pickedFile.path);
    }
  }

  Future<void> pickImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _uploadImage(pickedFile.path);
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    final File file = File(imagePath);
    final task = FirebaseStorage.instance
        .ref(FirebaseAuth.instance.currentUser!.uid)
        .child('profile_photo.jpg')
        .putFile(file);
    final snapshot = await task.whenComplete(() {});
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final uri = await snapshot.ref.getDownloadURL();
    setState(() {
      userRef.update({
        'imageUrl': uri,
      });
      imageUrl = uri;
    });
  }

  //update the username
  Future<void> _updateUsername() async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        userRef.update({
          'firstName': nameController.text.split(' ')[0],
          'lastName': nameController.text.split(' ')[1],
        });
        username = nameController.text;
      });
    } catch(e) {
      print(e);
    }
  }

  void showUploadOptions() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return SizedBox(
            height: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text("Take a Photo"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await pickImageFromCamera();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_rounded),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await pickImageFromGallery();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.blue[800] as Color],
              ),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Stack(children: [
                  GestureDetector(
                    onTap: () {
                      showUploadOptions();
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(imageUrl),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const Positioned(
                      top: 0, right: 0, child: Icon(Icons.edit_rounded)),
                ]),
                const SizedBox(height: 20),
                GestureDetector(onTap: () {
                  //prompt user to enter new username
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Change Username'),
                          content: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'i.e. John Doe',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _updateUsername();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      });
                },
                  child: Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ),
                const SizedBox(height: 20),
                Expanded(
                    child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const WelcomeScreen()),
                          );
                        },
                        child: Center(
                          child: Text(
                            'LOG OUT',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            )));
  }
}
