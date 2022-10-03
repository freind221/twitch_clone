// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/utilis/toast_message.dart';
import 'package:twitch_clone/models/user_model.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance.collection('users');

  Stream<User?> get authChanges => _auth.authStateChanges();
  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await _firestore.doc(uid).get();
      // Here we are gonna get the data from user that we stored in snap variable

      return snap.data();
    }
    return null;
  }

  setToProvider(BuildContext context) async {
    Provider.of<UserProvide>(context, listen: false).setUser(
        model.User.fromMap(await getCurrentUser(_auth.currentUser!.uid) ?? {}));
  }

  Future<bool> signupUser(String email, String password, String username,
      BuildContext context) async {
    bool res = false;
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      if (_auth.currentUser != null) {
        res = true;
        model.User user = model.User(
            uid: _auth.currentUser!.uid,
            username: username.trim(),
            email: email.trim());
        Provider.of<UserProvide>(context, listen: false).setUser(user);
        _firestore.doc(_auth.currentUser!.uid).set(user.toMap()).then((value) {
          Message.toatsMessage("Saved");
        }).onError((error, stackTrace) {
          Message.toatsMessage(error.toString());
        });
      }
    }).onError((error, stackTrace) {
      res = false;
      Message.toatsMessage(error.toString());
    });
    return res;
  }

  Future<bool> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    bool res = false;
    try {
      // Here in this line we got users credetials by which we can get user data easily
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        if (_auth.currentUser != null) {
          // Provider.of<UserProvide>(context, listen: false).setUser(
          //     model.User.fromMap(
          //         await getCurrentUser(_auth.currentUser!.uid) ?? {}));
          setToProvider(context);

          Message.toatsMessage('Logged in');
          res = true;
        }
      }
    } catch (e) {
      Message.toatsMessage(e.toString());
      res = false;
    }
    return res;
  }
}
