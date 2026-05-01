import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/notification_settings_model.dart';

void main() {
  group('NotificationSettingsModel', () {
    test('should have correct default values', () {
      const settings = NotificationSettingsModel();

      expect(settings.isPushEnabled, isFalse);
      expect(settings.notifyDeadlines, isTrue);
      expect(settings.notifyDeclarations, isTrue);
      expect(settings.notifyPayments, isTrue);
      expect(settings.reminderDaysBefore, 7);
    });

    test('copyWith should update specified fields', () {
      const settings = NotificationSettingsModel();
      final updated = settings.copyWith(
        isPushEnabled: true,
        reminderDaysBefore: 15,
        notifyPayments: false,
      );

      expect(updated.isPushEnabled, isTrue);
      expect(updated.reminderDaysBefore, 15);
      expect(updated.notifyPayments, isFalse);
      
      // Unchanged fields
      expect(updated.notifyDeadlines, isTrue);
      expect(updated.notifyDeclarations, isTrue);
    });
  });
}