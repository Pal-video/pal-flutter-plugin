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
    String? eventlogId,
    VideoTriggerEvent event,
  ) async {
    if (eventlogId == null || eventlogId.isEmpty) {
      return;
    }
    _resultEvents.putIfAbsent(eventlogId, () => []);
    _resultEvents[eventlogId]!.add(event);
  }

  /// calls remote server to store all these events related to
  /// [videoTriggerId] the video id
  Future<void> send() {
    if (_resultEvents.isEmpty) {
      return Future.value();
    }
    var futuresList = <Future<void>>[];
    for (var eventlogId in _resultEvents.keys) {
      var events = _resultEvents[eventlogId]!;
      for (var event in events) {
        futuresList.add(_httpClient.post(
          Uri.parse('/eventlogs/$eventlogId'),
          body: event.toJson(),
        ));
      }
    }
    return Future.wait(futuresList) //
        .then((_) => _resultEvents.clear());
  }
}
