import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../animations/pop_anim.dart';
import '../expanded/video_listener.dart';

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
  late final AnimationController _fadeAnimController;

  late final Animation<double> opacityAnimation;

  late final Animation<double> sizeAnimation;

  late final VideoListener videoListener;

  late final Future<void> videoFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fadeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimController,
      curve: Curves.decelerate,
    ));
    sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimController,
      curve: Curves.ease,
    ));

    final videoPlayerController = widget.videoAsset.startsWith("http")
        ? VideoPlayerController.network(widget.videoAsset)
        : VideoPlayerController.asset(widget.videoAsset);
    videoListener = VideoListener(
      videoPlayerController,
      onVideoStarted: () {
        _fadeAnimController.forward();
      },
    );
    videoFuture = videoListener.start(
      volume: 0.0,
      loop: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoListener.dispose();
    _fadeAnimController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius,
      child: FutureBuilder(
        future: videoFuture,
        builder: (context, snap) {
          if (snap.hasError || !videoListener.isPlaying) {
            if (snap.hasError) {
              // log error
              debugPrint("Error loading video : ${snap.error}");
            }
            return Container(
              width: widget.radius,
              height: widget.radius,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            );
          }
          return PopAnimation(
            animation: _fadeAnimController,
            opacityAnim: opacityAnimation,
            sizeAnim: sizeAnimation,
            child: GestureDetector(
              onTap: () => _fadeAnimController.reverse().then((value) {
                HapticFeedback.mediumImpact();
                widget.onTap();
              }),
              child: ClipOval(
                clipBehavior: Clip.antiAlias,
                clipper: _CenterClip(widget.radius),
                child: AspectRatio(
                  aspectRatio: videoListener.controller.value.aspectRatio,
                  child: VideoPlayer(
                    videoListener.controller,
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
