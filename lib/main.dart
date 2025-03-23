import 'package:flutter/material.dart';
import 'package:flutter_websockets/app.dart';

import 'multi_channels.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: AppScreen(),
      home: WebSocketScreen(),
    );
  }
}
