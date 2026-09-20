import 'package:flutter/material.dart';

final ContextMenuController contextMenuController = ContextMenuController();

class WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;
  final double iconSize;

  const WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: isClose ? Colors.red : Colors.white12,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: iconSize, color: Colors.white),
      ),
    );
  }
}

List<ContextMenuButtonItem> buildContextMenuItems() {
  return <ContextMenuButtonItem>[
    ContextMenuButtonItem(
      label: 'Minimize',
      onPressed: () {
        contextMenuController.remove();
      },
    ),
    ContextMenuButtonItem(
      label: 'Maximize',
      onPressed: () {
        contextMenuController.remove();
      },
    ),
    ContextMenuButtonItem(
      label: 'Close',
      onPressed: () {
        contextMenuController.remove();
      },
    ),
  ];
}
