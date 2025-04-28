import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class MediaPlayerWidget extends ConsumerStatefulWidget {
  final bool showControls;
  final String mediaUrl;
  final bool isVideo;
  const MediaPlayerWidget({
    required this.mediaUrl,
    this.showControls = false,
    required this.isVideo,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends ConsumerState<MediaPlayerWidget> {
  late double videoProgress;
  late VideoPlayerController _controller;

  @override
  void initState() {
    if (widget.isVideo) {
      initVideo();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  void initVideo() {
    videoProgress = 0.0;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl))
      ..initialize().then(
        (value) => setState(() {}),
      )
      ..play();

    _controller.addListener(() {
      setState(() {
        videoProgress = _controller.value.position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: mediaPlayer(widget.isVideo)),
        if (widget.showControls)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (widget.isVideo)
                  Slider(
                    value: videoProgress,
                    min: 0.0,
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (double value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                      setState(() {
                        videoProgress = value;
                      });
                    },
                  ),
                if (widget.isVideo)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${_controller.value.position.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_controller.value.position.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                      Text(
                          "${_controller.value.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_controller.value.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                    ],
                  ),
                if (widget.isVideo)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget mediaPlayer(bool isVideo) {
    if (isVideo) {
      return Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Center(
        child: Image.network(
          widget.mediaUrl,
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.contain,
        ),
      );
    }
  }
}
