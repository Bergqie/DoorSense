import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

class RegisterFingerprintPage extends StatefulWidget {
  final types.Room room;
  const RegisterFingerprintPage({super.key, required this.room});

  @override
  _RegisterFingerprintPageState createState() =>
      _RegisterFingerprintPageState();
}

class _RegisterFingerprintPageState extends State<RegisterFingerprintPage> {
  String username = '';
  String userImageUrl = '';
  List<String> fingerPrintHashList = [];

  Future<void> getUserInformation() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await userRef.get();

    setState(() {
      username = '${userDoc['firstName']} ${userDoc['lastName']}';
      userImageUrl = userDoc['imageUrl'];
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Fingerprints'),
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
              backgroundImage: NetworkImage(userImageUrl),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'You: $username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: ListView.builder(
              itemCount: fingerPrintHashList.length,
              itemBuilder: (BuildContext context, int index) {
                print(fingerPrintHashList.length);
                if (index == 0) {
                  return Column(
                    children: [
                      const Text(
                          textAlign: TextAlign.center,
                          "You don\t have any fingerprints registered currently. Click below to get started!"),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_rounded))
                    ],
                  );
                }
                else {
                  return ListTile(
                    leading: const AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(child: Icon(Icons.fingerprint)),
                    ),
                    title: Text("Fingerprint ${index + 1}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  'Delete Registered Fingerprint?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      fingerPrintHashList.removeAt(index);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            )),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Icon(Icons.fingerprint, size: 100),
            ),
          ],
        ),
      ),
    );
  }
}
