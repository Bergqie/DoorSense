import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'dart:io';


import '../flutter_chat_core/src/firebase_chat_core.dart';
import 'home_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
   final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  FocusNode? _focusNode;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text, // Replace with your authentication logic
        password: passwordController.text,
      );
      String imageUrl = '';

      // Upload image to Firebase Storage
      if (selectedImage != null) {
        String uid = userCredential.user!.uid;
        Reference ref = _storage.ref().child('user_images/$uid.jpg');
        UploadTask uploadTask = ref.putFile(selectedImage!);

        // Wait for the image to be uploaded
        await uploadTask.whenComplete(() {
          // Get the download URL of the uploaded image
          ref.getDownloadURL().then((url) {
            print('Image URL: $url');
            // Save the image URL to the user's profile data
            // You can use Firebase Firestore or Realtime Database to store this data
            setState(() {
              imageUrl = url;
            });
          });
        });
      }

      // // Add code to save the user's first name, last name, and date of birth to Firebase
      // // Firestore or Realtime Database
      //
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          dob: selectedDate.toString(),
          firstName: firstNameController.text,
          fingerPrintHash: '',
          id: userCredential.user!.uid,
          imageUrl: imageUrl,
          lastName: lastNameController.text,
        ),
      );

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
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }
  @override
  void dispose() {
    super.dispose();
    _focusNode?.dispose();
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
                  TextField(
                    autocorrect: true,
                    autofillHints: [AutofillHints.username],
                    autofocus: true,
                    controller: firstNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      hintText: 'First Name',
                      suffix: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => firstNameController?.clear(),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    onEditingComplete: () {
                      _focusNode?.requestFocus();
                    },
                    // readOnly: _registering,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      autocorrect: true,
                      autofillHints: [AutofillHints.name],
                      autofocus: true,
                      controller: lastNameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        hintText: 'Last Name',
                        suffix: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => lastNameController.clear(),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      onEditingComplete: () {
                        _focusNode?.requestFocus();
                      },
                      // readOnly: _registering,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      autocorrect: false,
                      autofillHints: [AutofillHints.email],
                      autofocus: true,
                      controller: emailController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        hintText: 'Email',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => emailController.clear(),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onEditingComplete: () {
                        _focusNode?.requestFocus();
                      },
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      autocorrect: false,
                      autofillHints: [AutofillHints.password],
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => passwordController.clear(),
                        ),
                      ),
                      focusNode: _focusNode,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: true,
                      // onEditingComplete: _register,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.done,
                    ),
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
