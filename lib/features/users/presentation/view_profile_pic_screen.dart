import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/widgets/media_player_widget.dart';
import 'package:chitchat/core/providers/firebase_auth_providers.dart';
import 'package:chitchat/features/users/data/repositories/user_repository.dart';
import 'package:chitchat/features/media/data/repositories/media_repository.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:chitchat/features/chat/presentation/providers/is_sending_media_provider.dart';

class ViewProfilePicScreen extends ConsumerStatefulWidget {
  final String userId;
  const ViewProfilePicScreen({required this.userId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProfilePicScreenState();
}

class _ViewProfilePicScreenState extends ConsumerState<ViewProfilePicScreen> {
  @override
  Widget build(BuildContext context) {
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final isSending = ref.watch(isSendingMediaProvider);

    return SafeArea(
      child: StreamBuilder(
        stream: userRepo.getUserDetails(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final user = snapshot.data;

          final hasValidPhoto =
              user!.photoURL != null && user.photoURL!.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: AuthBackButton(),
              title: Text(user.name!),
              centerTitle: true,
              actions: [
                if (user.uid == currentUser!.uid)
                  IconButton(
                    onPressed: () {
                      userRepo.removeUserProfilePic();
                      Fluttertoast.showToast(msg: 'Profile picture removed!');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                const SizedBox(width: 10),
              ],
            ),
            body: hasValidPhoto
                ? Hero(
                    tag: 'profilePic',
                    child: MediaPlayerWidget(
                      mediaUrl: user.photoURL!,
                      isVideo: false,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No profile picture yet!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        if (user.uid == currentUser.uid)
                          FilledButton.icon(
                            onPressed: isSending
                                ? null
                                : () {
                                    _pickAndSendMedia(ref);
                                  },
                            icon: isSending
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  )
                                : const Icon(Icons.add_a_photo),
                            label: isSending
                                ? const Text('Sending...')
                                : const Text('Add profile picture'),
                          ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _pickAndSendMedia(WidgetRef ref) async {
    // TODO: DOENS'T WORK IN WEB, FIX
    if (kIsWeb) {
      Fluttertoast.showToast(msg: "Not supported in web for now");
      return;
    }

    final userRepo = ref.watch(userRepositoryProvider);
    final mediaRepo = ref.read(mediaRepositoryProvider);

    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    final pickedFileFormat = pickedFile?.path.split(".").last;

    if (pickedFile != null && pickedFileFormat == "mp4" ||
        pickedFileFormat == "jpg" ||
        pickedFileFormat == "png" ||
        pickedFileFormat == "jpeg") {
      final mediaFile = File(pickedFile!.path);

      ref.read(isSendingMediaProvider.notifier).state = true;
      final mediaUrl = await mediaRepo.uploadMedia(mediaFile, isVideo: false);

      if (mediaUrl != null) {
        userRepo.updateUserProfilePic(photoURL: mediaUrl);
        context.pop();

        ref.read(isSendingMediaProvider.notifier).state = false;
        Fluttertoast.showToast(msg: 'Image sent');
      }
    } else if (pickedFileFormat == null) {
    } else {
      ref.read(isSendingMediaProvider.notifier).state = false;
      Fluttertoast.showToast(msg: "Invalid media format: $pickedFileFormat");
    }
  }
}
