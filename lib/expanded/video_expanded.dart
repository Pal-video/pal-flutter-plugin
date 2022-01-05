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

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );
  late final fadeOutAnimation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(_animationController);

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
  }

  @override
  void deactivate() {
    super.deactivate();
    videoListener.dispose();
    _animationController.dispose();
  }

  Future<bool> _initVideo() async {
    try {
      await videoPlayerController.setLooping(false);
      await videoPlayerController.setVolume(0);
      await videoPlayerController.initialize();
      await Future.delayed(const Duration(milliseconds: 300));
      await videoPlayerController.play();
      await videoPlayerController.seekTo(Duration.zero);
      videoListener.init();
      return true;
    } catch (e, d) {
      debugPrint("Error while playing video: $e, $d");
    }
    return false;
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
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return Stack(
          children: [
            Positioned.fill(
              child: widget.testMode
                  ? Container()
                  : VideoContainer(
                      ratio: videoPlayerController.value.aspectRatio,
                      contentSize: videoPlayerController.value.size,
                      child: VideoPlayer(
                        videoPlayerController,
                      ),
                    ),
            ),
            Positioned.fill(
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  color: widget.bgColor,
                  child: widget.child,
                ),
              ),
            ),
            if (widget.onSkip != null)
              Positioned(
                right: 24,
                top: 40,
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
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: fadeOutAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: fadeOutAnimation.value,
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
        );
      },
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
