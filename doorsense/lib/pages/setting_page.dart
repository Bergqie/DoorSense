import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/welcome_page.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}


// for top bar
class _SettingsPageState extends State<SettingsPage> {

  String username = '';
  String imageUrl = '';

  Future<void> getUserInformation() async {
    final userRef =  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await userRef.get();
    setState(() {
      username = "${userDoc['firstName']} ${userDoc['lastName']}" ?? "NULL";
      imageUrl = userDoc['imageUrl'];
    });
  }

  void getUserInfo() async {
    await getUserInformation();
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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Text(
                  username,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Container(
                //   width: double.infinity,
                //   height: 50,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(25),
                //     boxShadow: const [
                //       BoxShadow(
                //         color: Colors.black12,
                //         offset: Offset(0, 8),
                //         blurRadius: 8,
                //       ),
                //     ],
                //   ),
                //   child: Material(
                //     color: Colors.transparent,
                //     child: InkWell(
                //       onTap: () {
                //       },
                //       child: Center(
                //         child: Text(
                //           'GROUP CODE: HWF946',
                //           style: TextStyle(
                //             fontSize: 18,
                //             color: Colors.blue[800],
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
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
                              MaterialPageRoute(builder: (context) => WelcomeScreen()),
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
                  )
                ),
              ],
            )
        )
    );
  }
}