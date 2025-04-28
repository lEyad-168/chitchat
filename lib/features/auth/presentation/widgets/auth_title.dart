import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthTitle extends ConsumerWidget {
  final String title1;
  final String title2;
  final double containerWidth;
  const AuthTitle(
      {required this.title1,
      required this.title2,
      required this.containerWidth,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: 8,
              width:
                  containerWidth, //change accordingly to the size of the text below
              decoration: BoxDecoration(
                color: Color(0xFF58C3b6),
              ),
            ),
            Text(
              title1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          title2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
