import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PalEvent {
  final TargetPlatform? platform;

  const PalEvent({
    this.platform,
  });
}

class EventApi {
  Future<void> login() {
    throw "not implemented yet";
  }

  Future<void> logout() {
    throw "not implemented yet";
  }

  Future<void> signup() {
    throw "not implemented yet";
  }

  Future<void> setCurrentScreen(String name) {
    throw "not implemented yet";
  }

  Future<void> logEvent(PalEvent event) {
    throw "not implemented yet";
  }
}
