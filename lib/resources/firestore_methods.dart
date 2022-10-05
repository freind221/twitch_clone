import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/livestream_model.dart';
import 'package:twitch_clone/resources/storage_methods.dart';
import 'package:twitch_clone/pages/onboarding_page.dart';
import 'package:twitch_clone/provider/user_provider.dart';

import 'package:twitch_clone/utilis/toast_message.dart';

class FireStoreMethods {
  final StorageMethods storageMethods = StorageMethods();
  final _firestore = FirebaseFirestore.instance;
  Future uploadinLiveStream(
      String title, Uint8List? file, BuildContext context) async {
    final providerUser = Provider.of<UserProvide>(context, listen: false);
    try {
      if (title.isNotEmpty && file != null) {
        var url = await storageMethods.uploadImageToSource(
            'LiveStreams', file, providerUser.user.uid);
        final String channelId =
            "${providerUser.user.uid}${providerUser.user.username}";
        LiveStream liveStream = LiveStream(
            title: title,
            image: url,
            uid: providerUser.user.uid,
            username: providerUser.user.username,
            viewers: 0,
            channelId: channelId,
            startedAt: DateTime.now());
        _firestore
            .collection('liveStreamData')
            .doc(providerUser.user.uid)
            .set(liveStream.toMap())
            .then((value) {
          Navigator.pushNamed(context, OnboardingScreen.routeName);
        }).onError((error, stackTrace) {
          Message.toatsMessage(error.toString());
        });
      } else {
        Message.toatsMessage('Failed in Uploading');
      }
    } catch (e) {
      Message.toatsMessage(e.toString());
    }
  }
}
