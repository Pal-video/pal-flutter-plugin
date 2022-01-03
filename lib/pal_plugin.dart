import 'package:flutter/material.dart';
import 'package:pal/pal.dart';

import 'utils/overlay_helper.dart';

class PalPlugin {
  final OverlayHelper _overlayHelper = OverlayHelper();

  static final instance = PalPlugin._();

  PalPlugin._();

  Future<void> showVideoAsset(BuildContext context, String asset) async {
    _overlayHelper.showHelper(
      context,
      (context) => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 32.0,
            ),
            child: VideoMiniature(
              videoAsset: asset,
              radius: 80,
            ),
          ),
        ),
      ),
    );
  }
}
