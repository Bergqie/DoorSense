import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/group_page.dart';
import 'package:doorsense/utils/util.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

class GroupListTile extends StatefulWidget {
  final types.Room room;
  const GroupListTile({super.key, required this.room});
  @override
  _GroupListTileState createState() => _GroupListTileState();
}

class _GroupListTileState extends State<GroupListTile> {
  List<String> admins = [];
  List<String> imageUrls = [];
  String roomName = '';

  String adminName = '';

  void getGroupAdmins() async {
    admins = await getAdmins(widget.room.id);
    roomName = await getRoomName(widget.room.id);
  }

  Future<void> getGroupAdminNames() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(admins[0]);
    final userDoc = await userRef.get();
    setState(() {
      adminName = '${userDoc['firstName']} ${userDoc['lastName']}';
    });
  }

  void getUserImages() async {
    for (int i = 0; i < widget.room.users.length; i++) {
      String url = await getUserImageUrl(widget.room.users[i].id);
      imageUrls.add(url);
    }
  }

  void getAdminNames() async {
    await getGroupAdminNames();
  }

  @override
  void initState() {
    super.initState();
    getGroupAdmins();
    // Delayed execution of getAdminNames
    Future.delayed(const Duration(milliseconds: 500), () {
      getAdminNames();
      getUserImages();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(5), // Add this line to remove padding around the ListTile
      leading: SizedBox(
          width: 100, // Set a fixed width for the leading widget
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < min(imageUrls.length, 4); i++) //limit the amount of photos to 4
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 0),
                  child: Align(
                    widthFactor: 0.5,
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          imageUrls[i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      title: Text(roomName),
      subtitle: widget.room.users.length == 1
          ? Text(
              "Admin(s): ${widget.room.users.first.firstName} ${widget.room.users.first.lastName}")
          : Text("Admin(s): $adminName"),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_circle_right_outlined),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupPage(
                        room: widget.room,
                      )));
        },
      ),
    );
  }
}
