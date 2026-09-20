import 'dart:convert';

enum LaunchMode { normal, minimized, backgrounded }

enum Theme { light, dark, system }

enum Language { de, en }

class Settings {
  bool openedBefore; // tells if the app is opened for the first time - for showing layout selection screen or not
  String layoutStyle;
  Theme theme;
  LaunchMode launchMode;
  bool startWithWindows;
  bool alwaysOnTop;
  bool allowNotifications;
  bool showNotificationOnStamp;
  bool showSorting;
  Language language;

  Settings({
    this.openedBefore = false,
    this.layoutStyle = "classic",
    this.theme = Theme.light,
    this.launchMode = LaunchMode.normal,
    this.startWithWindows = true,
    this.alwaysOnTop = false,
    this.allowNotifications = false,
    this.showNotificationOnStamp = false,
    this.showSorting = false,
    this.language = Language.de,
  });

  Settings copyWith({
    bool? openedBefore,
    String? layoutStyle,
    Theme? theme,
    LaunchMode? launchMode,
    bool? startWithWindows,
    bool? alwaysOnTop,
    bool? allowNotifications,
    bool? showNotificationOnStamp,
    bool? confirmTimerStop,
    bool? showKPI,
    Language? language,
  }) {
    return Settings(
      openedBefore: openedBefore ?? this.openedBefore,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      theme: theme ?? this.theme,
      launchMode: launchMode ?? this.launchMode,
      startWithWindows: startWithWindows ?? this.startWithWindows,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      showNotificationOnStamp:
          showNotificationOnStamp ?? this.showNotificationOnStamp,
      showSorting: showKPI ?? this.showSorting,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'opened_before': openedBefore,
    'layout_style': layoutStyle,
    'theme': theme.name,
    'launch_mode': launchMode.name,
    'start_with_windows': startWithWindows,
    'always_on_top': alwaysOnTop,
    'allow_notifications': allowNotifications,
    'show_notifications_on_stamp': showNotificationOnStamp,
    'show_kpi': showSorting,
    'language': language.name,
  };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    openedBefore: json['opened_before'] ?? false,
    layoutStyle: json['layout_style'] ?? "Classic",
    theme: Theme.values.firstWhere(
      (theme) => theme.name == json['theme'],
      orElse: () => Theme.light,
    ),
    launchMode: LaunchMode.values.firstWhere(
      (mode) => mode.name == json['launch_mode'],
      orElse: () => LaunchMode.normal,
    ),
    startWithWindows: json['start_with_windows'] ?? true,
    alwaysOnTop: json['always_on_top'] ?? true,
    allowNotifications: json['allow_notifications'] ?? false,
    showNotificationOnStamp: json['show_notifications_on_stamp'] ?? false,
    showSorting: json['show_kpi'] ?? false,
    language: Language.values.firstWhere(
      (lang) => lang.name == json['language'],
      orElse: () => Language.de,
    ),
  );

  String toJsonString() => jsonEncode(toJson());

  factory Settings.fromJsonString(String value) {
    return Settings.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
