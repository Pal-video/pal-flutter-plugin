import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PalEvents {
  login,
  logout,
  setScreen,
  setButtonClick,
}

class PalEvent {
  /// the event triggered by the app
  final PalEvents event;

  /// attributes for sending custom event data
  final Map<String, dynamic>? attrs;

  const PalEvent({
    required this.event,
    this.attrs,
  });
}

class PalEventContext extends PalEvent {
  /// current running platform
  final TargetPlatform platform;

  const PalEventContext({
    required this.platform,
    required PalEvents event,
    Map<String, dynamic>? attrs,
  }) : super(
          event: event,
          attrs: attrs,
        );

  factory PalEventContext.fromEvent(
    PalEvent palEvent,
    TargetPlatform platform,
  ) {
    return PalEventContext(
      event: palEvent.event,
      attrs: palEvent.attrs,
      platform: platform,
    );
  }

  toJson() => {
        'event': event.name,
        'attrs': attrs != null ? jsonEncode(attrs) : null,
        'platform': platform.name,
      };
}
