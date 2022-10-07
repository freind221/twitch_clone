// ignore_for_file: use_build_context_synchronously, library_prefixes

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/config/agora_ids.dart';
import 'package:twitch_clone/pages/home_screen.dart';
import 'package:twitch_clone/provider/user_provider.dart';

import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/widgets/custom_button.dart';

class BroadCastingScreen extends StatefulWidget {
  static String routeName = '/broadcast';
  final String channelId;
  final bool isBroadcaster;
  const BroadCastingScreen(
      {Key? key, required this.isBroadcaster, required this.channelId})
      : super(key: key);

  @override
  State<BroadCastingScreen> createState() => _BroadCastingScreenState();
}

class _BroadCastingScreenState extends State<BroadCastingScreen> {
  late final RtcEngine _engine;
  bool localUserJoined = false;
  List<int> remoteUid = [];
  bool isSwitched = false;
  bool ismuted = false;
  @override
  void initState() {
    initEngine();
    super.initState();
  }

  Future<void> initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    joinChannel();
  }

  _addListeners() {
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: ((channel, uid, elapsed) {
      debugPrint('joinChannelSuccess $channel $uid $elapsed');
    }), userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }));
  }

  joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.camera, Permission.microphone].request();
    }
    await _engine.joinChannelWithUserAccount(token, 'twitch',
        Provider.of<UserProvide>(context, listen: false).user.uid);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if (('${Provider.of<UserProvide>(context, listen: false).user.uid}${Provider.of<UserProvide>(context, listen: false).user.username}') ==
        widget.channelId) {
      await FireStoreMethods().leaveChannel(widget.channelId);
    } else {
      await FireStoreMethods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        isSwitched = !isSwitched;
      });
    });
  }

  _muteAudio() {
    setState(() {
      ismuted = !ismuted;
    });
    _engine.muteLocalAudioStream(ismuted);
  }

  @override
  void dispose() {
    _engine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvide>(context).user;

    return WillPopScope(
        onWillPop: () async {
          await _leaveChannel();
          return Future.value(true);
        },
        child: SafeArea(
          child: Scaffold(
              bottomNavigationBar: widget.isBroadcaster
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: CustomButton(
                        text: 'End Stream',
                        onTap: () {
                          _leaveChannel();
                        },
                      ),
                    )
                  : null,
              body: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _renderVideo(user, false),
                          if ("${user.uid}${user.username}" == widget.channelId)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: _switchCamera,
                                  child: const Text('Switch Camera'),
                                ),
                                InkWell(
                                  onTap: _muteAudio,
                                  child: const Text('Mute'),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: const Text(
                                    'Start Screensharing',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  _renderVideo(user, isScreenSharing) {
    return AspectRatio(
      aspectRatio: 9 / 10,
      child: "${user.uid}${user.username}" == widget.channelId
          ? isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty
                  ? kIsWeb
                      ? RtcRemoteView.SurfaceView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                  : Container(),
    );
  }
}
