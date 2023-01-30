import 'dart:developer';

import 'package:chat_task/models/chat_model.dart';
import 'package:chat_task/models/message_model.dart';
import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/utils/vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthClient {
  AuthClient._();

  static final AuthClient instance = AuthClient._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get uid => auth.currentUser?.uid;

  Future<UserModel> registration(UserModel user, String pass) async {
    log('${user.toMap()}');
    await auth.createUserWithEmailAndPassword(
        email: user.email!, password: pass);
    await firestore.collection(UserVars.usersTable).doc(uid).set(user.toMap());
    await firestore
        .collection(UserVars.usersTable)
        .doc(uid)
        .update({UserVars.id: uid});
    final response =
        await firestore.collection(UserVars.usersTable).doc(uid).get();
    if (response.data()?.isNotEmpty ?? false) {
      return UserModel.fromMap(response.data()!);
    } else {
      throw response.data()!;
    }
  }

  Future<UserModel> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
    final response =
        await firestore.collection(UserVars.usersTable).doc(uid).get();
    if (response.data()?.isNotEmpty ?? false) {
      return UserModel.fromMap(response.data()!);
    } else {
      throw response.data()!;
    }
  }

  Future<UserModel> autoLogin() async {
    final response =
        await firestore.collection(UserVars.usersTable).doc(uid).get();
    if (response.data()?.isNotEmpty ?? false) {
      return UserModel.fromMap(response.data()!);
    } else {
      throw response.data()!;
    }
  }

  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<List<UserModel>> getUsers() async {
    final response = await firestore.collection(UserVars.usersTable).get();
    if (response.docs.isNotEmpty) {
      final List<UserModel> users = [];
      for (var user in response.docs) {
        users.add(UserModel.fromMap(user.data()));
      }
      return users;
    } else {
      return [];
    }
  }

  Future<ChatModel> getChatOrCreate(UserModel otherUser) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return Future.error('User does not exist');

    final userIds = [currentUser.uid, otherUser.id]..sort();

    final chatQuery = await firestore
        .collection(ChatVars.chatsTable)
        .where(ChatVars.userIDS, isEqualTo: userIds)
        .limit(1)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      final data = chatQuery.docs.first.data();
      final response = await firestore
          .collection(ChatVars.chatsTable)
          .doc(data[ChatVars.id])
          .collection(ChatVars.messages)
          .get();

      if (response.docs.isNotEmpty) {
        final List<MessageModel> messages = [];
        for (var message in response.docs) {
          messages.add(MessageModel.fromMap(message.data()));
        }
        data[ChatVars.messages] = messages;
      }
      return ChatModel.fromMap(data);
    }

    final oldChatQuery = await firestore
        .collection(ChatVars.chatsTable)
        .where(ChatVars.userIDS, isEqualTo: userIds.reversed.toList())
        .limit(1)
        .get();

    if (oldChatQuery.docs.isNotEmpty) {
      final data = chatQuery.docs.first.data();

      return ChatModel.fromMap(data);
    }

    final chat = await firestore.collection(ChatVars.chatsTable).add({
      ChatVars.createdAt: FieldValue.serverTimestamp(),
      ChatVars.updatedAt: FieldValue.serverTimestamp(),
      ChatVars.userIDS: userIds,
    });

    await firestore
        .collection(ChatVars.chatsTable)
        .doc(chat.id)
        .update({ChatVars.id: chat.id});

    final user = await autoLogin();

    final users = [user, otherUser];

    return ChatModel(
      id: chat.id,
      userIDS: userIds,
      users: users,
    );
  }

  Future<List<ChatModel>> getChats() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return Future.error('User does not exist');

    final response = await firestore
        .collection(ChatVars.chatsTable)
        .where(ChatVars.userIDS, arrayContains: currentUser.uid)
        .get();
    if (response.docs.isNotEmpty) {
      final List<ChatModel> chats = [];
      for (var chat in response.docs) {
        chats.add(ChatModel.fromMap(chat.data()));
      }
      return chats;
    } else {
      return [];
    }
  }

  Future<UserModel> getUserById(String id) async {
    final response =
        await firestore.collection(UserVars.usersTable).doc(id).get();
    if (response.data()?.isNotEmpty ?? false) {
      return UserModel.fromMap(response.data()!);
    } else {
      throw response.data()!;
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final response = await firestore
        .collection(ChatVars.chatsTable)
        .doc(chatId)
        .collection(ChatVars.messages)
        .orderBy(MessageVars.createdAt)
        .get();
    if (response.docs.isNotEmpty) {
      final List<MessageModel> messages = [];
      for (var message in response.docs) {
        messages.add(MessageModel.fromMap(message.data()));
      }
      return messages;
    } else {
      return [];
    }
  }

  Future<void> sendMessage(
      MessageModel message, UserModel otherUser, String chatID) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return Future.error('User does not exist');
    final userIds = [currentUser.uid, otherUser.id]..sort();

    final chat = await firestore
        .collection(ChatVars.chatsTable)
        .where(ChatVars.userIDS, isEqualTo: userIds)
        .limit(1)
        .get();
    final DocumentReference data = await firestore
        .collection(ChatVars.chatsTable)
        .doc(chat.docs.first.id)
        .collection(ChatVars.messages)
        .add(message.toMap());
    await firestore
        .collection(ChatVars.chatsTable)
        .doc(chat.docs.first.id)
        .update({ChatVars.updatedAt: DateTime.now()});
    await firestore
        .collection(ChatVars.chatsTable)
        .doc(chat.docs.first.id)
        .collection(ChatVars.messages)
        .doc(data.id)
        .update({MessageVars.id: data.id});
  }

  Future<void> updateStatus(bool online) async {
    await firestore
        .collection(UserVars.usersTable)
        .doc(uid)
        .update({UserVars.online: online});
  }

  Future<void> updateToken(String token) async {
    await firestore
        .collection(UserVars.usersTable)
        .doc(uid)
        .update({UserVars.token: token});
  }

  Stream<QuerySnapshot> getMessages(String chatID) {
    return firestore
        .collection(ChatVars.chatsTable)
        .doc(chatID)
        .collection(ChatVars.messages)
        .orderBy(ChatVars.createdAt, descending: true)
        .snapshots();
  }
}
