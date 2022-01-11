import 'package:pal/api/http_client.dart';
import 'package:flutter/foundation.dart';

import 'models/event.dart';
import 'models/video_trigger.dart';

class PalEventApi {
  final HttpClient _httpClient;

  PalEventApi(this._httpClient);

  Future<void> logLogin() {
    throw "not implemented yet";
  }

  Future<void> logSignout() {
    throw "not implemented yet";
  }

  Future<void> logSignup() {
    throw "not implemented yet";
  }

  Future<PalVideoTrigger?> logCurrentScreen(String name) => _logEvent(
        PalEvent(
          event: PalEvents.setScreen,
          attrs: <String, dynamic>{
            'name': name,
          },
        ),
      );

  Future<void> logButtonClick(String name) {
    throw "not implemented yet";
  }

  Future<PalVideoTrigger?> _logEvent(PalEvent event) async {
    final eventContext = PalEventContext.fromEvent(
      event,
      defaultTargetPlatform,
    );
    final response = await _httpClient.post(
      Uri.parse('/events'),
      body: eventContext.toJson(),
    );
    if (response.body.isEmpty) {
      return null;
    }
    return PalVideoTrigger.fromJson(response.body);
  }
}
