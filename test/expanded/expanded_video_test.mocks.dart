// Mocks generated by Mockito 5.2.0 from annotations
// in pal/test/expanded/expanded_video_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;
import 'dart:ui' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:video_player/src/closed_caption_file.dart' as _i5;
import 'package:video_player/video_player.dart' as _i2;
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeVideoPlayerValue_0 extends _i1.Fake implements _i2.VideoPlayerValue {
}

/// A class which mocks [VideoPlayerController].
///
/// See the documentation for Mockito's code generation for more information.
class MockVideoPlayerController extends _i1.Mock
    implements _i2.VideoPlayerController {
  MockVideoPlayerController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get dataSource =>
      (super.noSuchMethod(Invocation.getter(#dataSource), returnValue: '')
          as String);
  @override
  Map<String, String> get httpHeaders =>
      (super.noSuchMethod(Invocation.getter(#httpHeaders),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  _i3.DataSourceType get dataSourceType =>
      (super.noSuchMethod(Invocation.getter(#dataSourceType),
          returnValue: _i3.DataSourceType.asset) as _i3.DataSourceType);
  @override
  int get textureId =>
      (super.noSuchMethod(Invocation.getter(#textureId), returnValue: 0)
          as int);
  @override
  _i4.Future<Duration?> get position =>
      (super.noSuchMethod(Invocation.getter(#position),
          returnValue: Future<Duration?>.value()) as _i4.Future<Duration?>);
  @override
  _i2.VideoPlayerValue get value =>
      (super.noSuchMethod(Invocation.getter(#value),
          returnValue: _FakeVideoPlayerValue_0()) as _i2.VideoPlayerValue);
  @override
  set value(_i2.VideoPlayerValue? newValue) =>
      super.noSuchMethod(Invocation.setter(#value, newValue),
          returnValueForMissingStub: null);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  _i4.Future<void> initialize() =>
      (super.noSuchMethod(Invocation.method(#initialize, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> dispose() =>
      (super.noSuchMethod(Invocation.method(#dispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> play() => (super.noSuchMethod(Invocation.method(#play, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> setLooping(bool? looping) =>
      (super.noSuchMethod(Invocation.method(#setLooping, [looping]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> pause() => (super.noSuchMethod(Invocation.method(#pause, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> seekTo(Duration? position) =>
      (super.noSuchMethod(Invocation.method(#seekTo, [position]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> setVolume(double? volume) =>
      (super.noSuchMethod(Invocation.method(#setVolume, [volume]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> setPlaybackSpeed(double? speed) =>
      (super.noSuchMethod(Invocation.method(#setPlaybackSpeed, [speed]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  void setCaptionOffset(Duration? offset) =>
      super.noSuchMethod(Invocation.method(#setCaptionOffset, [offset]),
          returnValueForMissingStub: null);
  @override
  _i4.Future<void> setClosedCaptionFile(
          _i4.Future<_i5.ClosedCaptionFile>? closedCaptionFile) =>
      (super.noSuchMethod(
          Invocation.method(#setClosedCaptionFile, [closedCaptionFile]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  void removeListener(_i6.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void addListener(_i6.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}
