import 'package:doorsense/pages/manage_users.dart';
import 'package:doorsense/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

import '../notification_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();
  bool isNotificationsMenuOpen = false;

  final TextEditingController groupCodeController = TextEditingController(text: '');

  int itemLength = 1;
  List<String> groupNames = ["Ouch, That Hurtz LLC", "Baseball Team", "Biomedical Group LLC", ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        centerTitle: true,
        leading: IconButton(onPressed: (){
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
                      backgroundColor: MaterialStateProperty.all(Colors.white),
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
        }, icon: const Icon(Icons.group_add_rounded)),
        actions: [
          IconButton(onPressed: () {
          },
            icon: const Icon(Icons.notification_add_rounded),),
          IconButton(onPressed: () {
            //for new page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage())
            );
          }, icon: const Icon(Icons.settings_rounded))
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
              backgroundImage: const AssetImage('assets/images/doorsense.png'),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
             const Text(
              "Team Touch",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: itemLength == 0
                  ? Center(
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
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
                                    backgroundColor: MaterialStateProperty.all(Colors.white),
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
                      child: Center(
                        child: Text(
                          'Join Group',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : ListView.builder(
                itemCount: itemLength,
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
                    title: Text(groupNames[index]),
                    subtitle: const Text("Admin: John Smith"),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_circle_right_outlined),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ManageUsersPage())
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// to send
// git add .
// git commit -m "context about the page"