import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoProgress extends StatelessWidget {
  final Duration current;
  final Duration total;

  const VideoProgress({
    Key? key,
    required this.current,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${formatDuration(current)} / ${formatDuration(total)}",
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

String formatDuration(Duration duration) {
  num microseconds = duration.inMicroseconds;
  microseconds = microseconds.remainder(Duration.microsecondsPerHour);

  if (microseconds < 0) microseconds = -microseconds;

  var minutes = microseconds ~/ Duration.microsecondsPerMinute;
  microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

  var minutesPadding = minutes < 10 ? "0" : "";

  var seconds = microseconds ~/ Duration.microsecondsPerSecond;
  microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

  var secondsPadding = seconds < 10 ? "0" : "";
  return "$minutesPadding$minutes:"
      "$secondsPadding$seconds";
}
