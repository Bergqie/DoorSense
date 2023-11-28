import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/flutter_chat_core/flutter_firebase_chat_core.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
Future<List<String>> getAdmins(String roomId) async {
  final roomQuery =
  await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

  final room = roomQuery.data()!;

  final userIds = room['userIds'] as List<dynamic>;
  final userRoles = room['userRoles'] as Map<dynamic, dynamic>;

  final admins = <String>[];

  for (var i = 0; i < userIds.length; i++) {
    if (userRoles[userIds[i]] == types.Role.admin.toShortString()) {
      admins.add(userIds[i] as String);
    }
  }

  return admins;
}

Future<String> getRoomName(String roomId) async {
  final roomQuery =
  await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

  final room = roomQuery.data()!;

  return room['name'];
}