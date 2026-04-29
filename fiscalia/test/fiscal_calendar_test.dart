import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/fiscal_calendar_model.dart';
import 'package:fiscalia/presentation/providers/fiscal_calendar_provider.dart';

void main() {
  group('FiscalCalendarModel', () {
    test('should create model with correct values', () {
      final event = FiscalCalendarModel(
        id: 'test_1',
        title: 'Test Event',
        description: 'Test Description',
        date: DateTime(2026, 4, 11),
        type: FiscalEventType.declaration,
        department: '1-19',
        isDepartmentSpecific: true,
        isReminderEnabled: true,
        reminderDaysBefore: 7,
      );

      expect(event.id, 'test_1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.date, DateTime(2026, 4, 11));
      expect(event.type, FiscalEventType.declaration);
      expect(event.department, '1-19');
      expect(event.isDepartmentSpecific, true);
      expect(event.isReminderEnabled, true);
      expect(event.reminderDaysBefore, 7);
    });

    test('should serialize to JSON correctly', () {
      final event = FiscalCalendarModel(
        id: 'test_1',
        title: 'Test Event',
        description: 'Test Description',
        date: DateTime(2026, 4, 11),
        type: FiscalEventType.declaration,
        department: '1-19',
        isDepartmentSpecific: true,
        isReminderEnabled: true,
        reminderDaysBefore: 7,
      );

      final json = event.toJson();

      expect(json['id'], 'test_1');
      expect(json['title'], 'Test Event');
      expect(json['description'], 'Test Description');
      expect(json['date'], '2026-04-11T00:00:00.000');
      expect(json['type'], 'declaration');
      expect(json['department'], '1-19');
      expect(json['isDepartmentSpecific'], true);
      expect(json['isReminderEnabled'], true);
      expect(json['reminderDaysBefore'], 7);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test_1',
        'title': 'Test Event',
        'description': 'Test Description',
        'date': '2026-04-11T00:00:00.000',
        'type': 'declaration',
        'department': '1-19',
        'isDepartmentSpecific': true,
        'isReminderEnabled': true,
        'reminderDaysBefore': 7,
      };

      final event = FiscalCalendarModel.fromJson(json);

      expect(event.id, 'test_1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.date, DateTime(2026, 4, 11));
      expect(event.type, FiscalEventType.declaration);
      expect(event.department, '1-19');
      expect(event.isDepartmentSpecific, true);
      expect(event.isReminderEnabled, true);
      expect(event.reminderDaysBefore, 7);
    });

    test('should handle copyWith correctly', () {
      final original = FiscalCalendarModel(
        id: 'test_1',
        title: 'Original Title',
        description: 'Original Description',
        date: DateTime(2026, 4, 11),
        type: FiscalEventType.declaration,
      );

      final copy = original.copyWith(
        title: 'Updated Title',
        reminderDaysBefore: 14,
      );

      expect(copy.id, 'test_1');
      expect(copy.title, 'Updated Title');
      expect(copy.description, 'Original Description');
      expect(copy.date, DateTime(2026, 4, 11));
      expect(copy.type, FiscalEventType.declaration);
      expect(copy.reminderDaysBefore, 14);
    });
  });

  group('FiscalCalendarService', () {
    late FiscalCalendarService service;

    setUp(() {
      service = FiscalCalendarService();
    });

    test('should generate default fiscal calendar with correct events', () {
      final events = service.getDefaultFiscalCalendar();

      expect(events.length, greaterThan(0));
      expect(
        events.any((e) => e.title.contains('Déclaration de revenus')),
        true,
      );
      expect(events.any((e) => e.title.contains('Échéance PER')), true);
      expect(events.any((e) => e.title.contains('Dons aux œuvres')), true);
    });

    test('should get upcoming events correctly', () {
      final events = [
        FiscalCalendarModel(
          id: 'past',
          title: 'Past Event',
          description: 'Past',
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: FiscalEventType.declaration,
        ),
        FiscalCalendarModel(
          id: 'future',
          title: 'Future Event',
          description: 'Future',
          date: DateTime.now().add(const Duration(days: 30)),
          type: FiscalEventType.declaration,
        ),
      ];

      final upcoming = service.getUpcomingEvents(events);

      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'future');
    });

    test('should get events for month correctly', () {
      final events = [
        FiscalCalendarModel(
          id: 'jan',
          title: 'January Event',
          description: 'Jan',
          date: DateTime(2026, 1, 15),
          type: FiscalEventType.declaration,
        ),
        FiscalCalendarModel(
          id: 'feb',
          title: 'February Event',
          description: 'Feb',
          date: DateTime(2026, 2, 15),
          type: FiscalEventType.declaration,
        ),
        FiscalCalendarModel(
          id: 'jan2',
          title: 'January Event 2',
          description: 'Jan2',
          date: DateTime(2026, 1, 20),
          type: FiscalEventType.declaration,
        ),
      ];

      final januaryEvents = service.getEventsForMonth(events, 2026, 1);

      expect(januaryEvents.length, 2);
      expect(januaryEvents.any((e) => e.id == 'jan'), true);
      expect(januaryEvents.any((e) => e.id == 'jan2'), true);
      expect(januaryEvents.any((e) => e.id == 'feb'), false);
    });

    test('should get events needing reminder correctly', () {
      final now = DateTime.now();
      final events = [
        FiscalCalendarModel(
          id: 'soon',
          title: 'Soon Event',
          description: 'Soon',
          date: now.add(const Duration(days: 3)),
          type: FiscalEventType.declaration,
          isReminderEnabled: true,
          reminderDaysBefore: 7,
        ),
        FiscalCalendarModel(
          id: 'far',
          title: 'Far Event',
          description: 'Far',
          date: now.add(const Duration(days: 30)),
          type: FiscalEventType.declaration,
          isReminderEnabled: true,
          reminderDaysBefore: 7,
        ),
        FiscalCalendarModel(
          id: 'disabled',
          title: 'Disabled Reminder',
          description: 'Disabled',
          date: now.add(const Duration(days: 3)),
          type: FiscalEventType.declaration,
          isReminderEnabled: false,
          reminderDaysBefore: 7,
        ),
      ];

      final reminders = service.getEventsNeedingReminder(events);

      expect(reminders.length, 1);
      expect(reminders.first.id, 'soon');
    });

    test('should get department for zip code correctly', () {
      expect(service.getDepartmentForZipCode('75001'), '55-976');
      expect(service.getDepartmentForZipCode('01000'), '1-19');
      expect(service.getDepartmentForZipCode('20000'), '20-54');
      expect(service.getDepartmentForZipCode('55000'), '55-976');
      expect(service.getDepartmentForZipCode(''), '');
    });

    test('should get events for department correctly', () {
      final events = [
        FiscalCalendarModel(
          id: 'specific',
          title: 'Department Specific',
          description: 'Specific',
          date: DateTime(2026, 4, 11),
          type: FiscalEventType.declaration,
          department: '1-19',
          isDepartmentSpecific: true,
        ),
        FiscalCalendarModel(
          id: 'general',
          title: 'General Event',
          description: 'General',
          date: DateTime(2026, 4, 11),
          type: FiscalEventType.declaration,
          isDepartmentSpecific: false,
        ),
      ];

      final deptEvents = service.getEventsForDepartment(events, '1-19');

      expect(deptEvents.length, 2);
      expect(deptEvents.any((e) => e.id == 'specific'), true);
      expect(deptEvents.any((e) => e.id == 'general'), true);
    });

    test('should get days until event correctly', () {
      final now = DateTime.now();
      final event = FiscalCalendarModel(
        id: 'test',
        title: 'Test Event',
        description: 'Test',
        date: DateTime(now.year, now.month, now.day + 15),
        type: FiscalEventType.declaration,
      );

      final days = service.getDaysUntilEvent(event);

      expect(days, inInclusiveRange(14, 16));
    });

    test('should get event type display name correctly', () {
      expect(
        service.getEventTypeDisplayName(FiscalEventType.declaration),
        'Déclaration',
      );
      expect(
        service.getEventTypeDisplayName(FiscalEventType.deadline),
        'Échéance',
      );
      expect(
        service.getEventTypeDisplayName(FiscalEventType.contribution),
        'Cotisation',
      );
      expect(
        service.getEventTypeDisplayName(FiscalEventType.payment),
        'Paiement',
      );
      expect(
        service.getEventTypeDisplayName(FiscalEventType.notification),
        'Notification',
      );
      expect(
        service.getEventTypeDisplayName(FiscalEventType.reminder),
        'Rappel',
      );
    });

    test('should get event type icon correctly', () {
      expect(service.getEventTypeIcon(FiscalEventType.declaration), '📝');
      expect(service.getEventTypeIcon(FiscalEventType.deadline), '⏰');
      expect(service.getEventTypeIcon(FiscalEventType.contribution), '💰');
      expect(service.getEventTypeIcon(FiscalEventType.payment), '💳');
      expect(service.getEventTypeIcon(FiscalEventType.notification), '📧');
      expect(service.getEventTypeIcon(FiscalEventType.reminder), '🔔');
    });
  });
}
