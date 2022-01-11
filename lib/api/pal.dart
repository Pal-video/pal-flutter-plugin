import 'package:flutter/material.dart';
import 'package:pal/api/event_api.dart';
import 'package:pal/api/models/video_trigger.dart';
import 'package:pal/pal.dart';
import 'http_client.dart';
import 'models/pal_options.dart';

class Pal {
  /// an enhanced httpclient for our needs
  HttpClient? _httpClient;

  /// records events to our server
  PalEventApi? _eventApi;

  /// this is the Pal sdk overlaying our video above your app
  PalPlugin? _palSdk;

  String get _serverUrl => const String.fromEnvironment(
        "SERVER_URL",
        defaultValue: "https://app.pal.io/api",
      );

  @visibleForTesting
  Pal({
    HttpClient? httpClient,
    PalEventApi? eventApi,
    PalPlugin? sdk,
  })  : _httpClient = httpClient,
        _eventApi = eventApi,
        _palSdk = sdk;

  static final instance = Pal(sdk: PalPlugin.instance);

  initialize(PalOptions palOptions) {
    _httpClient ??= HttpClient.create(_serverUrl, palOptions.apiKey);
    _eventApi ??= PalEventApi(_httpClient!);
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
    return _palSdk!.showSingleChoiceSurvey(
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
    );
  }

  Future<void> _onTapChoice(PalVideoTrigger trigger, Choice choice) async {}

  Future<void> _onVideoEnded(PalVideoTrigger trigger) async {}

  Future<void> _onVideoSkipped(PalVideoTrigger trigger) async {}
}
