import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';

class ChatTextButton extends ConsumerWidget {
  final Function()? onTap;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  const ChatTextButton(
      {required this.onTap,
      required this.text,
      this.buttonColor,
      this.textColor,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        disabledBackgroundColor: buttonColor!.withAlpha(100),
        backgroundColor: buttonColor ?? Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Color(0xFF000E08),
          fontFamily: FontFamily.caros,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
