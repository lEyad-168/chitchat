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
        cursorColor: Colors.lightBlue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.lightBlue,
            fontSize: 14,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: themeMode == ThemeMode.light
                  ? Color(0xFFCDD1D0)
                  : Colors.lightBlue,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: themeMode == ThemeMode.light
                  ? Color(0xFFCDD1D0)
                  : Colors.lightBlue,
            ),
          ),
          errorStyle: TextStyle(
            fontFamily: FontFamily.circular,
            fontSize: 12,
            color: Colors.redAccent,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16,
            ),
      ),
    );
  }
}
