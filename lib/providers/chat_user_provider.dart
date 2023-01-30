import 'dart:io';

import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/utils/auth_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

export 'package:provider/provider.dart';

class ChatUserProvider extends ChangeNotifier {
  UserModel user;
  ChatUserProvider(this.user);

  final AuthClient _auth = AuthClient.instance;

  Future<void> getUserById() async {
    user = await _auth.getUserById(user.id!);
    notifyListeners();
  }
}
