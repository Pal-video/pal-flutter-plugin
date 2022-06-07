import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pal/animations/pop_anim.dart';
import 'package:video_player/video_player.dart';

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
    // _fadeAnimController.forward();
  }

  // Future _initVideo() async {
  //   try {
  //     await Future.delayed(const Duration(milliseconds: 100));
  //     await _videoPlayerController.initialize();
  //     await _videoPlayerController.setLooping(true);
  //     await _videoPlayerController.setVolume(0);
  //     await _videoPlayerController.play();
  //     _fadeAnimController.forward();
  //   } catch (err, stack) {
  //     debugPrint("--------------------");
  //     debugPrint("cannot load video");
  //     debugPrint("--------------------");
  //     debugPrintStack(stackTrace: stack);
  //   }
  // }

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
        future: videoListener.start(volume: 0, loop: true),
        builder: (context, snap) {
          if (snap.hasError || !videoListener.isPlaying) {
            // log error
            return Container(
              width: widget.radius,
              height: widget.radius,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            );
          }
          return Container();
          // return PopAnimation(
          //   animation: _fadeAnimController,
          //   opacityAnim: opacityAnimation,
          //   sizeAnim: sizeAnimation,
          //   child: GestureDetector(
          //     onTap: () => _fadeAnimController.reverse().then((value) {
          //       HapticFeedback.mediumImpact();
          //       widget.onTap();
          //     }),
          //     child: ClipOval(
          //       clipBehavior: Clip.antiAlias,
          //       clipper: _CenterClip(widget.radius),
          //       child: AspectRatio(
          //         aspectRatio: videoListener.controller.value.aspectRatio,
          //         child: VideoPlayer(
          //           videoListener.controller,
          //         ),
          //       ),
          //     ),
          //   ),
          // );
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
