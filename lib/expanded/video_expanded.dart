import 'package:flutter/material.dart';
import 'package:pal/expanded/video_container.dart';
import 'package:pal/widgets/user_card/user_card.dart';
import 'package:video_player/video_player.dart';

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
  final Function? onEndAction;
  final VideoPlayerController? videoPlayerController;
  final bool testMode;
  final Color bgColor;

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
  }) : super(key: key);

  @override
  VideoExpandedState createState() => VideoExpandedState();
}

@visibleForTesting
class VideoExpandedState extends State<VideoExpanded>
    with TickerProviderStateMixin {
  GlobalKey layoutKey = GlobalKey();
  double? layoutHeight;

  late VideoPlayerController videoPlayerController;
  late VideoListener videoListener;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    videoPlayerController = widget.videoPlayerController ??
        VideoPlayerController.asset(widget.videoAsset);
    videoListener = VideoListener(
      videoPlayerController,
      onPositionChanged: _onPositionChangedListener,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    videoListener.init();
  }

  @override
  void deactivate() {
    super.deactivate();
    videoListener.dispose();
    _animationController.dispose();
  }

  Future _initVideo() async {
    try {
      await videoPlayerController.setLooping(false);
      await videoPlayerController.setVolume(0);
      await Future.delayed(const Duration(milliseconds: 100));
      await videoPlayerController.initialize();
      await videoPlayerController.play();
    } catch (e, d) {
      debugPrint("Error while playing video: $e, $d");
    }
  }

  _onPositionChangedListener(Duration remaining) {
    if (widget.onEndAction == null) {
      return;
    }
    if (remaining <= widget.triggerEndRemaining &&
        _animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
      widget.onEndAction!();
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
        return VideoContainer(
          child: AspectRatio(
            aspectRatio: videoPlayerController.value.aspectRatio,
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.testMode
                      ? Container()
                      : VideoPlayer(
                          videoPlayerController,
                        ),
                ),
                Positioned.fill(
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      key: layoutKey,
                      color: widget.bgColor,
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
                        animation: fadeAnimation,
                        builder: (context, child) {
                          // this calculates the height of the layout as we don't know it
                          layoutHeight ??= getWidgetHeight(layoutKey);
                          return Transform.translate(
                            offset: Offset(
                              0,
                              -fadeAnimation.value * (layoutHeight! - 200),
                            ),
                            child: child!,
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
                if (widget.onSkip != null)
                  Positioned(
                    right: 24,
                    top: 16,
                    child: ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: () {
                        widget.onSkip!();
                      },
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
              ],
            ),
          ),
        );
      },
    );
  }

  Offset getWidgetPosition(GlobalKey key) {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  double getWidgetHeight(GlobalKey key) {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    return box.size.height;
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
