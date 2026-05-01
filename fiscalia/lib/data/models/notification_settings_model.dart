import 'package:hive/hive.dart';

part 'notification_settings_model.g.dart';

@HiveType(typeId: 18)
class NotificationSettingsModel {
  @HiveField(0)
  final bool isPushEnabled;

  @HiveField(1)
  final bool notifyDeadlines;

  @HiveField(2)
  final bool notifyDeclarations;

  @HiveField(3)
  final bool notifyPayments;

  @HiveField(4)
  final int reminderDaysBefore;

  const NotificationSettingsModel({
    this.isPushEnabled = false,
    this.notifyDeadlines = true,
    this.notifyDeclarations = true,
    this.notifyPayments = true,
    this.reminderDaysBefore = 7,
  });

  NotificationSettingsModel copyWith({
    bool? isPushEnabled,
    bool? notifyDeadlines,
    bool? notifyDeclarations,
    bool? notifyPayments,
    int? reminderDaysBefore,
  }) {
    return NotificationSettingsModel(
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      notifyDeadlines: notifyDeadlines ?? this.notifyDeadlines,
      notifyDeclarations: notifyDeclarations ?? this.notifyDeclarations,
      notifyPayments: notifyPayments ?? this.notifyPayments,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}
