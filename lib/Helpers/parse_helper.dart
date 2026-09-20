import 'dart:convert';

import 'package:html/parser.dart';

String decodeHtml(String? input) {
  if (input == null) return '';
  return parseFragment(input).text ?? input;
}

String encodeToBase64(String clearText) {
  List<int> clearTextBytes = utf8.encode(clearText);
  return base64Encode(clearTextBytes);
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
