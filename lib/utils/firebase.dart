import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseNotifications {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? fcm;

  static Future<String?> getFCM() async {
    fcm = await _firebaseMessaging.getToken();
    log('token -> $fcm');
    return fcm;
  }
}

final String serverToken =
    'AAAADWinbdI:APA91bFjMlqYsPrfNHbQcj-rzSlDwhuLt8Y4d8jJduKP4eeVyZ8T5xqPxA9K87UdJgxcZF4um1K5vSjFV73yteK9QLZOGAMcODfL6j0khD24YivxXWg1smXAO6VrNDZ7RaWl0tFocVxT';
