import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMiniature extends StatefulWidget {
  final String videoAsset;
  final double radius;
  final Function onTap;

  const VideoMiniature({
    Key? key,
    required this.videoAsset,
    required this.radius,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VideoMiniature> createState() => _VideoMiniatureState();
}

class _VideoMiniatureState extends State<VideoMiniature> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset(widget.videoAsset);
  }

  Future _initVideo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(true);
      await _videoPlayerController.setVolume(0);
      await _videoPlayerController.play();
    } catch (_) {
      debugPrint("cannot load video");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initVideo(),
      builder: (context, snap) {
        if (snap.hasError) {
          // log error
          return Container();
        }
        return GestureDetector(
          onTap: () => widget.onTap(),
          child: ClipOval(
            clipper: _CenterClip(widget.radius),
            child: SizedBox(
              width: widget.radius,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(
                  _videoPlayerController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CenterClip extends CustomClipper<Rect> {
  final double radius;

  _CenterClip(this.radius);

  @override
  Rect getClip(Size size) {
    return Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2,
      ),
      width: radius,
      height: radius,
    );
  }

  @override
  bool shouldReclip(oldClipper) {
    return false;
  }
}
