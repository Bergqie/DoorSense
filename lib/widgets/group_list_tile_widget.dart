import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/group_page.dart';
import 'package:doorsense/utils/util.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;


class GroupListTile extends StatefulWidget {
  final types.Room room;
  const GroupListTile({
    super.key,
    required this.room
  });
  @override
  _GroupListTileState createState() => _GroupListTileState();
}

class _GroupListTileState extends State<GroupListTile> {

  List<String> admins = [];
  String roomName = '';

  String adminName = '';

  void getGroupAdmins() async {
    admins = await getAdmins(widget.room.id);
    roomName = await getRoomName(widget.room.id);
  }

  Future<void> getGroupAdminNames() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(admins[0]);
    final userDoc = await userRef.get();
    setState(() {
      adminName = '${userDoc['firstName']} ${userDoc['lastName']}';
    });
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: Image.network(
            widget.room.imageUrl!.isNotEmpty ? widget.room.imageUrl! : faker.image.image(random: true), fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(roomName),
      subtitle: widget.room.users.length == 1 ? Text("Admin(s): ${widget.room.users.first.firstName} ${widget.room.users.first.lastName}") : Text("Admin(s): $adminName"),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_circle_right_outlined),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GroupPage(room: widget.room,)));
        },
      ),
    );
  }
}
