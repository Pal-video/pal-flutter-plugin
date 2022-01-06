import 'package:flutter/material.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:pal/pal.dart';

import 'animations/bouncing_background.dart';
import 'surveys/single_choice/single_choice.dart';
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
      (ctx) => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: BouncingCircleBg(
                radius: 40,
                child: VideoMiniature(
                  videoAsset: videoAsset,
                  radius: 80,
                  onTap: () {
                    _overlayHelper.popHelper();
                    showExpandedVideoAsset(
                      context: ctx,
                      videoAsset: videoAsset,
                      userName: userName,
                      companyTitle: companyTitle,
                      child: SingleChoiceForm(
                        question: 'my question lorem ipsum lorem',
                        choices: const [
                          Choice(id: 'a', text: 'lorem A'),
                          Choice(id: 'b', text: 'lorem B'),
                          Choice(id: 'c', text: 'lorem C'),
                          Choice(id: 'd', text: 'lorem D'),
                        ],
                        onTap: (choice) {
                          _overlayHelper.popHelper();
                        },
                      ),
                    );
                  },
                ),
              ),
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
    Widget? child,
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
            child: child,
          ),
        ),
      ),
    );
  }
}
