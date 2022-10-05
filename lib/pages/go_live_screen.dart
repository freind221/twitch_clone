import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/pages/broadcast_screen.dart';

import 'package:twitch_clone/resources/firestore_methods.dart';

import 'package:twitch_clone/utilis/colors.dart';
import 'package:twitch_clone/utilis/toast_message.dart';
import 'package:twitch_clone/widgets/custom_button.dart';
import 'package:twitch_clone/widgets/custom_textfield.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FireStoreMethods storeMethods = FireStoreMethods();
  Uint8List? image;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  liveStreamMeeting() async {
    Message.toatsMessage("Creating Meeting For you");
    bool res = await storeMethods.uploadinLiveStream(
        _titleController.text, image, context);

    if (res) {
      setState(() {
        isLoading = false;
      });

      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, BroadCastingScreen.routeName);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Uint8List? file = await Message.pickImage()
                          .onError((error, stackTrace) {
                        Message.toatsMessage(error.toString());
                      });

                      if (file != null) {
                        setState(() {
                          image = file;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 20.0,
                      ),
                      child: image != null
                          ? SizedBox(
                              height: 300,
                              child: Image.memory(image!),
                            )
                          : DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: buttonColor,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: buttonColor.withOpacity(.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open,
                                      color: buttonColor,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Select your thumbnail',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          message: '',
                          controller: _titleController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: CustomButton(
                  loading: isLoading,
                  text: 'Go Live!',
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    liveStreamMeeting();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
