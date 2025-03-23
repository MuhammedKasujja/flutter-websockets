import 'package:flutter/material.dart';
import 'package:flutter_websockets/reverb/flutter_reverb_multi_listen.dart';

class WebSocketScreen extends StatefulWidget {
  const WebSocketScreen({super.key});

  @override
  State<WebSocketScreen> createState() => _WebSocketScreenState();
}

class _WebSocketScreenState extends State<WebSocketScreen> {
  late WebSocketStreams webSocketService;
  final String authUrl = "http://127.0.0.1:8000/broadcasting/auth";
  final String userToken = "your-user-token";

  final List<String> publicChannels = ["news", "sports"];
  final List<String> privateChannels = ["private-chat.1"];
  Map<String, List<Map<String, dynamic>>> messages = {};

  @override
  void initState() {
    super.initState();
    webSocketService = WebSocketStreams(
      serverUrl: "ws://127.0.0.1:8080",
      authUrl: authUrl,
      userToken: userToken,
    );

      webSocketService.subscribe('sent-messages');
      webSocketService.listen('sent-messages').listen((message) {
        print("Messaging......");
         print(message);
        setState(() {
          messages.putIfAbsent('sent-messages', () => []).add(message);
        });
      });
      
      webSocketService.subscribe('notifications');
      webSocketService.listen('notifications').listen((message) {
        print("notifications......");
        print(message);
        setState(() {
          messages.putIfAbsent('notifications', () => []).add(message);
        });
      });

      webSocketService.subscribePrivate("preview");
      webSocketService.listen("preview").listen((message) {
        print("preview......");
        print(message);
        setState(() {
          messages.putIfAbsent("preview", () => []).add(message);
        });
      });
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Channels")),
      body: ListView(
        children: messages.entries.map((entry) {
          return ExpansionTile(
            title: Text("Channel: ${entry.key}"),
            children: entry.value.map((msg) {
              return ListTile(title: Text(msg["message"]));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
