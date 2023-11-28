import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/register_fingerprint_page.dart';
import 'package:doorsense/widgets/contact_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

import '../utils/util.dart';

class GroupPage extends StatefulWidget {
  final types.Room room;
  const GroupPage({super.key, required this.room});
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool isAdmin = false;
  String adminName = '';
  String adminEmail = '';
  String adminImageUrl = '';
  String groupCode = '';

  String userName = '';
  String userEmail = '';
  String userImageUrl = '';

  Future<void> getGroupCode() async {
    final roomRef =
        FirebaseFirestore.instance.collection('rooms').doc(widget.room.id);
    final roomDoc = await roomRef.get();
    setState(() {
      groupCode = roomDoc['groupCode'];
    });
  }

  void getGroupCodeInfo() async {
    await getGroupCode();
  }

  List<String> admins = [];
  String roomName = '';

  void getGroupAdmins() async {
    admins = await getAdmins(widget.room.id);
    roomName = await getRoomName(widget.room.id);
  }

  List<types.User> roomUsers = [];

  //gets the list of types.User from the widget.room.users list
  List<types.User> getUsers() {
    List<types.User> users = [];
    for (int i = 0; i < widget.room.users.length; i++) {
      users.add(widget.room.users[i]);
    }
    return users;
  }

  // void getCurrentUserInformation() {
  //   for (int i = 0; i < roomUsers.length; i++) {
  //     //if the length is 1, then the current user is the only user in the room and is the admin
  //     if (roomUsers.length == 1) {
  //       setState(() {
  //         isAdmin = true;
  //         userName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //         userEmail = roomUsers[i].email!;
  //         userImageUrl = roomUsers[i].imageUrl!;
  //         adminName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //         adminEmail = roomUsers[i].email!;
  //         adminImageUrl = roomUsers[i].imageUrl!;
  //       });
  //     } else if (roomUsers[i].id == FirebaseAuth.instance.currentUser!.uid) {
  //
  //       if (admins.contains(roomUsers[i].id)) {
  //         setState(() {
  //           userName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //           userEmail = roomUsers[i].email!;
  //           userImageUrl = roomUsers[i].imageUrl!;
  //           isAdmin = true;
  //           adminName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //           adminEmail = roomUsers[i].email!;
  //           adminImageUrl = roomUsers[i].imageUrl!;
  //         });
  //       }
  //       else {
  //         setState(() {
  //           userName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //           userEmail = roomUsers[i].email!;
  //           userImageUrl = roomUsers[i].imageUrl!;
  //         });
  //       }
  //       // Move the current user to the first position in the list
  //       roomUsers.insert(0, roomUsers.removeAt(i));
  //     }
  //     //else if get the admin information
  //     else if (admins.contains(roomUsers[i].id)) {
  //       setState(() {
  //         isAdmin = true;
  //         adminName = "${roomUsers[i].firstName} ${roomUsers[i].lastName}";
  //         adminEmail = roomUsers[i].email!;
  //         adminImageUrl = roomUsers[i].imageUrl!;
  //       });
  //     }
  //   }
  // }

  void getCurrentUserInformation() {
    for (int i = 0; i < widget.room.users.length; i++) {
      //if the length is 1, then the current user is the only user in the room and is the admin
      if (widget.room.users.length == 1) {
        setState(() {
          isAdmin = true;
          userName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
          userEmail = widget.room.users[i].email!;
          userImageUrl = widget.room.users[i].imageUrl!;
          adminName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
          adminEmail = widget.room.users[i].email!;
          adminImageUrl = widget.room.users[i].imageUrl!;
        });
      } else if (widget.room.users[i].id == FirebaseAuth.instance.currentUser!.uid) {

        if (admins.contains(widget.room.users[i].id)) {
          setState(() {
            userName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
            userEmail = widget.room.users[i].email!;
            userImageUrl = widget.room.users[i].imageUrl!;
            isAdmin = true;
            adminName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
            adminEmail = widget.room.users[i].email!;
            adminImageUrl = widget.room.users[i].imageUrl!;
          });
        }
        else {
          setState(() {
            userName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
            userEmail = widget.room.users[i].email!;
            userImageUrl = widget.room.users[i].imageUrl!;
          });
        }
        // Move the current user to the first position in the list
        widget.room.users.insert(0, widget.room.users.removeAt(i));
      }
      //else if get the admin information
      else if (admins.contains(widget.room.users[i].id)) {
        setState(() {
          isAdmin = true;
          adminName = "${widget.room.users[i].firstName} ${widget.room.users[i].lastName}";
          adminEmail = widget.room.users[i].email!;
          adminImageUrl = widget.room.users[i].imageUrl!;
        });
      }
    }
  }

  TextEditingController nameController = TextEditingController();


  //update the username
  Future<void> _updateRoomName() async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.room.id);
      setState(() {
        userRef.update({
          'name': nameController.text,

        });
        roomName = nameController.text;
      });
    } catch(e) {
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    getGroupCodeInfo();
    getGroupAdmins();
    roomUsers = getUsers();
    Future.delayed(const Duration(milliseconds: 500), () {
      getCurrentUserInformation();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: GestureDetector(onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Update Room Name'),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'i.e. John\'s Vehicle',
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
                        _updateRoomName();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              });
        }, child: Text(roomName)),
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
            !isAdmin
                ? Text(
                    "Group Code: $groupCode",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                : const SizedBox(height: 20),
            const SizedBox(
              height: 10,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                adminImageUrl,
              ),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Admin: $adminName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ContactWidget(adminEmail),
            const SizedBox(height: 20),
            admins.contains(FirebaseAuth.instance.currentUser!.uid)
                ? Expanded(
                    child: ListView.builder(
                        itemCount: widget.room.users.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: ClipOval(
                                child: index == 0
                                    ? Image.network(
                                        userImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(roomUsers[index].imageUrl!,
                                        fit: BoxFit.cover),
                              ),
                            ),
                            title: Text(index == 0
                                ? "You: $userName"
                                : "${roomUsers[index].firstName} ${roomUsers[index].lastName}"),
                            subtitle: Text(index == 0
                                ? FirebaseAuth.instance.currentUser!.email!
                                : ''),
                            trailing: IconButton(
                              icon: index == 0
                                  ? const Icon(Icons.fingerprint)
                                  : const Icon(Icons.delete),
                              onPressed: () {
                                if (index == 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                               RegisterFingerprintPage(room: widget.room,)));
                                } else {
                                  // Handle delete action for other items
                                }
                              },
                            ),
                          );
                        }))
                : Expanded(
                    child: ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: Image.network(
                          userImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text("You: $userName"),
                    subtitle: Text(FirebaseAuth.instance.currentUser!.email!),
                    trailing: IconButton(
                      icon: const Icon(Icons.fingerprint),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                     RegisterFingerprintPage(room: widget.room,)));
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
