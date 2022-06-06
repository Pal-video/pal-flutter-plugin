import 'package:pal/api/http_client.dart';
import 'models/video_trigger_event.dart';

class PalTriggeredEventApi {
  /// recorded event list before saving these to database
  final Map<String, List<VideoTriggerEvent>> _resultEvents = {};

  final HttpClient _httpClient;

  PalTriggeredEventApi(this._httpClient);

  /// save this event
  /// you have to call [send] to store this in remote server
  Future<void> save(
    String eventlogId,
    VideoTriggerEvent event,
  ) async {
    _resultEvents.putIfAbsent(eventlogId, () => []);
    _resultEvents[eventlogId]!.add(event);
  }

  /// calls remote server to store all these events related to
  /// [videoTriggerId] the video id
  Future<void> send() async {
    for (var eventlogId in _resultEvents.keys) {
      await _httpClient.post(
        Uri.parse('/eventlogs/$eventlogId'),
        body: _resultEvents[eventlogId]!.map((e) => e.toJson()).toList(),
      );
    }
    _resultEvents.clear();
  }
}
