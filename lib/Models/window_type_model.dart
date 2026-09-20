enum AppWindowType { main, settings, edit }

class WindowType {
  const WindowType({
    required this.id,
    required this.type,
    this.arguments = const {},
  });

  final String id;
  final AppWindowType type;
  final Map<String, dynamic> arguments;
}
