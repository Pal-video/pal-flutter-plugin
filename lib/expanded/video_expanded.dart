import 'package:flutter/material.dart';
import 'package:pal/expanded/video_container.dart';
import 'package:pal/widgets/user_card/user_card.dart';
import 'package:video_player/video_player.dart';

import '../overlays/pal_banner.dart';
import 'state_actions.dart';
import 'video_listener.dart';

const defaultBgColor = Color(0xFF191E26);

class VideoExpanded extends StatefulWidget {
  final bool testMode;
  final String videoAsset;
  final String userName;
  final String companyTitle;
  final String? avatarUrl;

  final Duration triggerEndRemaining;

  final Function? onSkip;
  final Function? close;
  final Function? onEndAction;
  final bool animateOnVideoEnd;

  final VideoPlayerController? videoPlayerController;
  final Color bgColor;

  final Widget? child;

  const VideoExpanded({
    Key? key,
    required this.videoAsset,
    this.onSkip,
    required this.userName,
    required this.companyTitle,
    this.triggerEndRemaining = const Duration(seconds: 0),
    this.onEndAction,
    this.avatarUrl,
    this.videoPlayerController,
    this.testMode = false,
    this.bgColor = defaultBgColor,
    this.animateOnVideoEnd = false,
    this.close,
    this.child,
  }) : super(key: key);

  @override
  VideoExpandedState createState() => VideoExpandedState();
}

@visibleForTesting
class VideoExpandedState extends State<VideoExpanded>
    with TickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
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

  late final Future<bool> videoFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.videoPlayerController != null) {
      videoPlayerController = widget.videoPlayerController!;
    } else {
      videoPlayerController = widget.videoAsset.startsWith("http")
          ? VideoPlayerController.network(widget.videoAsset)
          : VideoPlayerController.asset(widget.videoAsset);
    }
    videoListener = VideoListener(
      videoPlayerController!,
      onPositionChanged: _onPositionChangedListener,
    );
    _layoutFadeController.forward();
    videoFuture = videoListener.start(volume: 1, loop: false);
  }

  @override
  void dispose() {
    videoListener.dispose();
    _contentFadeController.dispose();
    _layoutFadeController.dispose();
    super.dispose();
  }

  _onPositionChangedListener(Duration remaining) {
    if (widget.onEndAction == null) {
      return;
    }
    if (remaining <= widget.triggerEndRemaining &&
        _contentFadeController.status == AnimationStatus.dismissed) {
      _contentFadeController.forward();
      _onEndVideo();
    }
  }

  void _onEndVideo() {
    if (widget.onEndAction != null && !widget.animateOnVideoEnd) {
      widget.onEndAction!();
    }
    if (widget.animateOnVideoEnd) {
      _layoutFadeController.reverse().then((_) {
        if (widget.onEndAction != null) {
          widget.onEndAction!();
        }
      });
    }
  }

  void _close([Intent? intent]) {
    if (widget.close != null) {
      videoListener.pause();
      _layoutFadeController.reverse().then((_) {
        widget.close!();
      });
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
                    future: videoFuture,
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
                        ratio: videoPlayerController!.value.aspectRatio,
                        contentSize: videoPlayerController!.value.size,
                        child: VideoPlayer(
                          videoPlayerController!,
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
              top: 60,
              child: InkWell(
                key: const ValueKey("palVideoSkip"),
                onTap: _skipVideo,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PalBanner(),
          ),
        ],
      ),
    );
  }
}
