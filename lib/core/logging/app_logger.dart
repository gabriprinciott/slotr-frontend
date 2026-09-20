import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

export 'package:logger/logger.dart' show Level, LogEvent;

/// Custom printer for file logs: plain, clean and structured text without ANSI escape sequences.
class PlainFilePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final timeStr = event.time.toIso8601String();
    final levelStr = event.level.name.toUpperCase().padRight(7);
    final buffer = StringBuffer('[$timeStr] [$levelStr] ${event.message}');

    final lines = <String>[buffer.toString()];

    if (event.error != null) {
      lines.add('  Error: ${event.error}');
    }

    if (event.stackTrace != null) {
      for (final traceLine in event.stackTrace.toString().split('\n')) {
        if (traceLine.trim().isNotEmpty) {
          lines.add('    $traceLine');
        }
      }
    }

    return lines;
  }
}

/// Centralized application logger providing:
/// - Visual, colored and emoji-rich output in the console via [PrettyPrinter].
/// - Persistent, rotated file logging without ANSI escape codes via [AdvancedFileOutput].
/// - Platform-agnostic safe initialization (graceful fallback on Web).
/// - Both static convenience API ([AppLogger.i]) and dependency-injectable instance.
class AppLogger {
  AppLogger._internal({
    required this._consoleLogger,
    this._fileLogger,
    this._logDirectoryPath,
  });

  static AppLogger? _instance;

  /// Global singleton instance.
  static AppLogger get instance {
    _instance ??= _createDefaultConsoleOnly();
    return _instance!;
  }

  final Logger _consoleLogger;
  final Logger? _fileLogger;
  final String? _logDirectoryPath;

  /// Path to the directory where log files are stored (null on Web or if file logging is disabled).
  String? get logDirectoryPath => _logDirectoryPath;

  /// Custom ANSI colors for log levels in console.
  static final Map<Level, AnsiColor> _customLevelColors = {
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: AnsiColor.fg(39),
    Level.info: AnsiColor.fg(76),
    Level.warning: AnsiColor.fg(214),
    Level.error: AnsiColor.fg(196),
    Level.fatal: AnsiColor.fg(198),
  };

  /// Custom emojis for each log level.
  static final Map<Level, String> _customLevelEmojis = {
    Level.trace: '',
    Level.debug: '',
    Level.info: '',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '',
  };

  static AppLogger _createDefaultConsoleOnly() {
    return AppLogger._internal(
      consoleLogger: Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 100,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.dateAndTime,
          levelColors: _customLevelColors,
          levelEmojis: _customLevelEmojis,
          excludePaths: const ['package:slotr_app/core/logging/app_logger.dart'],
        ),
      ),
    );
  }

  /// Initializes the logger. Call this once during app startup (e.g. in `setupInjection`).
  ///
  /// [customLogDirectory]: optional explicit directory path (useful for testing or custom paths).
  /// [enableFileLogging]: whether to write logs to disk (default `true` on non-web platforms).
  /// [maxFileSizeKB]: max size before rotating the log file (default 2048 KB = 2 MB).
  /// [maxRotatedFilesCount]: max number of rotated log files to retain (default 5).
  static Future<AppLogger> init({
    String? customLogDirectory,
    bool enableFileLogging = true,
    int maxFileSizeKB = 2048,
    int maxRotatedFilesCount = 5,
    LogOutput? customFileOutput,
  }) async {
    final consoleLogger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
        levelColors: _customLevelColors,
        levelEmojis: _customLevelEmojis,
        excludePaths: const ['package:slotr_app/core/logging/app_logger.dart'],
      ),
    );

    Logger? fileLogger;
    String? logDirPath;

    if (enableFileLogging && !kIsWeb) {
      try {
        if (customLogDirectory != null) {
          logDirPath = customLogDirectory;
        } else {
          final docsDir = await getApplicationDocumentsDirectory();
          logDirPath = '${docsDir.path}/logs';
        }

        final logDir = Directory(logDirPath);
        if (!logDir.existsSync()) {
          logDir.createSync(recursive: true);
        }

        final fileOutput = customFileOutput ??
            AdvancedFileOutput(
              path: logDirPath,
              maxFileSizeKB: maxFileSizeKB,
              maxRotatedFilesCount: maxRotatedFilesCount,
              latestFileName: 'app.log',
            );

        fileLogger = Logger(
          printer: PlainFilePrinter(),
          output: fileOutput,
        );
      } catch (e, st) {

        consoleLogger.w(
          'Failed to initialize file logging, falling back to console only',
          error: e,
          stackTrace: st,
        );
      }
    }

    final loggerInstance = AppLogger._internal(
      consoleLogger: consoleLogger,
      fileLogger: fileLogger,
      logDirectoryPath: logDirPath,
    );

    _instance = loggerInstance;
    return loggerInstance;
  }



  /// Log a message at [Level.trace].
  void trace(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.t(message, error: err, stackTrace: stackTrace);
    _fileLogger?.t(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [trace].
  void t(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      trace(message, err, stackTrace);

  /// Log a message at [Level.debug].
  void debug(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.d(message, error: err, stackTrace: stackTrace);
    _fileLogger?.d(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [debug].
  void d(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      debug(message, err, stackTrace);

  /// Log a message at [Level.info].
  void info(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.i(message, error: err, stackTrace: stackTrace);
    _fileLogger?.i(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [info].
  void i(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      info(message, err, stackTrace);

  /// Log a message at [Level.warning].
  void warning(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.w(message, error: err, stackTrace: stackTrace);
    _fileLogger?.w(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [warning].
  void w(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      warning(message, err, stackTrace);

  /// Log a message at [Level.error].
  void error(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.e(message, error: err, stackTrace: stackTrace);
    _fileLogger?.e(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [error].
  void e(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      error(message, err, stackTrace);

  /// Log a message at [Level.fatal].
  void fatal(dynamic message, [Object? err, StackTrace? stackTrace]) {
    _consoleLogger.f(message, error: err, stackTrace: stackTrace);
    _fileLogger?.f(message, error: err, stackTrace: stackTrace);
  }

  /// Shorthand for [fatal].
  void f(dynamic message, [Object? err, StackTrace? stackTrace]) =>
      fatal(message, err, stackTrace);



  /// Quick static getter for the singleton instance.
  static AppLogger get I => instance;



  /// Reads the current `app.log` contents from disk if available.
  Future<String?> readLatestLogs() async {
    if (_logDirectoryPath == null) return null;
    final file = File('$_logDirectoryPath/app.log');
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  /// Retrieves all existing log files (including rotated archives).
  Future<List<File>> getLogFiles() async {
    if (_logDirectoryPath == null) return [];
    final dir = Directory(_logDirectoryPath);
    if (!await dir.exists()) return [];
    return dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.log'))
        .cast<File>()
        .toList();
  }

  /// Clears all log files in the log directory.
  Future<void> clearLogs() async {
    final files = await getLogFiles();
    for (final file in files) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}

/// Convenient global accessor for [AppLogger.instance].
AppLogger get log => AppLogger.instance;
