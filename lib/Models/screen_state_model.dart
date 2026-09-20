import 'package:flutter/material.dart';

enum ScreenState {
  compact(Size(300, 100), 'compact'),
  classic(Size(300, 290), 'classic'),
  withSorting(Size(700, 290), 'withSorting'),
  edit(Size(700, 460), 'edit'),
  settings(Size(900, 800), 'settings'),
  layout(Size(1000, 750), 'layout');

  final Size windowSize;
  final String label;

  const ScreenState(this.windowSize, this.label);
}
