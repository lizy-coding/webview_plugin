import 'package:logging/logging.dart';

/// Initializes and configures the logging system for the WebView plugin.
///
/// This utility centralizes logging configuration to ensure consistent
/// logging behavior across the plugin.
class LoggerUtil {
  /// Configures the logging system with the specified log level.
  ///
  /// Call this method before using any WebView components to ensure
  /// proper logging setup.
  static void setupLogging({Level logLevel = Level.INFO}) {
    Logger.root.level = logLevel;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
      
      if (record.error != null) {
        // ignore: avoid_print
        print('Error: ${record.error}');
      }
      
      if (record.stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: ${record.stackTrace}');
      }
    });
  }
  
  /// Creates a named logger for a specific component.
  ///
  /// Use this method to create loggers in different components
  /// to easily identify the source of log messages.
  static Logger getLogger(String name) {
    return Logger(name);
  }
}
