import 'package:flutter/material.dart';
import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/flutter_reverb_revisted.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';
import 'package:flutter_websockets/service/websocket_service.dart';
import 'package:logger/logger.dart';

// final reverbHost = "192.168.65.100";
final reverbHost = "127.0.0.1";
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

  Map<String, dynamic>? data;

  late WebsocketService websocket;

  @override
  void initState() {
    websocket = WebsocketService.init(options);

    websocket.channel('sent-messages').listen((response) {
      logger.i("Received: ${response.event}, Data: ${response.data}");
      setState(() {
        data = response.data;
      });
    });

    // websocket.notifications((response) {
    //   logger.i("Received Notification: ${response.event}, Data: ${response.data}");
    //   setState(() {
    //     data = response.data;
    //   });
    // });

    // websocket.private('sent-messages-data').listen((response) {
    //   logger.i("Received: ${response.event}, Data: ${response.data}");
    //   logger.e("Received: with chaining}");
    //   setState(() {
    //     data = response.data;
    //   });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter sockets')),
      body: ListView(
        shrinkWrap: true,
        children:
            data?.entries
                .map((entry) => Text(entry.value.toString()))
                .toList() ??
            [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          websocket.reconnect();
        },
        label: Icon(Icons.refresh),
      ),
    );
  }
}
