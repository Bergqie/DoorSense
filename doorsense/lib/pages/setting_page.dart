import 'package:faker/faker.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}


// for top bar
class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
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
                  "Team Touch",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Container(
                //   width: double.infinity,
                //   height: 50,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(25),
                //     boxShadow: const [
                //       BoxShadow(
                //         color: Colors.black12,
                //         offset: Offset(0, 8),
                //         blurRadius: 8,
                //       ),
                //     ],
                //   ),
                //   child: Material(
                //     color: Colors.transparent,
                //     child: InkWell(
                //       onTap: () {
                //       },
                //       child: Center(
                //         child: Text(
                //           'GROUP CODE: HWF946',
                //           style: TextStyle(
                //             fontSize: 18,
                //             color: Colors.blue[800],
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Center(
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
                          },
                          child: Center(
                            child: Text(
                              'LOG OUT',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ],
            )
        )
    );
  }
}