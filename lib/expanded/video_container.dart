import 'package:flutter/material.dart';

class VideoContainer extends StatelessWidget {
  final Widget child;

  const VideoContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
