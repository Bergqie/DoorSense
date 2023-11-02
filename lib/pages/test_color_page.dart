import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_sign_in/google_sign_in.dart';

import 'home_page.dart';

class TestColorPage extends StatefulWidget {
  const TestColorPage({super.key});

  @override
  State<TestColorPage> createState() => _TestColorPageState();
}

class _TestColorPageState extends State<TestColorPage> {
  FocusNode? _focusNode;
  bool _loggingIn = false;
  bool _registering = false;
  TextEditingController? _passwordController;
  TextEditingController? _usernameController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _passwordController = TextEditingController(text: 'Qawsed1-');
    _usernameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF164569),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  const Text("#164569", style: TextStyle(color: Color(0xFF4462C9)),)
                ],
              ),
              const SizedBox(width: 25,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF194374),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  const Text("#194374", style: TextStyle(color: Color(0xFF4462C9)),)
                ],
              ),
              const SizedBox(width: 25,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF0D223A),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  const Text("#0D223A", style: TextStyle(color: Color(0xFF4462C9)),)
                ],
              ),
            ],
        ));
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loggingIn = true;
    });

    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController!.text,
        password: _passwordController!.text,
      );
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.user!.uid);
      userRef.update({
        'lastSeen': DateTime.now(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _loggingIn = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

//write a method that logins the user in using with Google and registers them in the database
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    //create a new user in the database
    final user = await FirebaseAuth.instance.signInWithCredential(credential);
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.user!.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      // await FirebaseChatCore.instance.createUserInFirestore(
      //   types.User(
      //     firstName: user.user!.displayName,
      //     id: user.user!.uid,
      //     imageUrl: user.user!.photoURL,
      //     lastName: '',
      //   ),
      // );
      user.user!.sendEmailVerification();
    } else {
      userRef.update({
        'lastSeen': DateTime.now(),
      });
    }
    if (user.user!.emailVerified == false) user.user!.sendEmailVerification();
    Navigator.of(context).pop();
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
