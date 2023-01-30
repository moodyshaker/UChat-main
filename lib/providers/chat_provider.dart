import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_task/models/chat_model.dart';
import 'package:chat_task/models/message_model.dart';
import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/utils/auth_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import '../ui/widgets/error_pop_up.dart';
import '../ui/widgets/loading_widget.dart';
import '../utils/firebase.dart';

export 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  ChatModel chat;

  ChatProvider(this.chat);

  final AuthClient _auth = AuthClient.instance;

  Future<void> sendMessage(MessageModel message, UserModel otherUser) async {
    chat.messages?.add(message);
    notifyListeners();
    await _auth.sendMessage(message, otherUser, chat.id ?? '');
  }

  Stream<QuerySnapshot> getMessages() {
    return _auth.getMessages(chat.id ?? '');
  }

  Future<void> sendNotification({
    required String toToken,
    required String title,
    required String body,
  }) async {
     Response r= await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': toToken,
        },
      ),
    );
    log('notify body ${r.body}');
    log('notify status code ${r.body}');
  }

}
