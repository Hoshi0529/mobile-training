import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/menu.dart';

class RestDayNotificationService {
  RestDayNotificationService._();

  static final RestDayNotificationService instance =
      RestDayNotificationService._();

  static const MethodChannel _channel = MethodChannel(
    'alcohol_record/rest_day_notification',
  );

  Future<void> configure(AppSettings settings) async {
    final supportedPlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (kIsWeb || !supportedPlatform) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('configure', {
        'enabled': settings.reminderEnabled,
        'restDays': settings.restDays,
      });
    } on MissingPluginException {
      // Android-only platform code is not available in widget tests/desktop.
    } on PlatformException {
      // Notification scheduling should never block the app UI.
    }
  }
}
