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

  //a method that checks if all the information is valid. The selected date must be 18 years old starting from the current date
  bool isValid() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedImage == null ||
        selectedDate
            .isAfter(DateTime.now().subtract(const Duration(days: 18 * 365)))) {
      return false;
    }
    return true;
  }

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
      if (isValid()) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text, // Replace with your authentication logic
          password: passwordController.text,
        );
        String imageUrl = '';

        // Upload image to Firebase Storage
        if (selectedImage != null) {
          String uid = userCredential.user!.uid;
          final file = File(selectedImage!.path);
          try {
            final reference = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(uid)
                .child('profile_photo');
            await reference.putFile(file);
            final uri = await reference.getDownloadURL();
            setState(() {
              imageUrl = uri;
            });
          } catch (e) {
            print(e);
          }
        }

        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
              dob: selectedDate.toString(),
              firstName: firstNameController.text,
              fingerPrintHashList: [],
              id: userCredential.user!.uid,
              imageUrl: imageUrl,
              lastName: lastNameController.text,
              email: emailController.text),
        );

        // Navigate to the home page or another screen after registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        //Show alert dialogue that the information is not valid
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Invalid Information'),
              content: const Text(
                  'Please make sure you enter in all the information correctly'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
        backgroundColor: Colors.black,
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
                  selectedImage == null
                      ? const Text('No Image Selected')
                      : CircleAvatar(
                          backgroundImage: FileImage(selectedImage!),
                          radius: 50),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick an Image'),
                  ),
                  const SizedBox(height: 20.0),
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
                      autofillHints: const [AutofillHints.password],
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
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                        'Date of Birth: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
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
