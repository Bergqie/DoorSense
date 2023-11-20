import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsense/flutter_chat_core/flutter_firebase_chat_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doorsense/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:swipe_to/swipe_to.dart';

class ActivityFeedItem extends StatefulWidget {
  final snap;
  final feedItemId;

  ActivityFeedItem({required this.snap, required this.feedItemId});

  @override
  State<ActivityFeedItem> createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  String _username = '';
  String _photoUrl = '';

  //Delete notification
  Future<String> deleteNotification(String feedItemId) async {
    String res = "Some error occurred";
    try {
      await FirebaseFirestore.instance
          .collection('feed')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('feedList')
          .doc(feedItemId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  void _deleteNotification(String feedItemId) async {
    await deleteNotification(feedItemId);
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return ' ${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return ' ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return ' ${difference.inHours} hours ago';
    } else {
      final formatter = DateFormat('MMMM d, yyyy');
      return ' ${formatter.format(timestamp)}';
    }
  }

  Widget preview = const SizedBox();
  Widget mediaPreview = const SizedBox();
  String textPreview = "";

  void showMediaPreview() {
    if (widget.snap['type'] == "request") {
      preview = SizedBox(
          height: 100,
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    acceptGroupCodeRequest(
                        widget.snap['userId'], widget.snap['groupCode']);
                  },
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                  )),
              IconButton(
                  onPressed: () {
                    declineGroupCodeRequest(
                        FirebaseAuth.instance.currentUser!.uid);
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                  ))
            ],
          ));
    } else {
      preview = Text("");
    }

    if (widget.snap['type'] == "request") {
      textPreview = " is requesting access to your group.";
    } else if (widget.snap['type'] == "accept") {
      textPreview = " accepted your group invite.";
    } else {
      textPreview = "";
    }
  }

  Future<void> getUserInformation() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.snap['userId']);
    final userDoc = await userRef.get();

    setState(() {
      _username = '${userDoc['firstName']} ${userDoc['lastName']}' ?? '';
      _photoUrl = userDoc['imageUrl'] ?? '';
    });
  }

  void getUserInfo() async {
    await getUserInformation();
  }

  void declineGroupCodeRequest(String userId) async {
    final userActivityFeedRef = FirebaseFirestore.instance
        .collection('feed')
        .doc(userId)
        .collection('feedList')
        .doc(widget.feedItemId)
        .delete();
  }

  void acceptGroupCodeRequest(String userId, String groupCode) async {
    final roomRef = FirebaseFirestore.instance.collection('rooms');
    final roomQuery = await roomRef.get();

    for (final roomSnapshot in roomQuery.docs) {
      if (roomSnapshot.data()['groupCode'] == groupCode) {
        roomSnapshot.reference.update({
          'userIds': FieldValue.arrayUnion([widget.snap['userId']]),
          'userRoles': {widget.snap['userId']: types.Role.user.toShortString()},
        });
      }
    }

    final userActivityFeedRef = FirebaseFirestore.instance
        .collection('feed')
        .doc(userId)
        .collection('feedList')
        .add({
      "type": "accept",
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "groupCode": groupCode,
      "date": DateTime.now().toString(),
    });

    declineGroupCodeRequest(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showMediaPreview();

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: SwipeTo(
        iconOnRightSwipe: Icons.delete_forever_rounded,
        onRightSwipe: () {
          _deleteNotification(widget.feedItemId);
        },
        child: ListTile(
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                      text: _username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: textPreview,
                  )
                ]),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_photoUrl),
            radius: 16,
          ),
          subtitle: Text(
            formatTimestamp(DateTime.parse(widget.snap['date'])),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: preview,
        ),
      ),
    );
  }
}
