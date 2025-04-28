import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';

class AuthSubtitle extends ConsumerWidget {
  final String subtitle;
  const AuthSubtitle({required this.subtitle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF797C7B),
        fontFamily: FontFamily.circular,
        fontSize: 14,
      ),
    );
  }
}
