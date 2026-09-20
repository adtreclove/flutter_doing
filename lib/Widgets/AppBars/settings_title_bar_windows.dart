import 'package:flutter/material.dart';
import 'package:flutter_doing/Widgets/AppBars/app_bar_widgets.dart';
import 'package:window_manager/window_manager.dart';

class SettingsTitleBarWindows extends StatelessWidget {
  const SettingsTitleBarWindows({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black,
          height: 40,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(title, style: TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              Material(
                type: MaterialType.transparency,
                child: WindowButton(
                  icon: Icons.remove,
                  onPressed: () => windowManager.minimize(),
                ),
              ),

              Material(
                type: MaterialType.transparency,
                child: WindowButton(
                  icon: Icons.close,
                  isClose: true,
                  onPressed: () => windowManager.close(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
