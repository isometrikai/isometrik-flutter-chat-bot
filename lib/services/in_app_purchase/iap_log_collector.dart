import 'dart:async';
import 'dart:io';

import 'package:chat_bot/services/in_app_purchase/iap_service.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists subscription/IAP debug logs so they can be shared without Xcode.
///
/// Captures lines prefixed with `IAP`, `IAP-BLOC`, or `IAP-API`.
class IapLogCollector {
  IapLogCollector._();

  static final IapLogCollector instance = IapLogCollector._();

  static const String _prefsKey = 'iap_subscription_debug_log_v1';
  static const int _maxStoredChars = 350000;

  final List<String> _lines = <String>[];
  bool _loaded = false;
  Timer? _persistTimer;
  Future<void>? _loadFuture;

  bool _shouldCapture(String message) {
    return message.startsWith('IAP |') ||
        message.startsWith('IAP-BLOC |') ||
        message.startsWith('IAP-API |');
  }

  Future<void> ensureLoaded() {
    return _loadFuture ??= _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null && stored.isNotEmpty) {
        _lines.addAll(stored.split('\n').where((line) => line.isNotEmpty));
      }
    } catch (_) {
      // Ignore corrupt prefs — start fresh.
    }
    _loaded = true;
  }

  /// [message] must be the same string sent to `print` (e.g. `IAP | INFO | ...`).
  void log(String message) {
    if (!_shouldCapture(message)) return;

    unawaited(ensureLoaded().then((_) {
      final line = '${DateTime.now().toIso8601String()} | $message';
      _lines.add(line);
      _trimToLimit();
      _schedulePersist();
    }));
  }

  void _trimToLimit() {
    while (_lines.isNotEmpty && _lines.join('\n').length > _maxStoredChars) {
      _lines.removeAt(0);
    }
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 400), () {
      unawaited(_persistToDisk());
    });
  }

  Future<void> _persistToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _lines.join('\n'));
    } catch (_) {
      // Best-effort persistence.
    }
  }

  Future<String> buildReport() async {
    await ensureLoaded();

    final packageInfo = await PackageInfo.fromPlatform();
    final entitlement = await IapService.instance.getEntitlement();
    final buffer = StringBuffer()
      ..writeln('=== EAZY Subscription / IAP Debug Log ===')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'App: ${packageInfo.appName} ${packageInfo.version}+${packageInfo.buildNumber}',
      )
      ..writeln('Platform: ${Platform.operatingSystem} | debug=$kDebugMode')
      ..writeln('User email: ${Utility.getEmailId()}')
      ..writeln('User name: ${Utility.getName()}')
      ..writeln('Store available: ${IapService.instance.isAvailable}')
      ..writeln('Store initialized: ${IapService.instance.isInitialized}')
      ..writeln(
        'Entitlement: ${entitlement == null ? "none" : entitlement.productId} | '
        'autoRenew=${entitlement?.autoRenew} | '
        'tx=${entitlement?.transactionId} | '
        'active=${entitlement?.isActive}',
      )
      ..writeln('Log lines: ${_lines.length}')
      ..writeln('---')
      ..writeln(_lines.join('\n'));

    return buffer.toString();
  }

  /// Opens the system share sheet (Mail, Messages, Files, etc.).
  Future<bool> shareLogs({Rect? sharePositionOrigin}) async {
    final report = await buildReport();
    if (report.trim().isEmpty || _lines.isEmpty) {
      return false;
    }

    const subject = 'EAZY IAP Subscription Debug Log';
    const maxInlineChars = 45000;

    if (report.length <= maxInlineChars) {
      await Share.share(
        report,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
      return true;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/iap_subscription_log_'
      '${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    await file.writeAsString(report);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/plain',
          name: file.uri.pathSegments.last,
        ),
      ],
      subject: subject,
      text: 'EAZY subscription/IAP debug log attached.',
      sharePositionOrigin: sharePositionOrigin,
    );
    return true;
  }

  Future<void> flush() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    await _persistToDisk();
  }
}
