import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/utils/auth_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

export 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthClient _auth = AuthClient.instance;

  User? get currentUser => auth.currentUser;
  bool get authLogged => currentUser != null;
  UserModel? user;

  String verificationId = '';
  String smsCode = '';

  Future<void> registration(String pass) async {
    user = await _auth.registration(user!, pass);
    notifyListeners();
  }

  verifyOTP() {
    PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<void> login(String email, String password) async {
    user = await _auth.login(email, password);
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (user != null) return true;

    if (!authLogged) return false;

    try {
      user = await _auth.autoLogin();
      return true;
    } on FirebaseAuthException catch (e) {
      await logout();
      return false;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.resetPassword(email);
  }

  Future<void> updateStatus(bool online) async {
    await _auth.updateStatus(online);
  }

  Future<void> updateToken(String token) async {
    await _auth.updateToken(token);
  }

  Future<void> logout() async {
    await updateStatus(false);
    await auth.signOut();
    user = null;
    notifyListeners();
  }
}
