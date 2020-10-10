class JsonException implements Exception {
  final _message;

  JsonException(this._message);

  String toString() {
    return "$_message";
  }
}

class SerializationException extends JsonException {
  SerializationException(String message)
      : super("Error During serialization: $message");
}
