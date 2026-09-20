import 'dart:io';

import 'package:flutter/foundation.dart';

void DebugPrint(String debugLog, [bool withColor = false]) {
  if (!kDebugMode) return;

  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  final ts =
      '${two(now.hour)}:${two(now.minute)}:${two(now.second)}.${three(now.millisecond)}';

  final msg = '[$ts] $debugLog';

  if (Platform.isAndroid) {
    if (withColor) {
      print(msg);
    } else {
      print('${colorCodes['magenta']}$msg${colorCodes['reset']}');
    }
  } else {
    print(msg);
  }
}

void coloredLog(String message, {String color = 'reset'}) {
  final selectedColor = colorCodes[color.toLowerCase()] ?? colorCodes['reset'];
  DebugPrint('$selectedColor$message${colorCodes['reset']}', true);
}

final colorCodes = {
  'black': '\x1B[30m',
  'red': '\x1B[31m',
  'green': '\x1B[32m',
  'yellow': '\x1B[33m',
  'blue': '\x1B[34m',
  'magenta': '\x1B[35m',
  'cyan': '\x1B[36m',
  'white': '\x1B[37m',
  'reset': '\x1B[0m',
};
