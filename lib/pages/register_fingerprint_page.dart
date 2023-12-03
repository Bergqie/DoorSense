import 'dart:async';
import 'dart:convert';

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
  List<dynamic> fingerPrintHashList = [];

  Color connectionColor = Colors.transparent;

  BluetoothDevice? doorSenseDevice;
  Set<DeviceIdentifier> seen = {};

  String deviceName = '';

  String readData = 'Place your finger on the fingerprint sensor for a few seconds, remove it, then place the same finger again.';

  bool isRegistering = false;

  Timer? periodicTimer;

  Future<void> updateFingerprintList(int data) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      setState(() {
        fingerPrintHashList.add(data.toString());
      });

        await userRef.update({
          'fingerPrintHash': fingerPrintHashList});
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeFingerprint(int index) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      setState(() {
        fingerPrintHashList.removeAt(index);
      });

      await userRef.update({
        'fingerPrintHash': fingerPrintHashList});
    } catch (e) {
      print(e);
    }
  }

  void setNewFingerprint(int data) async {
    await updateFingerprintList(data);
  }

  void startReadingDataPeriodically() {
    const Duration interval =
        Duration(seconds: 1); // adjust the interval as needed

    setState(() {
      isRegistering = true;
    });

    writeData(0x04);
    _registerFingerprint(context);

    try {
      periodicTimer = Timer.periodic(interval, (Timer timer) {
        if (isRegistering) {
          readIncomingData();
        }
      });
    } catch (e) {
      print(e);
      // periodicTimer?.cancel();
    }
  }

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
    if (doorSenseDevice!.isConnected) {
      await doorSenseDevice!.disconnect();

      print("Doorsense successfully disconnected");
      // setState(() {
      //   connectionColor = Colors.transparent;
      // });
    }
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
              if (result.device.platformName == 'Doorsense' ||
                  result.device.platformName == 'Arduino') {
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
        } finally {
          connectToDevice();
        }
      } else {
        // show an error to the user, etc
        print("An error occurred");
      }
    });
  }

  int convertAsciiToInteger(int asciiCode) {
    if (asciiCode >= 0 && asciiCode <= 127) {
      // Subtract the ASCII code of '0' to get the corresponding integer value
      return asciiCode - '0'.codeUnitAt(0);
    } else {
      throw ArgumentError('ASCII code should be between 0 and 127');
    }
  }


  Future<void> getUserInformation() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await userRef.get();

    setState(() {
      username = '${userDoc['firstName']} ${userDoc['lastName']}';
      userImageUrl = userDoc['imageUrl'];
      fingerPrintHashList = userDoc['fingerPrintHash'];
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

  late Stream<List<int>> incomingDataStream;

  String bytesToString(List<int> bytes) {
    // Decode the bytes using utf8 encoding
    String result = utf8.decode(bytes);
    return result;
  }

  void readIncomingData() async {
    try {
      List<BluetoothService> services = await doorSenseDevice!.discoverServices(
          timeout: 60);
      for (BluetoothService service in services) {
        // Replace with the UUID of your service
        if (service.uuid == Guid('19B10000-E8F2-537E-4F6C-D104768A1214')) {
          for (BluetoothCharacteristic characteristic
          in service.characteristics) {
            // Replace with the UUID of your characteristic
            if (characteristic.uuid ==
                Guid('19B10002-E8F2-537E-4F6C-D104768A1214')) {
              List<int> value = await characteristic.read();

              if (value[0] == 82) {
                Navigator.of(context).pop();
                _placeFingerprintAgain(context);
              } else if (value[0] == 83) {
                Navigator.of(context).pop();
                _successFingerprintEnroll(
                    context, convertAsciiToInteger(value[1]));
              }
              else if (value[0] == 45) {
                Navigator.of(context).pop();
                _showError(context, "An error occurred while attempting to register your fingerprint. Please try again.");
              }

              break;
            }
          }
          break;
        }
      }
    } catch(e) {
      print(e);
    }
  }

  void deleteFingerPrintFromMCU(int fingerPrintId) async {
    List<BluetoothService> services = await doorSenseDevice!.discoverServices();
    for (BluetoothService service in services) {
      // Replace with the UUID of your service
      if (service.uuid == Guid('19B10000-E8F2-537E-4F6C-D104768A1214')) {
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          // Replace with the UUID of your characteristic
          if (characteristic.uuid ==
              Guid('19B10003-E8F2-537E-4F6C-D104768A1214')) {
            if (characteristic.properties.write) {
              await characteristic.write([fingerPrintId]);
              print("Data should delete from $fingerPrintId!");
            }

            break;
          }
        }
        break;
      }
    }
  }


  @override
    void initState() {
    super.initState();
    getUserInfo();
    setupBluetooth();
  }

  @override
  void dispose() {
    disconnectDevice();
    periodicTimer?.cancel();
    super.dispose();
  }

  void deleteAllFingerPrints() async {
    for (int i = 0; i < fingerPrintHashList.length + 1; i++) {
      await removeFingerprint(i);
    }
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
                // if (!doorSenseDevice!.isConnected || doorSenseDevice == null) {
                searchForDevice();
                // }
                // else {
                //  disconnectDevice();
                // }
              },
              icon: const Icon(Icons.bluetooth_rounded)),
          IconButton(onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title:
                  const Text('Delete ALL Registered Fingerprints?'),
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
                          deleteAllFingerPrints();
                          writeData(0x09);
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
          }, icon: const Icon(Icons.delete_forever_rounded))
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
                if (fingerPrintHashList.isEmpty) {
                  return const Text(
                      textAlign: TextAlign.center,
                      "You don't have any fingerprints registered currently. Click below to get started!");
                } else {
                  return ListTile(
                    leading: const AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(child: Icon(Icons.fingerprint)),
                    ),
                    title: Text("Fingerprint ${index + 1}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () {
                        if (doorSenseDevice == null) {
                            _showError(context, "Please connect to Doorsense Device via Bluetooth!");
                        }else {
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
                                        writeData(0x08);
                                        removeFingerprint(index);
                                        deleteFingerPrintFromMCU(fingerPrintHashList[index]);
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
                        }
                      },
                    ),
                  );
                }
              },
            )),
            GestureDetector(
                onTap: () {
                  if (doorSenseDevice == null) {
                    _showError(context,
                        "Please connect to Doorsense Device via Bluetooth!");
                  } else {
                    startReadingDataPeriodically();
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
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK!"))
          ],
        );
      },
    );
  }

  Future<void> _registerFingerprint(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
          return AlertDialog(
            title: const Text('Add Fingerprint'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter state) {
              return Text(readData);
            }),
          );
        });
      },
    );
  }

  Future<void> _placeFingerprintAgain(BuildContext context) {
    String text =
        'Remove your finger then place it again on the fingerprint sensor.';
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

  Future<void> _successFingerprintEnroll(BuildContext context, int data) {
    String text = "Fingerprint enrolled successfully!";
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: Text(text),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    isRegistering = false;
                  });
                  setNewFingerprint(data);
                  Navigator.of(context).pop();
                },
                child: const Text("OK!"))
          ],
        );
      },
    );
  }
}
