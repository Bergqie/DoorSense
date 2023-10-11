import 'package:doorsense/pages/register_fingerprint_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;

class GroupPage extends StatefulWidget {
  final types.Room room;
  const GroupPage({super.key, required this.room});
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final faker = Faker();

  bool isAdmin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ouch, That Hurtz LLC'),
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
              backgroundImage: NetworkImage(
                faker.image.image(random: true),
              ),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'Admin: John Smith',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Contact: johnsmith@thathurtz.com',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: isAdmin ? ListTile(
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: Image.network(widget.room.users.first.imageUrl!, fit: BoxFit.cover,),

                    ),
                  ),
                  title: Text("You: ${widget.room.users.first.firstName} ${widget.room.users.first.lastName}"),
                  subtitle: Text("${FirebaseAuth.instance.currentUser!.email}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.fingerprint),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterFingerprintPage())
                      );
                    },
                  ),
                ) : ListView.builder(
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: ClipOval(
                          child: Image.network(
                            faker.image.image(random: true),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(faker.person.name()),
                      subtitle: Text(faker.internet.email()),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
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
