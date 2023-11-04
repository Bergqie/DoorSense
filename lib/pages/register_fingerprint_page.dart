import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

class RegisterFingerprintPage extends StatefulWidget {
  const RegisterFingerprintPage({super.key});

  @override
  _RegisterFingerprintPageState createState() =>
      _RegisterFingerprintPageState();
}

class _RegisterFingerprintPageState extends State<RegisterFingerprintPage> {
  final faker = Faker();

  List<String> fingerprintList = ["Fingerprint 1", "Fingerprint 2", "Fingerprint 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Fingerprints'),
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
              backgroundImage: const AssetImage('assets/images/doorsense.png'),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'You: Team Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: ListView.builder(
              itemCount: fingerprintList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(child: Icon(Icons.fingerprint)),
                  ),
                  title: Text("Fingerprint ${index + 1}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Registered Fingerprint?'),
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
                                onPressed: () {
                                  setState(() {
                                    fingerprintList.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                                child: const Text(
                                  'Remove',
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
                  ),
                );
              },
            )),
            const Padding(
              padding:  EdgeInsets.only(bottom: 20.0),
              child:  Icon(Icons.fingerprint, size: 100),
            ),
          ],
        ),
      ),
    );
  }
}
