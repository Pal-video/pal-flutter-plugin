import 'package:flutter/material.dart';

class VideoContainer extends StatelessWidget {
  final Widget child;
  final double ratio;
  final Size contentSize;

  const VideoContainer({
    Key? key,
    required this.child,
    required this.ratio,
    required this.contentSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: contentSize.width,
        height: contentSize.height,
        child: AspectRatio(
          aspectRatio: ratio,
          child: child,
        ),
      ),
    );
  }
}
