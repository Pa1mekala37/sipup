import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimezoneHelper {
  TimezoneHelper._();

  static const _channel = MethodChannel('com.pavanmekala.water_reminder/timezone');
  static const _cacheKey = 'cached_timezone_name';

  /// Returns the IANA timezone name (e.g. "Asia/Kolkata").
  /// In the foreground the result comes from Android's TimeZone.getDefault().
  /// In background isolates (WorkManager) the channel handler is unavailable,
  /// so we fall back to the value cached in SharedPreferences by the last
  /// foreground call.  Ultimate fallback is 'UTC'.
  static Future<String> getLocalTimezone() async {
    try {
      final name = await _channel.invokeMethod<String>('getLocalTimezone');
      if (name != null && name.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, name);
        return name;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}

    return 'UTC';
  }
}
