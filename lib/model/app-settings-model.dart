class AppSettings {
  final String androidVersion;
  final String? iosVersion;

  AppSettings({
    required this.androidVersion,
    this.iosVersion,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final setting = json['setting'] ?? {};
    return AppSettings(
      androidVersion: setting['android_version']?.toString() ?? "0",
      iosVersion: setting['ios_version']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "setting": {
        "android_version": androidVersion,
        "ios_version": iosVersion,
      }
    };
  }
}
