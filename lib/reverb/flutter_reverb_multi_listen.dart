import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketStreams {
  final String serverUrl;
  final String authUrl;
  final String userToken; // Laravel API token
  WebSocketChannel? _channel;
  final Map<String, StreamController<Map<String, dynamic>>> _channelStreams =
      {};

  WebSocketStreams({
    required this.serverUrl,
    required this.authUrl,
    required this.userToken,
  }) {
    _connect();
  }

  /// Get stream for a specific channel
  Stream<Map<String, dynamic>> listen(String channelName) {
    _channelStreams.putIfAbsent(
      channelName,
      () => StreamController<Map<String, dynamic>>.broadcast(),
    );
    return _channelStreams[channelName]!.stream;
  }

  /// Establish a single WebSocket connection
  void _connect() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('$serverUrl/app/ox9bhbnatqbg6umj8qrj'),
    );

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final String? channel = data['channel'];

        if (channel != null && _channelStreams.containsKey(channel)) {
          _channelStreams[channel]!.add({
            "channel": channel,
            "message": data['data'],
          });
        }
      },
      onDone: _reconnect,
      onError: (error) => print("WebSocket Error: $error"),
    );

    print("Connected to WebSocket Server");
  }

  /// Subscribe to a public channel
  void subscribe(String channelName) {
    _channelStreams.putIfAbsent(
      channelName,
      () => StreamController<Map<String, dynamic>>.broadcast(),
    );

    _channel?.sink.add(
      jsonEncode({
        "event": "pusher:subscribe",
        "data": {"channel": channelName},
      }),
    );

    print("Subscribed to $channelName");
  }

  /// Subscribe to a private channel (with authentication)
  Future<void> subscribePrivate(String channelName) async {
    String? authData = await _authenticate(channelName);
    if (authData == null) {
      print("Authentication failed for $channelName");
      return;
    }

    _channelStreams.putIfAbsent(
      channelName,
      () => StreamController<Map<String, dynamic>>.broadcast(),
    );

    _channel?.sink.add(
      jsonEncode({
        "event": "pusher:subscribe",
        "data": {"channel": channelName, "auth": authData},
      }),
    );

    print("Subscribed to private channel: $channelName");
  }

  /// Authenticate with Laravel for private channels
  Future<String?> _authenticate(String channelName) async {
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          "Authorization": "Bearer $userToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"channel_name": channelName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['auth'];
      } else {
        print("Authentication failed: ${response.body}");
      }
    } catch (e) {
      print("Error authenticating: $e");
    }
    return null;
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    _channel?.sink.add(
      jsonEncode({
        "event": "pusher:unsubscribe",
        "data": {"channel": channelName},
      }),
    );

    _channelStreams[channelName]?.close();
    _channelStreams.remove(channelName);

    print("Unsubscribed from $channelName");
  }

  /// Handle WebSocket reconnection
  void _reconnect() {
    _channel = null;
    Future.delayed(Duration(seconds: 2), _connect);
  }

  /// Dispose WebSocket connection
  void dispose() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _channelStreams.forEach((_, controller) => controller.close());
    _channelStreams.clear();
  }
}
