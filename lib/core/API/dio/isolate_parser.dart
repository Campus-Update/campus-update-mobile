import 'dart:convert';
import 'dart:isolate';

typedef ResponseConverter<T> = T Function(dynamic response);

class IsolateParser<T> {
  final Map<String, dynamic> data;
  final ResponseConverter<T> converter;

  IsolateParser(this.data, this.converter);

  Future<T> parseInBackground() async {
    final p = ReceivePort();
    await Isolate.spawn(_isolateEntry, p.sendPort);
    final sendPort = await p.first as SendPort;
    final response = ReceivePort();
    sendPort.send([data, converter, response.sendPort]);
    return await response.first as T;
  }

  static void _isolateEntry(SendPort initialReplyTo) {
    final port = ReceivePort();
    initialReplyTo.send(port.sendPort);
    port.listen((message) async {
      final data = message[0] as Map<String, dynamic>;
      final converter = message[1] as ResponseConverter;
      final sendPort = message[2] as SendPort;
      final result = converter(jsonDecode(jsonEncode(data)));
      sendPort.send(result);
    });
  }
}