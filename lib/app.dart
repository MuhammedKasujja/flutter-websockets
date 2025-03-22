import 'package:flutter/material.dart';
import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';
import 'package:flutter_websockets/service/websocket_service.dart';
import 'package:logger/logger.dart';

final reverbHost = "192.168.65.100";
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

  @override
  void initState() {
    // final reverb = FlutterReverb(options: options);

    // reverb.listen(
    //   (message) {
    //     logger.i("Received: ${message.event}, Data: ${message.data}");
    //     logger.e("Received: ${message.toJson()}");
    //     setState(() {
    //       data = message.data;
    //     });
    //   },
    //   "sent-messages",
    //   isPrivate: false,
    // );

    final websocket = WebsocketService.init(options);

    websocket.listenChannel(
      channelName: 'sent-messages',
      onData: (response) {
        logger.i("Received: ${response.event}, Data: ${response.data}");
        logger.e("Received: ${response.toJson()}");
        setState(() {
          data = response.data;
        });
      },
    );

    // Private channel
    // reverb.listen(
    //   (message) {
    //     print("Received: ${message.event}, Data: ${message.data}");
    //   },
    //   "public-channel",
    //   isPrivate: true,
    // );
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
    );
  }
}
