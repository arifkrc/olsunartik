import 'package:flutter/foundation.dart';

/// Centralized logging utility for the QMS application
///
/// Provides structured logging with different severity levels and emoji prefixes
/// for better visual clarity in debug console. Production-safe and follows
/// Flutter best practices.
///
/// Usage:
/// ```dart
/// AppLogger.info('Connectivity service başlatılıyor...');
/// AppLogger.error('Sync hatası', error: e, stackTrace: stackTrace);
/// AppLogger.debug('Debug bilgisi', tag: 'SyncService');
/// ```
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  /// Log level - can be configured for different environments
  static bool _isDebugMode = kDebugMode;

  /// Debug level log - for development/debugging purposes only
  /// Uses 🔍 emoji prefix
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_isDebugMode) {
      _log('🔍', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Info level log - general information messages
  /// Uses ✅ or appropriate emoji prefix
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ℹ️', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning level log - potential issues that don't prevent operation
  /// Uses ⚠️ emoji prefix
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('⚠️', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Error level log - errors that affect functionality
  /// Uses ❌ emoji prefix
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('❌', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Success level log - successful operations
  /// Uses ✅ emoji prefix
  static void success(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('✅', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Network/connectivity related logs
  /// Uses 📡 or 🌐 emoji prefix
  static void network(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('📡', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Sync operation logs
  /// Uses 🔄 emoji prefix
  static void sync(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('🔄', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Core logging implementation
  static void _log(
    String emoji,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final logMessage = '$emoji $timestamp $tagPrefix$message';

    // Use debugPrint which handles long messages better than print
    debugPrint(logMessage);

    // Log error details if provided
    if (error != null) {
      debugPrint('   ↳ Error: $error');
    }

    // Log stack trace if provided (only in debug mode)
    if (stackTrace != null && _isDebugMode) {
      debugPrint('   ↳ Stack trace:\n$stackTrace');
    }
  }

  /// Configure logger for production mode
  static void setProductionMode(bool isProduction) {
    _isDebugMode = !isProduction;
  }
}
