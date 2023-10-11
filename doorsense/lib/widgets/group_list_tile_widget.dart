import 'package:doorsense/pages/group_page.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

import '../pages/manage_users.dart';

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

  @override
  void initState() {
    super.initState();
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
            widget.room.imageUrl!, fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(widget.room.name!),
      subtitle: Text("Admin(s): "),
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
