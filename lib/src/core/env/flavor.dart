/// Build-time application flavor.
///
/// Each value maps to a Flutter entrypoint (`lib/main_<flavor>.dart`),
/// a native build flavor (Android product flavor / iOS scheme), and an
/// `env/<flavor>.json` file consumed via `--dart-define-from-file`.
enum Flavor {
  dev,
  staging,
  prod
  ;

  bool get isDev => this == Flavor.dev;
  bool get isStaging => this == Flavor.staging;
  bool get isProd => this == Flavor.prod;

  /// Parse a flavor name (case-insensitive). Throws on unknown values so
  /// that a misconfigured env file fails fast at boot.
  static Flavor fromName(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return Flavor.dev;
      case 'staging':
      case 'stage':
        return Flavor.staging;
      case 'prod':
      case 'production':
        return Flavor.prod;
    }
    throw ArgumentError.value(value, 'value', 'Unknown flavor');
  }
}
