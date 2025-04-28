import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';
import 'package:chitchat/core/theme/theme_provider.dart';

class AuthTextField extends ConsumerWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String labelText;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    required this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        cursorColor: Color(0xFF5EBAAE),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF5EBAAE),
            fontSize: 14,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: themeMode == ThemeMode.light
                  ? Color(0xFFCDD1D0)
                  : Color(0xFF595E5C),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF5EBAAE)),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: themeMode == ThemeMode.light
                  ? Color(0xFFCDD1D0)
                  : Color(0xFF595E5C),
            ),
          ),
          errorStyle: TextStyle(
            fontFamily: FontFamily.circular,
            fontSize: 12,
            color: Color(0xFFFF2D1B),
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16,
            ),
      ),
    );
  }
}
