import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MainToolbar extends StatelessWidget {
  const MainToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('POS main', style: TextStyle(color: Colors.white)),
                ),
                Row(
                  children: [
                    _buildWindowButton(
                      Icons.remove,
                      WindowManager.instance.minimize,
                    ),
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
          Expanded(child: Container(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _toggleMaximize() async {
    bool isMaximized = await WindowManager.instance.isMaximized();
    print({'isMaximized':isMaximized});
    isMaximized
        ? await WindowManager.instance.setFullScreen(false)
        : await WindowManager.instance.setFullScreen(true);
  }

  Widget _buildWindowButton(IconData icon, Function() onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      splashRadius: 20,
    );
  }
}
