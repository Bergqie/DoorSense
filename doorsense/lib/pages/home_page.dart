import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/flutter_chat_core/flutter_firebase_chat_core.dart';
import 'package:doorsense/flutter_chat_types/src/room.dart';
import 'package:doorsense/pages/notifications_page.dart';
import 'package:doorsense/pages/setting_page.dart';
import 'package:doorsense/widgets/group_list_tile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

import '../flutter_chat_core/src/firebase_chat_core.dart';
import '../notification_widget.dart';
import '../utils/util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  final TextEditingController groupCodeController =
      TextEditingController(text: '');

  String username = '';
  String imageUrl = '';

  List<types.Room> rooms = [];

  RoomType getRoomTypeFromString(String type) {
    switch (type) {
      case 'direct':
        return RoomType.direct;
      case 'group':
        return RoomType.group;
      default:
        return RoomType.direct; // Example default value
    }
  }

  Future<void> getUserInformation() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final userDoc = await userRef.get();
      setState(() {
        username = "${userDoc['firstName']} ${userDoc['lastName']}" ?? "NULL";
        imageUrl = userDoc['imageUrl'];
      });
    } catch (e) {
      print("An error occurred getting the information");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getUserInfo() async {
    await getUserInformation();
  }

  Stream<int> getNotificationsStream() {
    final notificationsRef = FirebaseFirestore.instance
        .collection('feed')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('feedList');

    return notificationsRef.snapshots().map((snapshot) => snapshot.size);
  }

  //Returns a list of type rooms that returns all the rooms in the firebase collection
  Future<void> getAllRooms() async {
    try {
      final roomRef = FirebaseFirestore.instance.collection('rooms');
      final roomQuery = await roomRef.get();

      rooms.clear(); // Clear the existing list if any

      for (final roomSnapshot in roomQuery.docs) {
        final room = Room(
            id: roomSnapshot.id,
            type: getRoomTypeFromString(roomSnapshot.data()['type']),
            users: [],
            groupCode: roomSnapshot.data()['groupCode']
            // Add other fields here based on your data model
            );

        rooms.add(room);
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      print('Error fetching rooms: $e');
    }
  }

  void getRooms() async {
    await getAllRooms();
    print('Rooms: ${rooms.length}');
  }

  void sendGroupCodeRequest(String userId, String groupCode) async {
    final userActivityFeedRef = FirebaseFirestore.instance
        .collection('feed')
        .doc(userId)
        .collection('feedList')
        .add({
      "type": "request",
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "groupCode": groupCode,
      "date": DateTime.now().toString(),
    });
  }

  void showRequestSent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Sent'),
          content: const Text(
              'Your request has been sent to the admin of the group.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getRooms();
  }

  @override
  void dispose() {
    super.dispose();
    groupCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    content: TextField(
                      controller: groupCodeController,
                      decoration: const InputDecoration(hintText: 'Group code'),
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
                        onPressed: () async {
                          for (int i = 0; i < rooms.length; i++) {
                            if (rooms[i].groupCode ==
                                groupCodeController.text) {
                              //get the admin of the group
                              List<String> admins =
                                  await getAdmins(rooms[i].id);
                              print(admins.length);
                              print(rooms[i].groupCode);
                              //send a request to the admin inside of the room that matches the group code
                              try {
                                sendGroupCodeRequest(
                                    admins[0], groupCodeController.text);
                                print("Request sent");
                              } catch (e) {
                                print("An error occurred sending the request");
                              } finally {
                                //Close the dialog
                                Navigator.of(context).pop();
                                //Show a dialogue saying the request was sent
                                showRequestSent();
                              }
                            } else {
                              //TODO: Throw an error saying the room doesn't exist
                              print(
                                  "ERROR: No room found with that group code");
                            }
                          }
                        },
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
          StreamBuilder<int>(
            stream: getNotificationsStream(),
            builder: (context, snapshot) {
              // Check if the Stream is still active and receiving data
              if (!snapshot.hasData) {
                return IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_rounded),
                );
              }

              // Get the notification count from the stream data
              int notificationCount = snapshot.data ?? 0;

              // Display the red circle with the notification count
              return Stack(children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ));
                  },
                  icon: Icon(Icons.notifications_rounded),
                ),
                notificationCount > 0
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationCount > 9
                                ? '9+'
                                : notificationCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
              ]);
            },
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
                        //although the user is not in any roomss get all of the rooms and add them to the list

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
                                  onPressed: () async {
                                    await FirebaseChatCore.instance
                                        .createSingleRoom();
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
                            return GroupListTile(room: room);
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
