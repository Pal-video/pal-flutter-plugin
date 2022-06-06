// import 'package:device_info_plus/device_info_plus.dart';
import 'package:pal/api/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'models/session.dart';

const _kSessionId = 'sessionId';

class PalSessionApi {
  final HttpClient _httpClient;

  /// the current user session
  PalSession? _session;

  // final DeviceInfoPlugin deviceInfoPlugin;

  final SharedPreferences sharedPreferences;

  PalSessionApi(
    this._httpClient,
    this.sharedPreferences,
  );

  Future<void> initSession() async {
    final localSessionId = sharedPreferences.getString(_kSessionId);
    if (localSessionId != null && localSessionId.isNotEmpty) {
      _session = PalSession(uid: localSessionId);
      return;
    }

    final res = await _httpClient.post(
      Uri.parse('/sessions'),
      body: PalSessionRequest.create(
        platform: defaultTargetPlatform.name,
      ).toJson(),
    );
    _session = PalSession.fromJson(res.body);

    await sharedPreferences.setString(_kSessionId, _session!.uid);
  }

  PalSession get session => _session!;

  bool get hasSession => _session != null && _session!.uid.isNotEmpty;
}
