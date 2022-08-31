import 'dart:convert';

import 'session.dart';

enum PalEvents {
  login,
  logout,
  setScreen,
  setButtonClick,
}

class PalEvent {
  /// name of the event as it is registered on the server
  final String name;

  /// the event type triggered by the app
  final PalEvents type;

  /// attributes for sending custom event data
  final Map<String, dynamic>? attrs;

  const PalEvent({
    required this.name,
    required this.type,
    this.attrs,
  });
}

class PalEventContext extends PalEvent {
  /// the current user device session
  final PalSession session;

  const PalEventContext({
    required this.session,
    required String name,
    required PalEvents event,
    Map<String, dynamic>? attrs,
  }) : super(
          name: name,
          type: event,
          attrs: attrs,
        );

  factory PalEventContext.fromEvent(
    PalSession session,
    PalEvent palEvent,
  ) {
    return PalEventContext(
      session: session,
      name: palEvent.name,
      event: palEvent.type,
      attrs: palEvent.attrs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionUId': session.uid,
      'name': name,
      'type': type.name,
      'attrs': attrs != null ? jsonEncode(attrs) : null,
    };
  }

  toJson() => jsonEncode(toMap());
}
