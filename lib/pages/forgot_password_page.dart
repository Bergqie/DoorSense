import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/util.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  FocusNode? _focusNode;
  TextEditingController? _emailController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _emailController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _emailController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black26, Colors.blue[800] as Color],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: [
              const Text(
                "Enter in your email: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 5),
              TextField(
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                autofocus: true,
                controller: _emailController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  labelText: 'Email',
                  focusColor: Colors.purple,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _emailController?.clear(),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: () {
                  _focusNode?.requestFocus();
                },
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    onTap: _forgotPassword,
                    child: Center(
                      child: Text(
                        'Send email',
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
            ],
          ),
        ),
      ),
    );
  }

  void _forgotPassword() {
    String email = _emailController!.text;
    if (email.isEmpty || !email.contains("@")) {
      // Show an error message if the email is empty or doesn't contain an @domain
      const snackBar = SnackBar(
        content: Text('Please enter a valid email address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
      // Password reset email sent successfully
      // Show a message to the user to check their email
      const snackBar = SnackBar(
        content: Text('Email sent!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((error) {
      // An error occurred while trying to send password reset email
      // Show an error message to the user
      const snackBar = SnackBar(
        content: Text('Uh-oh! Something went wrong!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

}
