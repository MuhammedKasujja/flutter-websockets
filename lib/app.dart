import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final reverbHost = "192.168.100.35";
final reverbPort = 8080;
final reverbAppKey = "ox9bhbnatqbg6umj8qrj";

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final Logger logger = Logger();

  final options = ReverbOptions(
    scheme: "ws",
    host: reverbHost,
    port: "$reverbPort",
    appKey: reverbAppKey,
    authUrl:
        "http://$reverbHost/broadcasting/auth", // optional, needed for private channels
    authToken: "your-auth-token", // optional
    privatePrefix: "private-", // default: "private-"
    usePrefix: true, // default: true
  );

  @override
  void initState() {
    final reverb = FlutterReverb(options: options);

    reverb.listen(
      (message) {
        logger.i("Received: ${message.event}, Data: ${message.data}");
      },
      "sent-messages",
      isPrivate: false,
    );

    // Private channel
    // reverb.listen(
    //   (message) {
    //     print("Received: ${message.event}, Data: ${message.data}");
    //   },
    //   "public-channel",
    //   isPrivate: true,
    // );
    // _testReverb();
    super.initState();
  }

  void _testReverb() {
    final wsUrl = 'ws://$reverbHost:$reverbPort/app/$reverbAppKey';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    final subscription = {
      "event": "pusher:subscribe",
      "data": {"channel": "sent-messages"},
    };
    channel.sink.add(jsonEncode(subscription));
    channel.stream.listen(
      (message) {
        logger.d('Received: $message');
      },
      onDone: () {
        logger.i('Connection closed.');
      },

      onError: (error) {
        logger.e('Error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter sockets')),
      body: ListView(children: [
          
        ],
      ),
    );
  }
}
