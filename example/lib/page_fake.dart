import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FakePage extends StatelessWidget {
  final String assetImgUrl;
  final Function onTap, onTapBottom;

  const FakePage({
    Key? key,
    required this.assetImgUrl,
    required this.onTap,
    required this.onTapBottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset(assetImgUrl)),
            Positioned.fromRect(
              rect: const Rect.fromLTWH(0, 0, 300, 300),
              child: GestureDetector(
                onHorizontalDragEnd: (_) => Navigator.of(context).pop(),
                onTap: () => onTap(),
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: 300,
              height: 300,
              child: GestureDetector(
                onHorizontalDragEnd: (_) => Navigator.of(context).pop(),
                onTap: () => onTapBottom(),
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
