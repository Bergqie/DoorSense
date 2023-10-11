import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/manage_users.dart';
import 'package:doorsense/pages/setting_page.dart';
import 'package:doorsense/pages/test_color_page.dart';
import 'package:doorsense/widgets/group_list_tile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

import '../flutter_chat_core/src/firebase_chat_core.dart';
import '../notification_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();
  bool isNotificationsMenuOpen = false;

  final TextEditingController groupCodeController =
      TextEditingController(text: '');

  String username = '';
  String imageUrl = '';

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
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Enter Group Code'),
                    content: const TextField(
                      decoration: InputDecoration(hintText: 'Group code'),
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                      cursorColor: Colors.blue,
                    ),
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
                        onPressed: () => {},
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        child: const Text(
                          'Join',
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
            icon: const Icon(Icons.group_add_rounded)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notification_add_rounded),
          ),
          IconButton(
              onPressed: () {
                //for new page
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              icon: const Icon(Icons.settings_rounded))
        ],
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: StreamBuilder<List<types.Room>>(
                    stream: FirebaseChatCore.instance.rooms(),
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            bottom: 200,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "You are not in any groups.\n\nClick below to create one!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                  onPressed: () async{
                                    await FirebaseChatCore.instance.createSingleRoom();
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_rounded,
                                    size: 60,
                                    color: Color(0xFFDFDEDE),
                                  )),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final room = snapshot.data![index];
                            return GroupListTile(
                            room: room,);
                          });
                    })),
          ],
        ),
      ),
    );
  }
}
// to send
// git add .
// git commit -m "context about the page"
