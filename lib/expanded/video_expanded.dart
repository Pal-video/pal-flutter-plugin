import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pal/expanded/video_container.dart';
import 'package:pal/widgets/user_card/user_card.dart';
import 'package:video_player/video_player.dart';

import 'state_actions.dart';
import 'video_listener.dart';

const defaultBgColor = Color(0xFF191E26);

class VideoExpanded extends StatefulWidget {
  final String videoAsset;
  final Function? onSkip;
  final String? onSkipText;
  final String userName;
  final String companyTitle;
  final String? avatarUrl;
  final Duration triggerEndRemaining;
  final Function? close;
  final Function? onEndAction;
  final VideoPlayerController? videoPlayerController;
  final bool testMode;
  final Color bgColor;
  final Widget? child;

  const VideoExpanded({
    Key? key,
    required this.videoAsset,
    this.onSkip,
    this.onSkipText,
    required this.userName,
    required this.companyTitle,
    this.triggerEndRemaining = const Duration(seconds: 0),
    this.onEndAction,
    this.avatarUrl,
    this.videoPlayerController,
    this.testMode = false,
    this.bgColor = defaultBgColor,
    this.close,
    this.child,
  }) : super(key: key);

  @override
  VideoExpandedState createState() => VideoExpandedState();
}

@visibleForTesting
class VideoExpandedState extends State<VideoExpanded>
    with TickerProviderStateMixin {
  late VideoPlayerController videoPlayerController;
  late VideoListener videoListener;

  /// content fade animation
  late final AnimationController _contentFadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final contentFadeAnimation = CurvedAnimation(
    parent: _contentFadeController,
    curve: Curves.easeIn,
  );

  late final userCardFadeAnimation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(_contentFadeController);

  /// full layout animation
  late final AnimationController _layoutFadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final layoutFadeAnimation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _layoutFadeController,
    curve: Curves.easeOut,
  ));

  @override
  void initState() {
    super.initState();
    videoPlayerController = widget.videoPlayerController ??
        VideoPlayerController.asset(widget.videoAsset);
    videoListener = VideoListener(
      videoPlayerController,
      onPositionChanged: _onPositionChangedListener,
    );
    _layoutFadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    videoListener.dispose();
    _contentFadeController.dispose();
    _layoutFadeController.dispose();
  }

  // Future<bool> _initVideo() async {
  //   try {
  //     await videoPlayerController.initialize();
  //     await videoPlayerController.setLooping(false);
  //     await videoPlayerController.setVolume(1);
  //     await videoPlayerController.seekTo(Duration.zero);
  //     videoListener.init();
  //     await _layoutFadeController.forward();
  //     await Future.delayed(const Duration(milliseconds: 500), () async {
  //       await videoPlayerController.play();
  //     });
  //     return true;
  //   } catch (e, d) {
  //     debugPrint("Error while playing video: $e, $d");
  //   }
  //   return false;
  // }

  _onPositionChangedListener(Duration remaining) {
    if (widget.onEndAction == null) {
      return;
    }
    if (remaining <= widget.triggerEndRemaining &&
        _contentFadeController.status == AnimationStatus.dismissed) {
      _contentFadeController.forward();
      widget.onEndAction!();
    }
  }

  void _close([Intent? intent]) {
    if (widget.close != null) {
      _layoutFadeController //
          .reverse() //
          .then((_) => widget.close!());
    }
  }

  _skipVideo() async {
    if (widget.onSkip != null) {
      await _layoutFadeController.reverse();
      widget.onSkip!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: layoutFadeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(
            0, MediaQuery.of(context).size.height * layoutFadeAnimation.value),
        child: child!,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.testMode
                ? Container()
                : FutureBuilder(
                    future: videoListener.start(volume: 1, loop: false),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        // log error
                        return Container(color: Colors.black);
                      }
                      if (!snap.hasData) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      return VideoContainer(
                        ratio: videoPlayerController.value.aspectRatio,
                        contentSize: videoPlayerController.value.size,
                        child: VideoPlayer(
                          videoPlayerController,
                        ),
                      );
                    },
                  ),
          ),
          Positioned.fill(
            child: FadeTransition(
              opacity: contentFadeAnimation,
              child: Container(
                color: widget.bgColor,
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    CloseVideoIntent: CallbackAction<CloseVideoIntent>(
                      onInvoke: _close,
                    ),
                  },
                  child: widget.child ?? Container(),
                ),
              ),
            ),
          ),
          if (widget.onSkip != null)
            Positioned(
              right: 24,
              top: 40,
              child: ElevatedButton(
                key: const ValueKey("palVideoSkip"),
                style: raisedButtonStyle,
                onPressed: _skipVideo,
                child: Text(
                  widget.onSkipText ?? 'SKIP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: userCardFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: userCardFadeAnimation.value,
                      child: child,
                    );
                  },
                  child: UserCard.black(
                    userName: widget.userName,
                    companyTitle: widget.companyTitle,
                    imageUrl: widget.avatarUrl,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle get raisedButtonStyle => ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.black,
        minimumSize: const Size(88, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );
}
