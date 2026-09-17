import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

class Launcher {
  static Future<void> makePhoneCall(String phoneNumber) async {
    log("message");
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}