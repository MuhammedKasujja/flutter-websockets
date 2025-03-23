import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  final String serverUrl;
  final String authUrl;
  final String userToken; // Laravel API token
  WebSocketChannel? _channel;
  final List<String> _subscribedChannels = [];
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController.broadcast();

  WebSocketService({
    required this.serverUrl,
    required this.authUrl,
    required this.userToken,
  }) {
    _connect();
  }

  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Establish a single WebSocket connection
  void _connect() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse(
        '$serverUrl/app/your-app-key?protocol=7&client=js&version=4.4.0',
      ),
    );

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['event'] == 'message.received') {
          _messageStreamController.add({
            "channel": data['channel'],
            "message": data['data']['message'],
          });
        }
      },
      onDone: _reconnect,
      onError: (error) => print("WebSocket Error: $error"),
    );

    for (var channel in _subscribedChannels) {
      _subscribe(channel);
    }

    print("Connected to WebSocket Server");
  }

  /// Subscribe to a public channel
  void subscribe(String channelName) {
    if (_subscribedChannels.contains(channelName)) return;

    _subscribedChannels.add(channelName);
    _subscribe(channelName);
  }

  /// Subscribe to a private channel
  Future<void> subscribePrivate(String channelName) async {
    if (_subscribedChannels.contains(channelName)) return;

    String? authData = await _authenticate(channelName);
    if (authData == null) {
      print("Authentication failed for $channelName");
      return;
    }

    _subscribedChannels.add(channelName);
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

  /// Send subscribe event
  void _subscribe(String channelName) {
    _channel?.sink.add(
      jsonEncode({
        "event": "pusher:subscribe",
        "data": {"channel": channelName},
      }),
    );
    print("Subscribed to $channelName");
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    _subscribedChannels.remove(channelName);
    _channel?.sink.add(
      jsonEncode({
        "event": "pusher:unsubscribe",
        "data": {"channel": channelName},
      }),
    );
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
    _messageStreamController.close();
  }
}
