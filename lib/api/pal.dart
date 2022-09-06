import 'dart:async';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pal_video/pal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_api.dart';
import 'http_client.dart';
import 'models/video_trigger.dart';
import 'models/video_trigger_event.dart';
import 'session_api.dart';
import 'triggered_event_api.dart';

class Pal {
  /// an enhanced httpclient for our needs
  HttpClient? _httpClient;

  /// records client app events to our server
  PalEventApi? _eventApi;

  /// records video's events
  PalTriggeredEventApi? _triggeredEventApi;

  /// handle current user pal server session sync
  PalSessionApi? _sessionApi;

  /// this is the Pal sdk overlaying our video above your app
  PalSdk? _palSdk;

  /// if a video is currently playing, this is not null
  PalVideoTrigger? triggeredVideo;

  String get _serverUrl => const String.fromEnvironment(
        "SERVER_URL",
        defaultValue: "https://back.pal.video",
      );

  @visibleForTesting
  Pal({
    HttpClient? httpClient,
    PalEventApi? eventApi,
    PalSessionApi? sessionApi,
    PalSdk? sdk,
  })  : _httpClient = httpClient,
        _eventApi = eventApi,
        _sessionApi = sessionApi,
        _palSdk = sdk;

  static final instance = Pal();

  /// initialize the pal sdk
  /// a session UID string is generated by the server to identify the current user
  /// [navigatorKey] the navigator key we needs to show the video as an overlay
  Future<void> initialize(
    PalOptions palOptions,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    try {
      _palSdk ??= PalSdk.fromKey(navigatorKey: navigatorKey);
      _httpClient ??= HttpClient.create(_serverUrl, palOptions.apiKey);
      _eventApi ??= PalEventApi(_httpClient!);
      _sessionApi ??= PalSessionApi(
        _httpClient!,
        await SharedPreferences.getInstance(),
      );
      _triggeredEventApi ??= PalTriggeredEventApi(_httpClient!);
      await _sessionApi!.initSession();
    } catch (err, stack) {
      debugPrint("error initializing pal: $err");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> logLogin(BuildContext buildContext) {
    throw "not implemented yet";
  }

  Future<void> logSignout(BuildContext buildContext) {
    throw "not implemented yet";
  }

  Future<void> logSignup(BuildContext buildContext) {
    throw "not implemented yet";
  }

  Future<void> logButtonClick(BuildContext buildContext, String name) {
    throw "not implemented yet";
  }

  /// send the screen view event to the server
  /// if a video is triggered, it will be returned
  /// depending on configuration
  /// - user will see video on first time this screen as been seen
  /// Or each time this screen is visited
  Future<void> logCurrentScreen(BuildContext buildContext, String name) async {
    if (!_sessionApi!.hasSession) {
      debugPrint('''
      Missing Session Error: You must have a session to call this method
      ''');
      return;
    }
    if (triggeredVideo != null) {
      return;
    }
    runZonedGuarded(
      () async {
        final screenTriggeredVideo = await _eventApi!.logCurrentScreen(
          _sessionApi!.session,
          name,
        );
        if (screenTriggeredVideo == null) {
          return;
        }
        triggeredVideo = screenTriggeredVideo;
        if (screenTriggeredVideo.isTalkType) {
          await _showVideo(
            context: buildContext,
            trigger: screenTriggeredVideo,
          );
        } else if (screenTriggeredVideo.isSurveyType) {
          await _showSurvey(
            context: buildContext,
            trigger: screenTriggeredVideo,
          );
        }
      },
      (error, stack) => debugPrint("[PAL] error showing video: $error"),
    );
  }

  /// reset the stored session UID from the local storage
  /// call it whenever your user logs out
  Future<void> clearSession() async {
    runZonedGuarded(
      () async {
        await _sessionApi!.clearSession();
        await _sessionApi!.initSession();
      },
      (error, stack) => debugPrint("[PAL] error reseting session: $error"),
    );
  }

  /// returns the current session UID used by Pal to identify the current user
  ///
  /// for more informations about sessions please check our documentation
  Future<String?> getSession() {
    if (_sessionApi!.hasSession) {
      return Future.value(_sessionApi!.session.uid);
    }
    return Future.value(null);
  }

  /// bind the user to an existing session id
  /// - the session id must exists on Pal server
  /// - the session id exists on current project
  /// You can use this when one of your users logs in again after a logout
  ///
  /// for more informations about sessions please check our documentation
  Future<void> setSession(String sessionId) {
    throw "not implemented yet";
  }

  /// shows a video miniature on the client app
  Future<void>? _showVideo({
    required BuildContext context,
    required PalVideoTrigger trigger,
  }) {
    return _palSdk!.showVideoOnly(
      context: context,
      videoUrl: trigger.videoUrl,
      minVideoUrl: trigger.videoThumbUrl,
      userName: trigger.author.userName,
      companyTitle: trigger.author.companyTitle,
      onSkip: () => _onVideoSkipped(trigger),
      onExpand: () => _onVideoExpand(trigger),
      onVideoEnd: () => _onVideoViewed(trigger),
    );
  }

  Future<void> _showSurvey({
    required BuildContext context,
    required PalVideoTrigger trigger,
  }) {
    return _palSdk!.showSingleChoiceSurvey(
      context: context,
      videoAsset: trigger.videoUrl,
      userName: trigger.author.userName,
      companyTitle: trigger.author.companyTitle,
      question: trigger.survey!.question,
      choices: trigger.survey!.choices!
          .map((e) => Choice(code: e.id, text: e.text))
          .toList(),
      onTapChoice: (choice) => _onTapChoice(trigger, choice),
      onVideoEndAction: () => _onVideoViewed(trigger),
      onSkip: () => _onVideoSkipped(trigger),
      onExpand: () => _onVideoExpand(trigger),
    );
  }

  Future<void> _onVideoExpand(PalVideoTrigger trigger) async {
    try {
      final event = VideoTriggerEvent.videoOpen(_sessionApi!.session.uid);
      _triggeredEventApi!.save(trigger.eventLogId, event);
    } catch (err, stack) {
      debugPrint("Pal error");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _onTapChoice(PalVideoTrigger trigger, Choice choice) async {
    try {
      triggeredVideo = null;
      final event = VideoTriggerEvent.singleChoice(
        _sessionApi!.session.uid,
        choice.code,
      );
      _triggeredEventApi!.save(trigger.eventLogId, event);
      _triggeredEventApi!.send();
    } catch (err, stack) {
      debugPrint("Pal error");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _onVideoViewed(PalVideoTrigger trigger) async {
    try {
      triggeredVideo = null;
      final event = VideoTriggerEvent.videoViewed(_sessionApi!.session.uid);
      _triggeredEventApi!.save(trigger.eventLogId, event);
      _triggeredEventApi!.send();
    } catch (err, stack) {
      debugPrint("Pal error");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _onVideoSkipped(PalVideoTrigger trigger) async {
    try {
      triggeredVideo = null;
      final event = VideoTriggerEvent.videoSkipped(_sessionApi!.session.uid);
      _triggeredEventApi!.save(trigger.eventLogId, event);
      _triggeredEventApi!.send();
    } catch (err, stack) {
      debugPrint("Pal error");
      debugPrintStack(stackTrace: stack);
    }
  }
}
