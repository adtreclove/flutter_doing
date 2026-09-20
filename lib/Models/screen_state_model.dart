import 'package:flutter/material.dart';

enum ScreenState {
  compact(Size(300, 120), 'compact'),
  classic(Size(300, 210), 'classic'),
  withSorting(Size(700, 210), 'withSorting'),
  edit(Size(700, 500), 'edit'),
  settings(Size(900, 800), 'settings'),
  layout(Size(1000, 750), 'layout');

  final Size windowSize;
  final String label;

  const ScreenState(this.windowSize, this.label);
}
