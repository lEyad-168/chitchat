import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/chat/data/repositories/chat_repository.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/media/data/repositories/media_repository.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:chitchat/features/chat/presentation/providers/is_sending_media_provider.dart';

class SendMediaConfirmationScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String mediaFilePath;
  const SendMediaConfirmationScreen(
      {required this.chatId, required this.mediaFilePath, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SendMediaConfirmationScreenState();
}

class _SendMediaConfirmationScreenState
    extends ConsumerState<SendMediaConfirmationScreen> {
  late VideoPlayerController _controller;
  late double videoProgress;

  @override
  void initState() {
    videoProgress = 0.0;
    _controller = VideoPlayerController.file(File(widget.mediaFilePath))
      ..initialize().then(
        (value) => setState(() {}),
      )
      ..play();

    _controller.addListener(() {
      setState(() {
        videoProgress = _controller.value.position.inMilliseconds.toDouble();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final isSending = ref.watch(isSendingMediaProvider);

    final media = File(widget.mediaFilePath);
    final mediaFormat = media.path.split(".").last;
    final isVideo = mediaFormat == 'mp4';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: AuthBackButton(),
          title: Text(
            isVideo ? 'Send video' : 'Send image',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (mediaFormat == 'mp4')
              Expanded(
                child: Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              )
            else if (mediaFormat == 'jpg' ||
                mediaFormat == 'png' ||
                mediaFormat == 'jpeg')
              Expanded(
                child: Center(
                  // TODO: fix error when entering some imgs
                  // (happens when the img is already sent before)
                  // BUT IT DONT HAPPENED BEFORE WHEN SENT TWO IMGS IN A ROW
                  child: Image.file(
                    media,
                    width: double.maxFinite,
                    height: double.maxFinite,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (mediaFormat == 'mp4')
                    Slider(
                      value: videoProgress,
                      min: 0.0,
                      max: _controller.value.duration.inMilliseconds.toDouble(),
                      onChanged: (double value) {
                        _controller
                            .seekTo(Duration(milliseconds: value.toInt()));
                        setState(() {
                          videoProgress = value;
                        });
                      },
                    ),
                  if (mediaFormat == 'mp4')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${_controller.value.position.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_controller.value.position.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                        Text(
                            "${_controller.value.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_controller.value.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                      ],
                    ),
                  if (mediaFormat == 'mp4')
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      icon: Icon(_controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                    ),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder(
                          stream: chatRepo.getChatDetails(widget.chatId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ));
                            }
                            final chat = snapshot.data!;
                            final friendId = chat.participants!.firstWhere(
                              (id) => id != currentUser!.uid,
                              orElse: () => '',
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sending to:",
                                ),
                                const SizedBox(width: 10),
                                StreamBuilder(
                                    stream: userRepo.getUserDetails(friendId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final user = snapshot.data!;
                                      return Text(
                                        user.name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 14,
                                            ),
                                      );
                                    }),
                              ],
                            );
                          },
                        ),
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.lightBlue),
                          ),
                          onPressed: isSending
                              ? null
                              : () {
                                  _sendMedia(ref, media, isVideo);
                                },
                          icon: isSending
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : SvgPicture.asset(
                                  Assets.icons.send.path,
                                  colorFilter: ColorFilter.mode(
                                    isDarkMode(ref, context)
                                        ? Colors.white
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  height: 24,
                                ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMedia(WidgetRef ref, File mediaFile, bool isVideo) async {
    final mediaRepo = ref.read(mediaRepositoryProvider);

    ref.read(isSendingMediaProvider.notifier).state = true;

    final mediaUrl = await mediaRepo.uploadMedia(mediaFile, isVideo: isVideo);

    if (mediaUrl != null) {
      final chatRepo = ref.read(chatRepositoryProvider);
      chatRepo.sendMessage(widget.chatId, mediaUrl, true, isVideo);

      Fluttertoast.showToast(msg: isVideo ? 'Video sent' : 'Image sent');
      ref.read(isSendingMediaProvider.notifier).state = false;
      context.pop();
    } else {
      Fluttertoast.showToast(
          msg: isVideo ? 'Failed to send video' : 'Failed to send image');
      ref.read(isSendingMediaProvider.notifier).state = false;
    }
  }
}
