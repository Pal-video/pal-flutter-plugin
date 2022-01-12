import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef OnPositionChanged = void Function(Duration duration);

class VideoListener {
  final OnPositionChanged onPositionChanged;
  VideoPlayerController controller;
  bool hasInit;

  bool get isTesting => Platform.environment.containsKey('FLUTTER_TEST');

  VideoListener(
    this.controller, {
    required this.onPositionChanged,
  }) : hasInit = false;

  _initListener() {
    if (hasInit) {
      return;
    }
    controller.addListener(onPositionChangedListener);
    hasInit = true;
    // since we can't test the video ending trigger in full integration test
    if (isTesting) {
      Future.delayed(const Duration(milliseconds: 500), () {
        onPositionChanged(Duration.zero);
      });
    }
  }

  Future<bool> start({
    required double volume,
    required bool loop,
  }) async {
    try {
      Future.delayed(const Duration(milliseconds: 500));
      await controller.initialize();
      _initListener();
      await controller.setLooping(loop);
      await controller.setVolume(volume);
      await controller.seekTo(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await controller.play();
      });
      return true;
    } catch (e, d) {
      debugPrint("Error while playing video: $e, $d");
    }
    return false;
  }

  dispose() {
    controller.removeListener(onPositionChangedListener);
    controller.dispose();
  }

  onPositionChangedListener() async {
    final remaining = await remainingDuration;
    if (remaining != null) {
      onPositionChanged(remaining);
    }
  }

  Future<Duration?> get remainingDuration async {
    try {
      final position = await controller.position;
      if (position != null) {
        final totalDuration = controller.value.duration;
        return totalDuration - position;
      }
    } catch (e, d) {
      debugPrint("Error while fetching duration: $e, $d");
    }
  }

  Future<void> pause() async {
    await controller.pause();
  }
}
