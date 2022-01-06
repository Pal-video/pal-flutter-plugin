import 'package:flutter/material.dart';

const _kTtranslation = 10;

class PopAnimation extends StatelessWidget {
  final Animation<double>? sizeAnim;
  final Animation<double>? opacityAnim;
  final Widget child;
  final Listenable animation;

  const PopAnimation({
    Key? key,
    this.sizeAnim,
    this.opacityAnim,
    required this.child,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          _kTtranslation - ((sizeAnim?.value ?? 0) * _kTtranslation),
        ),
        child: Transform.scale(
          scale: sizeAnim?.value ?? 0,
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacityAnim?.value ?? 0,
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }
}
