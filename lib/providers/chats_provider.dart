import 'dart:developer';
import 'dart:io';

import 'package:chat_task/models/chat_model.dart';
import 'package:chat_task/models/message_model.dart';
import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/utils/auth_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

export 'package:provider/provider.dart';

class ChatsProvider extends ChangeNotifier {
  final AuthClient _auth = AuthClient.instance;
  List<ChatModel>? chats;
  ChatModel? chat;
  List<UserModel>? users;

  Future<void> getChatOrCreate(UserModel otherUser) async {
    chat = null;
    notifyListeners();
    chat = await _auth.getChatOrCreate(otherUser);
    chats ??= [];
    chat?.messages ??= [];
    if (!(chats?.contains(chat) ?? false)) {
      chats?.add(chat ?? ChatModel());
    }
    notifyListeners();
  }

  Future<void> getUsers() async {
    users = await _auth.getUsers();
    final FirebaseAuth auth = FirebaseAuth.instance;
    users?.removeWhere((user) => user.id == auth.currentUser?.uid);
    notifyListeners();
  }

  Future<void> getChats() async {
    chats = null;
    notifyListeners();
    chats = await _auth.getChats();
    for (ChatModel chat in chats ?? []) {
      chat.messages = await getChatMessages(chat.id ?? '');
    }
    notifyListeners();
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    return await _auth.getChatMessages(chatId);
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  showNotification(RemoteNotification? msg) async {
    AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'com.example.uchat',
      'UChat',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'com.example.uchat',
      'UChat',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.max,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        40, msg!.title, msg.body, platformChannelSpecifics,
        payload: null);
  }

  void iOSPermission() async {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void showMyNotification(RemoteMessage? m) {
    if (Platform.isIOS) {
      iOSPermission();
    }
    FlutterRingtonePlayer.play(
        android: AndroidSounds.notification, ios: IosSounds.glass);
    showNotification(m!.notification);
  }

  void initialFCM(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      log('$m');
      showMyNotification(m);
    });
  }

  void initialOpenedAppFCM(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      log('$m');
      showMyNotification(m);
    });
  }
}
