import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

class RegisterFingerprintPage extends StatefulWidget {
  final types.Room room;
  const RegisterFingerprintPage({super.key, required this.room});

  @override
  _RegisterFingerprintPageState createState() =>
      _RegisterFingerprintPageState();
}

class _RegisterFingerprintPageState extends State<RegisterFingerprintPage> {
  String username = '';
  String userImageUrl = '';
  List<String> fingerPrintHashList = [];

  Color connectionColor = Colors.transparent;

  BluetoothDevice? doorSenseDevice;
  Set<DeviceIdentifier> seen = {};

  String deviceName = '';

  List<int> readData = [];

  void setupBluetooth() async {
    // first, check if bluetooth is supported by your hardware
// Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // turn on bluetooth ourself if we can
// for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> scanForBluetooth() async {
    // Note: You must call discoverServices after every connection!
    // Setup Listener for scan results.
// device not found? see "Common Problems" in the README
    Set<DeviceIdentifier> seen = {};
    var subscription = FlutterBluePlus.scanResults.listen(
      (results) {
        for (ScanResult r in results) {
          if (seen.contains(r.device.remoteId) == false) {
            print(
                '${r.device.remoteId}: "${r.device.platformName}" found! rssi: ${r.rssi}');
            seen.add(r.device.remoteId);
          }
        }
      },
    );

// Start scanning
// Note: You should always call `scanResults.listen` before you call startScan!
    await FlutterBluePlus.startScan();
  }

  void connectToDevice() async {
    await doorSenseDevice!.connect();

    print("DoorSense successfully connected!!!");
    setState(() {
    connectionColor = Colors.green;
    });
  }

  void disconnectDevice() async {
    await doorSenseDevice!.disconnect();

    print("Doorsense successfully disconnected");
    setState(() {
      connectionColor = Colors.transparent;
    });
  }

  void searchForDevice() {
    // handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        //look for bluetooth with charateristic UUID 19B10000-E8F2-537E-4F6C-D104768A1214
        print("Scanning");
        try {
          // Start scanning for devices
          FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

          print("Searching for Doorsense...");

          // Listen for scanned devices
          FlutterBluePlus.scanResults.listen((scanResult) {
            for (var result in scanResult) {
              if (result.device.platformName == 'Doorsense' || result.device.platformName == 'Arduino') {
                // Found the DoorSense device
                doorSenseDevice = result.device;
                print("DoorSense found!!!");
                FlutterBluePlus.stopScan();
                if (doorSenseDevice != null) {
                  setState(() {
                    deviceName = doorSenseDevice!.platformName;
                  });
                  print(deviceName);

                }
                break;
              }
            }
          });
        } catch (e) {
          // Handle any errors that occur during the process
          print('Error: $e');
        }
        finally {
          connectToDevice();
        }
      } else {
        // show an error to the user, etc
        print("An error occurred");
      }
    });
  }

  Future<void> getUserInformation() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await userRef.get();

    setState(() {
      username = '${userDoc['firstName']} ${userDoc['lastName']}';
      userImageUrl = userDoc['imageUrl'];
    });
  }

  void getUserInfo() async {
    await getUserInformation();
  }

  void writeData(int data) async {
   List<BluetoothService> services = await doorSenseDevice!.discoverServices();
   services.forEach((element) async {
     var characteristics = element.characteristics;
     for (BluetoothCharacteristic c in characteristics) {
       if (c.properties.write) {
         await c.write([data]);
         print("Wrote data successfully!");
       }
     }
   });
  }

  void readIncomingData() async {
    List<BluetoothService> services = await doorSenseDevice!.discoverServices();
    services.forEach((element) async {
      var characteristics = element.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          readData = await c.read();
          print("Read data successfully!");
          print(readData);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    setupBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: connectionColor,
        title: const Text('Fingerprints'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                if (!doorSenseDevice!.isConnected) {
                  searchForDevice();
                }
                else {
                  disconnectDevice();
                }
              },
              icon: const Icon(Icons.bluetooth_rounded))
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
              backgroundImage: NetworkImage(userImageUrl),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'You: $username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: ListView.builder(
              itemCount: fingerPrintHashList.length,
              itemBuilder: (BuildContext context, int index) {
                print(fingerPrintHashList.length);
                if (index == 0) {
                  return Column(
                    children: [
                      const Text(
                          textAlign: TextAlign.center,
                          "You don\t have any fingerprints registered currently. Click below to get started!"),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_rounded))
                    ],
                  );
                } else {
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
                              title:
                                  const Text('Delete Registered Fingerprint?'),
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
                                      fingerPrintHashList.removeAt(index);
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
                }
              },
            )),
            GestureDetector(
                onTap: () {
                   if (doorSenseDevice == null) {
                      _showError(context, "Please connect to Doorsense Device via Bluetooth!");
                   }
                   else {
                     writeData(
                         0x04); //switch to the enrolling state for the hardware
                     _registerFingerprint(context);

                     //check if the read data is 0x01 then show the place finger again dialog
                      //if the read data is 0x02 then show the success dialog
                      readIncomingData();
                      if (readData[0] == 0x01) {
                        _placeFingerprintAgain(context);
                      }
                      else if (readData[0] == 0x02) {
                        _successFingerprintEnroll(context);
                      }

                   }
                },
                child: const Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Icon(Icons.fingerprint, size: 100),
                  ),
                  Positioned(
                      top: 0, right: 0, child: Icon(Icons.add_circle_rounded))
                ])),
          ],
        ),
      ),
    );
  }

  Future<void> _showError(BuildContext context, String error) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: const Text("OK!"))
          ],
        );
      },
    );
  }



  Future<void> _registerFingerprint(BuildContext context) {
    String text = "Place your finger on the fingerprint sensor";
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Fingerprint'),
          content: Text(text),
        );
      },
    );
  }

  Future<void> _placeFingerprintAgain(BuildContext context) {
    String text = "Remove your finger and place it again.";
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Fingerprint'),
          content: Text(text),
        );
      },
    );
  }

  Future<void> _successFingerprintEnroll(BuildContext context) {
    String text = "Fingerprint enrolled successfully!";
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: Text(text),
        );
      },
    );
  }
}
