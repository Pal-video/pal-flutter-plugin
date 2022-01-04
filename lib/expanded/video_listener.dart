import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef OnPositionChanged = void Function(Duration duration);

class VideoListener {
  final OnPositionChanged onPositionChanged;
  VideoPlayerController controller;

  VideoListener(
    this.controller, {
    required this.onPositionChanged,
  });

  init() {
    controller.addListener(onPositionChangedListener);
  }

  dispose() {
    controller.removeListener(onPositionChangedListener);
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
}
