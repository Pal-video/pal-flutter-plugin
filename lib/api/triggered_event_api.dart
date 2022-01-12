import 'package:pal/api/http_client.dart';
import 'models/video_trigger_event.dart';

class PalTriggeredEventApi {
  /// recorded event list before saving these to database
  Map<String, List<VideoTriggerEvent>> _resultEvents = {};

  final HttpClient _httpClient;

  PalTriggeredEventApi(this._httpClient);

  /// save this event
  /// you have to call [send] to store this in remote server
  Future<void> save(
    String videoTriggerId,
    VideoTriggerEvent event,
  ) async {
    _resultEvents.putIfAbsent(videoTriggerId, () => []);
    _resultEvents[videoTriggerId]!.add(event);
  }

  /// calls remote server to store all these events related to
  /// [videoTriggerId] the video id
  Future<void> send() async {
    for (var videoId in _resultEvents.keys) {
      await _httpClient.post(
        Uri.parse('/triggers/$videoId'),
        body: _resultEvents[videoId]!.map((e) => e.toJson()).toList(),
      );
    }
    _resultEvents.clear();
  }
}
