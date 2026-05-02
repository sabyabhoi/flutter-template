import 'package:app/src/core/env/flavor.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Process-wide [Talker] logger.
///
/// Always go through this class — never instantiate `Talker()` ad hoc — so
/// that breadcrumbs from every layer (Riverpod, Dio, errors) end up in the
/// same in-memory log that powers the in-app log viewer (`TalkerScreen`).
class AppLogger {
  AppLogger._();

  static Talker? _instance;

  static Talker get instance {
    final talker = _instance;
    assert(talker != null, 'AppLogger.init() must be called before use.');
    return talker!;
  }

  /// Initialise the singleton. Safe to call multiple times in tests; the
  /// previous instance is replaced.
  static Talker init(Flavor flavor) {
    final talker = TalkerFlutter.init(
      settings: TalkerSettings(
        // Bigger ring buffer in dev so the in-app viewer is more useful.
        maxHistoryItems: flavor.isProd ? 200 : 1000,
      ),
    );
    _instance = talker;
    talker.info('AppLogger initialised for flavor=${flavor.name}');
    return talker;
  }
}
