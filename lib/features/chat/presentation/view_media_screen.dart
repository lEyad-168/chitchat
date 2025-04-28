import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/core/widgets/media_player_widget.dart';
import 'package:chitchat/features/auth/presentation/widgets/auth_back_button.dart';

class ViewMediaScreen extends ConsumerStatefulWidget {
  final String mediaUrl;
  const ViewMediaScreen({required this.mediaUrl, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewMediaScreenState();
}

class _ViewMediaScreenState extends ConsumerState<ViewMediaScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: AuthBackButton(),
        ),
        body: MediaPlayerWidget(
          mediaUrl: widget.mediaUrl,
          showControls: true,
          isVideo: widget.mediaUrl.split(".").last == "mp4",
        ),
      ),
    );
  }
}
