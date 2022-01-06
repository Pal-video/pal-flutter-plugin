import 'package:flutter/material.dart';

import 'bouncing_background_painter.dart';

class BouncingCircleBg extends StatefulWidget {
  final Widget child;
  final double radius;

  const BouncingCircleBg({
    Key? key,
    required this.child,
    required this.radius,
  }) : super(key: key);

  @override
  _BouncingCircleBgState createState() => _BouncingCircleBgState();
}

class _BouncingCircleBgState extends State<BouncingCircleBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSkeleton(
      circles: [
        BouncingCircle(
          Colors.blueGrey.withOpacity(.1),
          widget.radius + 2,
          widget.radius + 2,
          52,
        ),
        BouncingCircle(
          Colors.blueGrey.withOpacity(.05),
          widget.radius,
          widget.radius,
          64,
        ),
        BouncingCircle(
          Colors.blueGrey.withOpacity(.01),
          widget.radius,
          widget.radius,
          80,
        ),
      ],
      listenable: animationController,
      child: widget.child,
    );
  }
}

class AnimatedSkeleton extends AnimatedWidget {
  final Widget? child;
  final List<BouncingCircle> circles;
  final Animation<double> animation;

  AnimatedSkeleton({
    required AnimationController listenable,
    required this.circles,
    this.child,
    Key? key,
  })  : animation = CurvedAnimation(
          parent: listenable,
          curve: Curves.decelerate,
        ),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return _BouncingCircleBgRenderObjectWidget(
          circles
              .map((e) => e.copyWith(
                  width: ((e.max - e.min) * animation.value) + e.min))
              .toList(),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _BouncingCircleBgRenderObjectWidget
    extends SingleChildRenderObjectWidget {
  final List<BouncingCircle> circles;

  const _BouncingCircleBgRenderObjectWidget(this.circles, {Widget? child})
      : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderBouncingCircle(circles: circles);

  @override
  void updateRenderObject(
      BuildContext context, RenderBouncingCircle renderObject) {
    renderObject.circles = circles;
    renderObject.markNeedsPaint();
  }

  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   // properties.add(DoubleProperty('animValue', animValue));
  // }
}
