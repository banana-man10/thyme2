import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Container(
                // Use a Container for alignment and padding
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 2.0),
                child: const Text(
                  'Thyme',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          const WindowButtons(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40); // Standard app bar height
}


class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minimize Button
        IconButton(
          icon: const Icon(Icons.minimize, color: Colors.white, size: 20),
          onPressed: () => windowManager.minimize(),
          splashRadius: 20,
          hoverColor: Colors.white.withOpacity(0.1),
        ),
        
        // Maximize / Restore Button
        IconButton(
          icon: const Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18),
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          splashRadius: 20,
          hoverColor: Colors.white.withOpacity(0.1),
        ),
        
        // Close Button
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: () => windowManager.close(),
          splashRadius: 20,
          hoverColor: Colors.red.withOpacity(0.8),
        ),
        const SizedBox(width: 0),
      ],
    );
  }
}