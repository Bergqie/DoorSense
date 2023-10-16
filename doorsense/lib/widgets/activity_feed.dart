
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          height: 50,
          width: 50,
          child: Row(children: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.check_circle_rounded, color: Colors.green,)),
            IconButton(onPressed: (){}, icon: const Icon(Icons.delete_rounded, color: Colors.red,))
          ],)
      );
    } else {
      preview = Text("");
    }

    if (widget.snap['type'] == "like") {
      textPreview = " is requesting access to your group.";
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
      _username = '${userDoc['firstName']} ${userDoc['lastName']}'  ?? '';
      _photoUrl = userDoc['imageUrl'] ?? '';
    });
  }

  void getUserInfo() async {
    await getUserInformation();
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    showMediaPreview();

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: GestureDetector(
          onTap: () {
          },
          child: RichText(
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
        ),
        leading: const CircleAvatar(
          radius: 16,
        ),
        subtitle: Text(
          formatTimestamp(DateTime.parse(widget.snap['date'])),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: preview,
      ),
    );
  }
}
