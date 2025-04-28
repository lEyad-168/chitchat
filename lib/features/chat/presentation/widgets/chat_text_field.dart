import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/core/theme/is_dark_mode.dart';
import 'package:chitchat/core/theme/theme_provider.dart';

class ChatTextField extends ConsumerWidget {
  final Function(String text)? onChanged;
  final Function(String text)? onSubmitted;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final String? hintText;
  const ChatTextField(
      {this.onChanged,
      this.onSubmitted,
      this.focusNode,
      this.hintText,
      required this.controller,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      //autofocus: true,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: themeMode == ThemeMode.light ? Colors.black : Colors.white,
            fontSize: 12,
          ),
      cursorColor: themeMode == ThemeMode.light ? Colors.black : Colors.white,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor:
            isDarkMode(ref, context) ? Color(0xFF192222) : Color(0xFFF3F6F6),
        hintText: hintText ?? "Write your messge",
        hintStyle: TextStyle(
          color: Color(0xFF797C7B),
          fontSize: 12,
          fontFamily: FontFamily.circular,
        ),
      ),
    );
  }
}
