import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:pal/pal.dart';

import 'utils/overlay_helper.dart';

class PalPlugin {
  final OverlayHelper _overlayHelper = OverlayHelper();

  static final instance = PalPlugin._();

  PalPlugin._();

  Future<void> showVideoAsset({
    required BuildContext context,
    required String videoAsset,
    required String userName,
    required String companyTitle,
  }) async {
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
              videoAsset: videoAsset,
              radius: 80,
              onTap: () {
                Navigator.of(context).pop();
                showExpandedVideoAsset(
                  context: context,
                  videoAsset: videoAsset,
                  userName: userName,
                  companyTitle: companyTitle,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showExpandedVideoAsset({
    required BuildContext context,
    required String videoAsset,
    required String companyTitle,
    required String userName,
    String? avatarUrl,
  }) async {
    _overlayHelper.showHelper(
      context,
      (context) => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: VideoExpanded(
            videoAsset: videoAsset,
            companyTitle: companyTitle,
            userName: userName,
            avatarUrl: avatarUrl,
            onEndAction: () {},
            triggerEndRemaining: const Duration(seconds: 1),
            onSkip: () {},
          ),
        ),
      ),
    );
  }
}
