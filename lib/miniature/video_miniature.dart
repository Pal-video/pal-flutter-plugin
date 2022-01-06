import 'package:flutter/material.dart';
import 'package:pal/animations/pop_anim.dart';
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

class _VideoMiniatureState extends State<VideoMiniature>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;

  late final AnimationController _fadeAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final opacityAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _fadeAnimController,
    curve: Curves.decelerate,
  ));

  late final sizeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _fadeAnimController,
    curve: Curves.ease,
  ));

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
      _fadeAnimController.forward();
    } catch (_) {
      debugPrint("cannot load video");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fadeAnimController.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius,
      child: FutureBuilder(
        future: _initVideo(),
        builder: (context, snap) {
          if (snap.hasError) {
            // log error
            return Container();
          }
          return PopAnimation(
            animation: _fadeAnimController,
            opacityAnim: opacityAnimation,
            sizeAnim: sizeAnimation,
            child: GestureDetector(
              onTap: () => _fadeAnimController
                  .reverse() //
                  .then((value) => widget.onTap()),
              child: ClipOval(
                clipBehavior: Clip.antiAlias,
                clipper: _CenterClip(widget.radius),
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
      ),
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
