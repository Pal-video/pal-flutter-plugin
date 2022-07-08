import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef OnPositionChanged = void Function(Duration duration);

typedef OnVideoStarted = void Function();

class VideoProgression {
  Duration current;
  Duration total;

  VideoProgression(this.current, this.total);
}

class VideoListener {
  final OnPositionChanged? onPositionChanged;

  final OnVideoStarted? onVideoStarted;

  final StreamController<VideoProgression> _videoProgressStreamCtrl =
      StreamController();

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
    try {
      _playing = true;
      await controller.initialize();
      _initListener();
      await controller.setLooping(loop);
      await controller.setVolume(volume);
      await controller.seekTo(Duration.zero);
      await controller.play();
      if (onVideoStarted != null) {
        onVideoStarted!();
      }
      await _startProgressTimer();
      return true;
    } catch (e, d) {
      _playing = false;
      debugPrint("Error while playing video: $e, $d");
    }
    return false;
  }

  Stopwatch? _stopWatch;
  Timer? _timer;

  /// Currently listening to video progression makes laggy
  /// so we create our own timer refreshing progression every seconds
  Future<void> _startProgressTimer() async {
    final totalDurationAwaited = await totalDuration;
    _stopWatch = Stopwatch()..start();
    _videoProgressStreamCtrl.add(VideoProgression(
      Duration.zero,
      totalDurationAwaited!,
    ));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopWatch!.elapsed >= totalDurationAwaited) {
        timer.cancel();
        _stopWatch!.stop();
        return;
      }
      final remaining = totalDurationAwaited - _stopWatch!.elapsed;
      if (onPositionChanged != null) {
        onPositionChanged!(remaining);
      }
      if (_videoProgressStreamCtrl.isClosed) {
        return;
      }
      _videoProgressStreamCtrl.add(VideoProgression(
        _stopWatch!.elapsed,
        totalDurationAwaited,
      ));
    });
  }

  bool get isPlaying =>
      _playing && controller.value.isPlaying && controller.value.isInitialized;

  dispose() {
    controller.dispose();
    _videoProgressStreamCtrl.close();
    if (_stopWatch != null && _stopWatch!.isRunning) {
      _stopWatch!.stop();
    }
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
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

  Future<Duration?> get totalDuration async => controller.value.duration;

  Stream<VideoProgression> listenProgress() =>
      _videoProgressStreamCtrl.stream.asBroadcastStream();

  Future<void> pause() async {
    await controller.pause();
  }
}
