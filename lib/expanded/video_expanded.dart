import 'package:flutter/material.dart';
import 'package:pal/widgets/user_card/user_card.dart';
import 'package:video_player/video_player.dart';

class VideoExpanded extends StatefulWidget {
  final String videoAsset;
  final Function? onSkip;
  final String? onSkipText;
  final String userName;
  final String companyTitle;
  final String? avatarUrl;

  const VideoExpanded({
    Key? key,
    required this.videoAsset,
    this.onSkip,
    this.onSkipText,
    required this.userName,
    required this.companyTitle,
    this.avatarUrl,
  }) : super(key: key);

  @override
  _VideoExpandedState createState() => _VideoExpandedState();
}

class _VideoExpandedState extends State<VideoExpanded> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset(widget.videoAsset);
  }

  Future _initVideo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.setVolume(0);
    await _videoPlayerController.play();
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
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: VideoPlayer(
                      _videoPlayerController,
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: UserCard(
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
