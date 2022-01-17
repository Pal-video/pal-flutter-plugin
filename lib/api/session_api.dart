import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:pal/api/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/session.dart';

const _kSessionId = 'sessionId';

class PalSessionApi {
  final HttpClient _httpClient;

  /// the current user session
  PalSession? _session;

  final _deviceInfoPlugin = DeviceInfoPlugin();

  final SharedPreferences sharedPreferences;

  PalSessionApi(this._httpClient, this.sharedPreferences);

  Future<void> initSession() async {
    final localSessionId = sharedPreferences.getString(_kSessionId);
    if (localSessionId != null) {
      _session = PalSession(id: localSessionId);
      return;
    }
    final res = await _httpClient.post(
      Uri.parse('/sessions'),
      body: {},
    );
    _session = PalSession.fromJson(res.body);
  }

  PalSession get session => _session!;
}
