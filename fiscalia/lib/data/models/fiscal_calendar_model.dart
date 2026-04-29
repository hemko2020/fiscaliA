import 'package:hive/hive.dart';

part 'fiscal_calendar_model.g.dart';

@HiveType(typeId: 16)
class FiscalCalendarModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final FiscalEventType type;

  @HiveField(5)
  final String department;

  @HiveField(6)
  final bool isDepartmentSpecific;

  @HiveField(7)
  final bool isReminderEnabled;

  @HiveField(8)
  final int reminderDaysBefore;

  const FiscalCalendarModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.department = '',
    this.isDepartmentSpecific = false,
    this.isReminderEnabled = true,
    this.reminderDaysBefore = 7,
  });

  FiscalCalendarModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    FiscalEventType? type,
    String? department,
    bool? isDepartmentSpecific,
    bool? isReminderEnabled,
    int? reminderDaysBefore,
  }) {
    return FiscalCalendarModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      department: department ?? this.department,
      isDepartmentSpecific: isDepartmentSpecific ?? this.isDepartmentSpecific,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.name,
      'department': department,
      'isDepartmentSpecific': isDepartmentSpecific,
      'isReminderEnabled': isReminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  factory FiscalCalendarModel.fromJson(Map<String, dynamic> json) {
    return FiscalCalendarModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: FiscalEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FiscalEventType.declaration,
      ),
      department: json['department'] ?? '',
      isDepartmentSpecific: json['isDepartmentSpecific'] ?? false,
      isReminderEnabled: json['isReminderEnabled'] ?? true,
      reminderDaysBefore: json['reminderDaysBefore'] ?? 7,
    );
  }
}

@HiveType(typeId: 17)
enum FiscalEventType {
  @HiveField(0)
  declaration,

  @HiveField(1)
  deadline,

  @HiveField(2)
  contribution,

  @HiveField(3)
  payment,

  @HiveField(4)
  notification,

  @HiveField(5)
  reminder,
}
