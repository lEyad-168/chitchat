import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/assets.gen.dart';

class ChatProfilePic extends ConsumerWidget {
  final String? chatPhotoURL;
  final double? avatarRadius;
  final bool isOnline;
  const ChatProfilePic(
      {this.chatPhotoURL,
      required this.isOnline,
      this.avatarRadius = 26,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // check if the chatProfileURL is valid
    bool isChatPicValid = chatPhotoURL != null && chatPhotoURL!.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        isChatPicValid
            ? CircleAvatar(
                radius: avatarRadius,
                backgroundImage: NetworkImage(
                  chatPhotoURL ?? '',
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: SvgPicture.asset(
                  Assets.icons.user.path,
                  height: avatarRadius! * 2,
                ),
              ),
        isOnline
            ? Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color(0xFF0FE16D),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
