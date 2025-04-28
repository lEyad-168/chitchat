import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/theme/is_dark_mode.dart';

class ChatIconButton extends ConsumerWidget {
  final String iconPath;
  final Color? backgroundColor;
  final Function() onPressed;
  const ChatIconButton(
      {this.backgroundColor,
      required this.onPressed,
      required this.iconPath,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStatePropertyAll(backgroundColor ?? Colors.transparent),
      ),
      onPressed: onPressed,
      icon: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          isDarkMode(ref, context) ? Colors.white : Colors.black,
          BlendMode.srcIn,
        ),
        height: 24,
      ),
    );
  }
}
