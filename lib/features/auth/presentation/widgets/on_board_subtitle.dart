import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/gen/fonts.gen.dart';

class OnBoardSubtitle extends ConsumerWidget {
  const OnBoardSubtitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      "Our chat app is the perfect way to stay connected with friends and family.",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 16,
        fontFamily: FontFamily.circular,
        fontWeight: FontWeight.w100,
        
      ),
    );
  }
}
