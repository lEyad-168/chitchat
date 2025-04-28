import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContentBackground extends ConsumerWidget {
  final double height;
  final Widget child;
  const HomeContentBackground(
      {required this.height, required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: child,
    );
  }
}
