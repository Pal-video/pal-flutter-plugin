import 'package:flutter/material.dart';
import 'package:pal/api/event_api.dart';
import 'package:pal/api/models/video_trigger.dart';
import 'package:pal/pal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_client.dart';
import 'models/pal_options.dart';
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
  late final PalPlugin _palSdk;

  String get _serverUrl => const String.fromEnvironment(
        "SERVER_URL",
        defaultValue: "https://app.pal.io/api",
      );

  @visibleForTesting
  Pal({
    HttpClient? httpClient,
    PalEventApi? eventApi,
    PalSessionApi? sessionApi,
    required PalPlugin sdk,
  })  : _httpClient = httpClient,
        _eventApi = eventApi,
        _sessionApi = sessionApi,
        _palSdk = sdk;

  static final instance = Pal(sdk: PalPlugin.instance);

  initialize(PalOptions palOptions) async {
    _httpClient ??= HttpClient.create(_serverUrl, palOptions.apiKey);
    _eventApi ??= PalEventApi(_httpClient!);
    _sessionApi ??= PalSessionApi(
      _httpClient!,
      await SharedPreferences.getInstance(),
    );
    _triggeredEventApi ??= PalTriggeredEventApi(_httpClient!);

    _sessionApi!.initSession();
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

  Future<void> logCurrentScreen(BuildContext buildContext, String name) async {
    final video = await _eventApi!.logCurrentScreen(name);
    if (video != null) {
      await _showSurvey(context: buildContext, trigger: video);
    }
  }

  Future<void> logButtonClick(BuildContext buildContext, String name) {
    throw "not implemented yet";
  }

  Future<void> _showSurvey({
    required BuildContext context,
    required PalVideoTrigger trigger,
  }) {
    return _palSdk.showSingleChoiceSurvey(
      context: context,
      videoAsset: trigger.video720pUrl,
      userName: trigger.author.userName,
      companyTitle: trigger.author.companyTitle,
      question: trigger.survey!.question,
      choices: trigger.survey!.choices!
          .map((e) => Choice(id: e.id, text: e.text))
          .toList(),
      onTapChoice: (choice) => _onTapChoice(trigger, choice),
      onVideoEndAction: () => _onVideoEnded(trigger),
      onSkip: () => _onVideoSkipped(trigger),
      onExpand: () => _onVideoExpand(trigger),
    );
  }

  Future<void> _onVideoExpand(PalVideoTrigger trigger) async {
    final event = VideoTriggerEvent(
      time: DateTime.now(),
      sessionId: _sessionApi!.session.id,
      type: VideoTriggerEvents.minVideoOpen,
    );
    _triggeredEventApi!.save(trigger.id, event);
  }

  Future<void> _onTapChoice(PalVideoTrigger trigger, Choice choice) async {
    final event = VideoTriggerEvent.singleChoice(
      choice.id,
      _sessionApi!.session.id,
    );
    _triggeredEventApi!.save(trigger.id, event);
    _triggeredEventApi!.send();
  }

  Future<void> _onVideoEnded(PalVideoTrigger trigger) async {}

  Future<void> _onVideoSkipped(PalVideoTrigger trigger) async {
    final event = VideoTriggerEvent(
      time: DateTime.now(),
      type: VideoTriggerEvents.videoSkip,
      sessionId: _sessionApi!.session.id,
    );
    _triggeredEventApi!.save(trigger.id, event);
    _triggeredEventApi!.send();
  }
}
