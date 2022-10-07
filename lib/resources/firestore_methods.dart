import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/models/livestream_model.dart';

import 'package:twitch_clone/resources/storage_methods.dart';

import 'package:twitch_clone/provider/user_provider.dart';

import 'package:twitch_clone/utilis/toast_message.dart';

class FireStoreMethods {
  final StorageMethods storageMethods = StorageMethods();
  final _firestore = FirebaseFirestore.instance;
  Future<String> uploadinLiveStream(
      String title, Uint8List? file, BuildContext context) async {
    String channelID = '';
    final providerUser = Provider.of<UserProvide>(context, listen: false);
    try {
      if (title.isNotEmpty && file != null) {
        if (!((await _firestore
                .collection('liveStreamData')
                .doc('${providerUser.user.uid}${providerUser.user.username}')
                .get())
            .exists)) {
          var url = await storageMethods.uploadImageToSource(
              'LiveStreams', file, providerUser.user.uid);

          final String channelId =
              "${providerUser.user.uid}${providerUser.user.username}";
          channelID = channelId;
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
              .doc(channelId)
              .set(liveStream.toMap())
              .then((value) {})
              .onError((error, stackTrace) {
            Message.toatsMessage(error.toString());
            channelID = '';
          });
        } else {
          Message.toatsMessage("You cannot start two meetings at a time");
        }
      } else {
        Message.toatsMessage('Failed in Uploading');
      }
    } catch (e) {
      Message.toatsMessage(e.toString());
    }
    return channelID;
  }

  leaveChannel(String channelId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('liveStreamData')
          .doc(channelId)
          .collection('comments')
          .get();

      for (var i = 0; i < snapshot.docs.length; i++) {
        await _firestore
            .collection('liveStreamData')
            .doc(channelId)
            .collection('comments')
            .doc((snapshot.docs[i].data() as dynamic)['commentId'])
            .delete()
            .then((value) {})
            .onError((error, stackTrace) {
          Message.toatsMessage(error.toString());
        });
      }

      await _firestore
          .collection('liveStreamData')
          .doc(channelId)
          .delete()
          .onError((error, stackTrace) {
        Message.toatsMessage(error.toString());
      });
    } catch (e) {
      Message.toatsMessage(e.toString());
    }
  }

  updateViewCount(String channelId, bool isIncreasing) async {
    try {
      await _firestore.collection('liveStreamData').doc(channelId).update({
        'viewers': FieldValue.increment(isIncreasing ? 1 : -1)
      }).onError((error, stackTrace) {
        Message.toatsMessage(error.toString());
      });
    } catch (e) {
      Message.toatsMessage(e.toString());
    }
  }
}
