import 'package:flutter/rendering.dart';

class BouncingCircle {
  final double width;
  final double min, max;
  final Color color;

  const BouncingCircle(this.color, this.width, this.min, this.max);

  BouncingCircle copyWith({double? width, Color? color}) {
    return BouncingCircle(
      color ?? this.color,
      width ?? this.width,
      min,
      max,
    );
  }
}

// class RenderBouncingCircle extends RenderShiftedBox {
class RenderBouncingCircle extends RenderProxyBox {
  List<BouncingCircle> circles;
  bool alwaysIncludeSemantics;

  RenderBouncingCircle({
    required this.circles,
    this.alwaysIncludeSemantics = false,
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    final BoxConstraints sizeConstraints = constraints.loosen();
    final Size unconstrainedSize = sizeConstraints
        .constrainSizeAndAttemptToPreserveAspectRatio(child!.size);
    size = constraints.constrain(unconstrainedSize);
    // size = constraints.constrain(const Size(600, 1900));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    final canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);
    canvas.translate(size.width / 2, size.height / 2);
    for (var circle in circles) {
      Paint circlePainter = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(Offset.zero, circle.width, circlePainter);
    }
    canvas.restore();
    context.paintChild(child!, offset);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null && (alwaysIncludeSemantics)) visitor(child!);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('alwaysIncludeSemantics',
        value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}
