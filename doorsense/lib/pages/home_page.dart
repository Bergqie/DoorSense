import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final faker = Faker();

  List<String> groupNames = ["Harry & Sons Electric Company", "Baseball Team", "Biomedical Group LLC", ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
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
              backgroundImage: NetworkImage(
                faker.image.image(random: true),
              ),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
             Text(
              faker.person.name(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
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
                    subtitle: Text("Admin: ${faker.person.name()}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_circle_right_outlined),
                      onPressed: () {},
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
