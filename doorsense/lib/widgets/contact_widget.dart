import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactWidget extends StatelessWidget {
  final String adminEmail;

  const ContactWidget(this.adminEmail, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          const TextSpan(
            text: 'Contact: ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: adminEmail,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Set the color for the email address
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _launchEmail(adminEmail);
              },
          ),
        ],
      ),
    );
  }

  _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(emailLaunchUri);
    }
    catch(e){
      throw 'Could not launch $email';
    }
  }
}
