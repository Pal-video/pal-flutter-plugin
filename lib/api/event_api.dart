import 'package:pal/api/http_client.dart';

import 'models/event.dart';
import 'models/session.dart';
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

  Future<PalVideoTrigger?> logCurrentScreen(PalSession session, String name) =>
      _logEvent(
        session,
        PalEvent(
          name: name,
          type: PalEvents.setScreen,
          attrs: <String, dynamic>{
            'name': name,
          },
        ),
      );

  Future<void> logButtonClick(String name) {
    throw "not implemented yet";
  }

  Future<PalVideoTrigger?> _logEvent(PalSession session, PalEvent event) async {
    final eventContext = PalEventContext.fromEvent(session, event);

    final response = await _httpClient.post(
      Uri.parse('/eventlogs'),
      body: eventContext.toJson(),
    );
    if (response.body.isEmpty) {
      return null;
    }
    return PalVideoTrigger.fromJson(response.body);
  }
}
