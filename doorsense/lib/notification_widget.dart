import 'package:flutter/material.dart';

class NotificationWidget extends StatefulWidget {
  final bool isNotificationMenuOpen;
  const NotificationWidget({Key? key, required this.isNotificationMenuOpen}) : super(key: key);

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text(
              'No new notifications',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Positioned(
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isNotificationMenuOpen ? 200 : 0,
              height: widget.isNotificationMenuOpen ? 200 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: widget.isNotificationMenuOpen
                  ? ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Notification ${index + 1}'),
                  );
                },
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
