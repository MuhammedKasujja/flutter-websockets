import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowToolbar extends StatelessWidget {
  const WindowToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingToolbar(),
    );
  }
}

class FloatingToolbar extends StatelessWidget {
  const FloatingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) async {
            Rect bounds = await WindowManager.instance.getBounds();
            await WindowManager.instance.setBounds(
              bounds.translate(details.delta.dx, details.delta.dy),
            );
          },
          child: Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.menu, color: Colors.white),
                Text('Floating Toolbar', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    _buildWindowButton(Icons.remove, _minimizeToTray),
                    _buildWindowButton(Icons.crop_square, _toggleMaximize),
                    _buildWindowButton(
                      Icons.close,
                      WindowManager.instance.close,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _minimizeToTray() async {
    await WindowManager.instance.hide(); // Hide to system tray
  }

  Future<void> _toggleMaximize() async {
    bool isMaximized = await WindowManager.instance.isMaximized();
    isMaximized
        ? await WindowManager.instance.restore()
        : await WindowManager.instance.maximize();
  }

  Widget _buildWindowButton(IconData icon, Function() onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      splashRadius: 20,
    );
  }
}