class MissingSessionException implements Exception {
  MissingSessionException();

  @override
  String toString() {
    return '''
    -----------------------------
    MissingSessionException
    You must have a session to call this method
    -----------------------------
    ''';
  }
}
