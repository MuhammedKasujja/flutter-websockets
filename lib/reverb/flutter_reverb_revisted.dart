import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';

class FlutterReverbImp implements ReverbService {
  late final WebSocketChannel _channel;
  final ReverbOptions options;
  final Logger _logger = Logger();
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController.broadcast();
  final List<Channel> _connectedChannels = [];

  FlutterReverbImp({required this.options}) {
    try {
      final wsUrl = _constructWebSocketUrl();
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    } catch (e) {
      _logger.e('Failed to connect to WebSocket: $e');
      rethrow;
    }
  }

  String _constructWebSocketUrl() {
    return '${options.scheme}://${options.host}:${options.port}/app/${options.appKey}';
  }

  void _subscribe(
    String channelName,
    String? broadcastAuthToken, {
    bool isPrivate = false,
  }) {
    try {
      final subscription = {
        "event": "pusher:subscribe",
        "data":
            isPrivate
                ? {"channel": channelName, "auth": broadcastAuthToken}
                : {"channel": channelName},
      };
      _channel.sink.add(jsonEncode(subscription));
    } catch (e) {
      _logger.e('Failed to subscribe to channel: $e');
      rethrow;
    }
  }

  @override
  void listen(
    void Function(WebsocketResponse data) onData,
    String channelName, {
    bool isPrivate = false,
  }) {
    try {
      final channelPrefix = options.usePrefix ? options.privatePrefix : '';
      final fullChannelName =
          isPrivate ? '$channelPrefix$channelName' : channelName;
      _subscribe(channelName, null);
      _subscription = _channel.stream.listen(
        (message) async {
          try {
            final Map<String, dynamic> jsonMessage = jsonDecode(message);
            final response = WebsocketResponse.fromJson(jsonMessage);

            if (response.event == 'pusher:connection_established') {
              final socketId = response.data?['socket_id'];

              if (socketId == null) {
                throw Exception('Socket ID is missing');
              }

              if (isPrivate) {
                final authToken = await _authenticate(
                  socketId,
                  fullChannelName,
                );
                _subscribe(fullChannelName, authToken!, isPrivate: isPrivate);
              } else {
                _subscribe(fullChannelName, null, isPrivate: isPrivate);
              }
            } else if (response.event == 'pusher:ping') {
              _channel.sink.add(jsonEncode({'event': 'pusher:pong'}));
            }
            onData(response);
          } catch (e) {
            _logger.e('Error processing message: $e');
          }
        },
        onError: (error) => _logger.e('WebSocket error: $error'),
        onDone: () => _logger.i('Connection closed: $channelName'),
      );
    } catch (e) {
      _logger.e('Failed to listen to WebSocket: $e');
      rethrow;
    }
  }

  Future<String?> _authenticate(String socketId, String channelName) async {
    try {
      if (options.authToken == null) {
        throw Exception('Auth Token is missing');
      } else if (options.authUrl == null) {
        throw Exception('Auth URL is missing');
      }

      var token = options.authToken;
      if (options.authToken is Future<String?>) {
        token = await options.authToken;
      } else if (options.authToken is String) {
        token = options.authToken;
      } else {
        throw Exception('Parameter authToken is not a string or a function');
      }

      final response = await (http.Client()).post(
        Uri.parse(options.authUrl!),
        headers: {'Authorization': 'Bearer $token'},
        body: {'socket_id': socketId, 'channel_name': channelName},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['auth'];
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Authentication error: $e');
      return null;
    }
  }

  @override
  FlutterReverbImp channel(String channelName) {
    _addChannels(Channel(name: channelName, isPrivate: false));
    return this;
  }

  @override
  FlutterReverbImp private(String channelName) {
    _addChannels(Channel(name: channelName, isPrivate: true));
    return this;
  }

  void stream(void Function(WebsocketResponse data) onData) {
    final lastChannel = _connectedChannels.last;
    listen(onData, lastChannel.name, isPrivate: lastChannel.isPrivate);
  }

  void _addChannels(Channel channel) {
    final storedChannel = _connectedChannels.firstWhereOrNull(
      (ele) => ele.name == channel.name,
    );
    if (storedChannel == null) {
      _connectedChannels.add(channel);
    }
  }

  void reconnect() {
    for (var channel in _connectedChannels) {
      _logger.i(channel.toJson());
    }
  }

  @override
  void close() {
    try {
      _subscription?.cancel();
      _channel.sink.close(status.goingAway);
    } catch (e) {
      _logger.e('Failed to close WebSocket: $e');
    }
  }
}

class Channel {
  final String name;
  final bool isPrivate;

  Channel({required this.name, this.isPrivate = false});

  Map<String, dynamic> toJson() {
    return {"name": name, "isPrivate": isPrivate};
  }
}
