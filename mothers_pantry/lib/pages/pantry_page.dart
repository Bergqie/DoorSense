import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Item {
  final String name;
  final String imageUrl;
  int quantity;

  Item({required this.name, required this.imageUrl, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final List<Item> items = [];
  final TextEditingController nameController = TextEditingController();
  int quantity = 1;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    prefs = await SharedPreferences.getInstance();
    final List<String>? itemsJson = prefs.getStringList('items');
    if (itemsJson != null) {
      items.clear();
      itemsJson.forEach((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(
            jsonDecode(json) as Map<String, dynamic>);
        items.add(Item.fromMap(map));
      });
      setState(() {});
    }
  }

  Future<void> saveItems() async {
    final List<String> itemsJson =
    items.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList('items', itemsJson);
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile =
    await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        items.add(Item(
          name: nameController.text,
          imageUrl: pickedFile.path,
          quantity: quantity,
        ));
        nameController.clear();
        quantity = 1;
        saveItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Image.file(File(items[index].imageUrl)),
              title: Text(items[index].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        items[index].quantity--;
                        saveItems();
                      });
                    },
                    icon: Icon(Icons.remove),
                  ),
                  Text('${items[index].quantity}'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        items[index].quantity++;
                        saveItems();
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}