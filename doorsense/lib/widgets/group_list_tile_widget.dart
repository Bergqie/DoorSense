import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import '../pages/manage_users.dart';

class GroupListTile extends StatefulWidget {
  final String groupImageUrl;
  final String groupAdmins;
  final String groupName;
  const GroupListTile({
    super.key,
    required this.groupImageUrl,
    required this.groupAdmins,
    required this.groupName
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
            widget.groupImageUrl, fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(widget.groupName),
      subtitle: Text("Admin(s): ${widget.groupAdmins}"),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_circle_right_outlined),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManageUsersPage()));
        },
      ),
    );
  }
}
