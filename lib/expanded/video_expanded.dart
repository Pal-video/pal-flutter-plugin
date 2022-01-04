import 'package:flutter/material.dart';
import 'package:pal/expanded/video_container.dart';
import 'package:pal/widgets/user_card/user_card.dart';
import 'package:video_player/video_player.dart';

import 'video_listener.dart';

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
  }) : super(key: key);

  @override
  VideoExpandedState createState() => VideoExpandedState();
}

@visibleForTesting
class VideoExpandedState extends State<VideoExpanded> {
  late VideoPlayerController videoPlayerController;
  late VideoListener videoListener;

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
  }

  Future _initVideo() async {
    try {
      await videoPlayerController.setLooping(false);
      await videoPlayerController.setVolume(1);
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
    if (remaining <= widget.triggerEndRemaining) {
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
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: UserCard.black(
                    userName: widget.userName,
                    companyTitle: widget.companyTitle,
                    imageUrl: widget.avatarUrl,
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
                  )
              ],
            ),
          ),
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
