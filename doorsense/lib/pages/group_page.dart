import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/pages/register_fingerprint_page.dart';
import 'package:doorsense/widgets/contact_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> getGroupCode() async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.room.id);
    final roomDoc = await roomRef.get();
    setState(() {
      groupCode = roomDoc['groupCode'];
    });
  }

  void getGroupCodeInfo() async {
    await getGroupCode();
  }

  void checkAdminStatus() {
    if (widget.room.users.length == 1) {
       setState(() {
         adminName = "${widget.room.users.first.firstName} ${widget.room.users.first.lastName}";
         adminEmail = "${FirebaseAuth.instance.currentUser!.email}";
         adminImageUrl = widget.room.users.first.imageUrl!;

       });
    }
   }

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
    getGroupCodeInfo();
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
        title: Text(widget.room.name!),
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
            !isAdmin ? Text("Group Code: $groupCode", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),) : const SizedBox(height: 20),
            const SizedBox(height: 10,),
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
            Expanded(
                child: ListView.builder(
                  itemCount: widget.room.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: ClipOval(
                          child: index == 0
                              ? Image.network(widget.room.users.first.imageUrl!, fit: BoxFit.cover,)
                              : Image.network(faker.image.image(random: true), fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(index == 0
                          ? "You: ${widget.room.users.first.firstName} ${widget.room.users.first.lastName}"
                          : faker.person.name()),
                      subtitle: Text(index == 0
                          ? FirebaseAuth.instance.currentUser!.email!
                          : faker.internet.email()),
                      trailing: IconButton(
                        icon: index == 0 ? const Icon(Icons.fingerprint) : const Icon(Icons.delete),
                        onPressed: () {
                          if (index == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterFingerprintPage())
                            );
                          } else {
                            // Handle delete action for other items
                          }
                        },
                      ),
                    );
                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}
