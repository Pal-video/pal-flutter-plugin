import 'package:intl/intl.dart';

/// format date to Java Instant format
/// example: 2007-12-03T10:15:30.00Z
String toDateServerFormat(DateTime date) {
  var dateUtc = date.toUtc();
  return DateFormat('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').format(dateUtc);
}
