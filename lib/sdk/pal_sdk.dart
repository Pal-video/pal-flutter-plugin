import 'package:flutter/material.dart';
import 'package:pal_video/expanded/video_expanded.dart';
import 'package:pal_video/pal.dart';

import '../animations/bouncing_background.dart';
import '../expanded/state_actions.dart';
import '../surveys/single_choice/single_choice.dart';
import '../overlays/overlay_helper.dart';

typedef OnTapChoice = void Function(Choice choice);

class PalSdk {
  final OverlayHelper _overlayHelper;

  @visibleForTesting
  PalSdk({
    required OverlayHelper overlayHelper,
  }) : _overlayHelper = overlayHelper;

  PalSdk.fromKey({
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _overlayHelper = OverlayHelper(navigatorKey);

  Future<void> showSingleChoiceSurvey({
    required String videoAsset,
    required String userName,
    required String companyTitle,
    String? avatarUrl,
    required String question,
    required List<Choice> choices,
    required OnTapChoice onTapChoice,
    required Function onVideoEndAction,
    Function? onExpand,
    Function? onClose,
    Function? onSkip,
  }) async {
    return showVideoAsset(
      videoAsset: videoAsset,
      userName: userName,
      companyTitle: companyTitle,
      avatarUrl: avatarUrl,
      onVideoEndAction: onVideoEndAction,
      onSkip: onSkip,
      onClose: onClose,
      onExpand: onExpand,
      animateOnVideoEnd: false,
      child: SingleChoiceForm(
        question: question,
        choices: choices,
        onTap: (ctx, choice) {
          onTapChoice(choice);
          Actions.maybeInvoke(ctx, const CloseVideoIntent());
          Future.delayed(const Duration(milliseconds: 500), () {
            _overlayHelper.popHelper();
          });
        },
      ),
    );
  }

  Future<void> showVideoOnly({
    required String videoUrl,
    required String minVideoUrl,
    required String userName,
    required String companyTitle,
    String? avatarUrl,
    Function? onExpand,
    Function? onVideoEnd,
    Function? onSkip,
  }) async {
    return showVideoAsset(
      videoAsset: videoUrl,
      userName: userName,
      companyTitle: companyTitle,
      avatarUrl: avatarUrl,
      animateOnVideoEnd: true,
      onVideoEndAction: () {
        _overlayHelper.popHelper();
        if (onVideoEnd != null) {
          onVideoEnd();
        }
      },
      onSkip: onSkip,
      onClose: onVideoEnd,
      onExpand: onExpand,
    );
  }

  Future<void> showVideoAsset({
    required String videoAsset,
    required String userName,
    required String companyTitle,
    required Function onVideoEndAction,
    required bool animateOnVideoEnd,
    Function? onClose,
    Function? onExpand,
    String? avatarUrl,
    Widget? child,
    Function? onSkip,
  }) async {
    _overlayHelper.showHelper(
      (ctx) => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: BouncingCircleBg(
                radius: 50,
                child: VideoMiniature(
                  videoAsset: videoAsset,
                  radius: 100,
                  onTap: () {
                    if (onExpand != null) {
                      onExpand();
                    }
                    _overlayHelper.popHelper();
                    showExpandedVideoAsset(
                      videoAsset: videoAsset,
                      userName: userName,
                      companyTitle: companyTitle,
                      animateOnVideoEnd: animateOnVideoEnd,
                      child: child,
                      onVideoEndAction: onVideoEndAction,
                      close: () {
                        _overlayHelper.popHelper();
                        if (onClose != null) {
                          onClose();
                        }
                      },
                      onSkip: () {
                        _overlayHelper.popHelper();
                        if (onSkip != null) {
                          onSkip();
                        }
                      },
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
    required String videoAsset,
    required String userName,
    required String companyTitle,
    required Function onVideoEndAction,
    required Function close,
    required bool animateOnVideoEnd,
    Function? onSkip,
    String? avatarUrl,
    Widget? child,
  }) async {
    _overlayHelper.showHelper(
      (context) => Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: VideoExpanded(
          videoAsset: videoAsset,
          companyTitle: companyTitle,
          userName: userName,
          avatarUrl: avatarUrl,
          onEndAction: onVideoEndAction,
          animateOnVideoEnd: animateOnVideoEnd,
          triggerEndRemaining: const Duration(seconds: 1),
          onSkip: onSkip,
          close: close,
          bgColor: const Color(0xFF191E26).withOpacity(.82),
          child: child,
        ),
      ),
    );
  }

  Future<void> clearAnyVideo() async {
    _overlayHelper.popHelper();
  }
}
