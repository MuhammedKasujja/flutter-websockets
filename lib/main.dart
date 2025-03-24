import 'package:flutter/material.dart';
import 'package:flutter_websockets/app.dart';
import 'package:flutter_websockets/main_toolbar.dart';
import 'package:flutter_websockets/window_toolbar.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'multi_channels.dart';

void main() async {
  // runApp(const MainApp());
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: const Size(800, 600),
    // alwaysOnTop: true,
    // resizable: true, // Allow resizing
  );

  await WindowManager.instance.waitUntilReadyToShow(windowOptions, () async {
    await WindowManager.instance.setAsFrameless();
    await WindowManager.instance.show();
    await WindowManager.instance.focus();  
  });

  // await TrayManager.instance.setIcon(
  //   'assets/tray_icon.png',
  // ); // Change to your icon path
  // await TrayManager.instance.setToolTip('Floating Toolbar');
  // await TrayManager.instance.setContextMenu(
  //   Menu(
  //     items: [
  //       MenuItem(
  //         label: 'Show',
  //         onClick: (_) async => await WindowManager.instance.show(),
  //       ),
  //       MenuItem(
  //         label: 'Exit',
  //         onClick: (_) async => await WindowManager.instance.close(),
  //       ),
  //     ],
  //   ),
  // );

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: AppScreen(),
      // home: WindowToolbar(),
      home: MainToolbar(),
      // home: WebSocketScreen(),
    );
  }
}
