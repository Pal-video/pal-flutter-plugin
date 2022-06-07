import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef OnPositionChanged = void Function(Duration duration);

typedef OnVideoStarted = void Function();

class VideoListener {
  final OnPositionChanged? onPositionChanged;

  final OnVideoStarted? onVideoStarted;

  VideoPlayerController controller;

  bool _hasInit;

  bool _playing;

  bool get isTesting => Platform.environment.containsKey('FLUTTER_TEST');

  VideoListener(
    this.controller, {
    this.onPositionChanged,
    this.onVideoStarted,
  })  : _hasInit = false,
        _playing = false;

  _initListener() {
    if (_hasInit) {
      return;
    }
    controller.addListener(onPositionChangedListener);
    _hasInit = true;
    // since we can't test the video ending trigger in full integration test
    if (isTesting && onPositionChanged != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        onPositionChanged!(Duration.zero);
      });
    }
  }

  Future<bool> start({
    required double volume,
    required bool loop,
  }) async {
    if (_playing) {
      return false;
    }
    if (isTesting) {
      _playing = true;
      return true;
    }
    try {
      _playing = true;
      Future.delayed(const Duration(milliseconds: 500));
      await controller.initialize();
      _initListener();
      await controller.setLooping(loop);
      await controller.setVolume(volume);
      await controller.seekTo(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await controller.play();
        if (onVideoStarted != null) {
          onVideoStarted!();
        }
      });
      return true;
    } catch (e, d) {
      _playing = false;
      debugPrint("Error while playing video: $e, $d");
    }
    return false;
  }

  bool get isPlaying =>
      _playing && controller.value.isPlaying && controller.value.isInitialized;

  dispose() {
    controller.removeListener(onPositionChangedListener);
    controller.dispose();
  }

  onPositionChangedListener() async {
    final remaining = await remainingDuration;
    if (remaining != null && onPositionChanged != null) {
      onPositionChanged!(remaining);
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
    return null;
  }

  Future<void> pause() async {
    await controller.pause();
  }
}
