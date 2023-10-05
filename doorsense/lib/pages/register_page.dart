import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';


import 'home_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseStorage _storage =
  //     FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  String firstName = '';
  String lastName = '';
  String dob = '';
  File? selectedImage;

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _registerUser() async {
    try {
      // UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      //   email: 'user@example.com', // Replace with your authentication logic
      //   password: 'password',
      // );
      //
      // // Upload image to Firebase Storage
      // if (selectedImage != null) {
      //   String uid = userCredential.user!.uid;
      //   Reference ref = _storage.ref().child('user_images/$uid.jpg');
      //   UploadTask uploadTask = ref.putFile(selectedImage!);
      //
      //   // Wait for the image to be uploaded
      //   await uploadTask.whenComplete(() {
      //     // Get the download URL of the uploaded image
      //     ref.getDownloadURL().then((imageUrl) {
      //       print('Image URL: $imageUrl');
      //       // Save the image URL to the user's profile data
      //       // You can use Firebase Firestore or Realtime Database to store this data
      //     });
      //   });
      // }
      //
      // // Add code to save the user's first name, last name, and date of birth to Firebase
      // // Firestore or Realtime Database
      //
      // //TODO: Register User Here

      // Navigate to the home page or another screen after registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error: $e');
      // Handle registration errors here
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('Registration Page'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black26, Colors.blue[800] as Color],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Date of Birth: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                  ),
                  const SizedBox(height: 20.0),
                  selectedImage == null
                      ? const Text('No Image Selected')
                      : CircleAvatar(backgroundImage: FileImage(selectedImage!), radius: 50),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick an Image'),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
