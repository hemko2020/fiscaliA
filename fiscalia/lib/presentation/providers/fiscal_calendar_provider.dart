import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/fiscal_calendar_model.dart';

final userZipCodeProvider = StateNotifierProvider<ZipCodeNotifier, String>((
  ref,
) {
  return ZipCodeNotifier();
});

class ZipCodeNotifier extends StateNotifier<String> {
  ZipCodeNotifier()
    : super(Hive.box('settings').get('zipCode', defaultValue: ''));

  void setZipCode(String zipCode) {
    Hive.box('settings').put('zipCode', zipCode);
    state = zipCode;
  }
}

final fiscalCalendarProvider = Provider<List<FiscalCalendarModel>>((ref) {
  final service = ref.watch(fiscalCalendarServiceProvider);
  final zipCode = ref.watch(userZipCodeProvider);

  final allEvents = service.getDefaultFiscalCalendar();

  if (zipCode.isEmpty) {
    return allEvents;
  }

  final department = service.getDepartmentForZipCode(zipCode);

  return allEvents.where((event) {
    if (!event.isDepartmentSpecific) return true;
    return event.department == department;
  }).toList();
});

final fiscalCalendarServiceProvider = Provider<FiscalCalendarService>((ref) {
  return FiscalCalendarService();
});

class FiscalCalendarService {
  List<FiscalCalendarModel> getDefaultFiscalCalendar() {
    final currentYear = DateTime.now().year;

    return [
      // Déclaration de revenus
      FiscalCalendarModel(
        id: 'income_declaration_1',
        title: 'Déclaration de revenus - Départ 1-19',
        description: 'Période de déclaration pour les départements 1 à 19',
        date: DateTime(currentYear, 4, 11),
        type: FiscalEventType.declaration,
        department: '1-19',
        isDepartmentSpecific: true,
        reminderDaysBefore: 7,
      ),
      FiscalCalendarModel(
        id: 'income_declaration_2',
        title: 'Déclaration de revenus - Départ 20-54',
        description: 'Période de déclaration pour les départements 20 à 54',
        date: DateTime(currentYear, 4, 18),
        type: FiscalEventType.declaration,
        department: '20-54',
        isDepartmentSpecific: true,
        reminderDaysBefore: 7,
      ),
      FiscalCalendarModel(
        id: 'income_declaration_3',
        title: 'Déclaration de revenus - Départ 55-976',
        description: 'Période de déclaration pour les départements 55 à 976',
        date: DateTime(currentYear, 4, 25),
        type: FiscalEventType.declaration,
        department: '55-976',
        isDepartmentSpecific: true,
        reminderDaysBefore: 7,
      ),

      // PER - Échéance 31 décembre
      FiscalCalendarModel(
        id: 'per_deadline',
        title: 'Échéance PER',
        description:
            'Dernier jour pour verser sur votre PER et déduire vos revenus 2026',
        date: DateTime(currentYear, 12, 31),
        type: FiscalEventType.contribution,
        reminderDaysBefore: 30,
      ),

      // Don aux œuvres - Échéance 31 décembre
      FiscalCalendarModel(
        id: 'donations_deadline',
        title: 'Échéance Dons aux œuvres',
        description:
            'Dernier jour pour faire vos dons et bénéficier de la réduction d\'impôt',
        date: DateTime(currentYear, 12, 31),
        type: FiscalEventType.contribution,
        reminderDaysBefore: 15,
      ),

      // Paiement de l'impôt - Échéances
      FiscalCalendarModel(
        id: 'tax_payment_1',
        title: 'Paiement de l\'impôt - 1ère échéance',
        description:
            'Premier paiement de votre impôt sur le revenu (option mensuelle)',
        date: DateTime(currentYear, 1, 15),
        type: FiscalEventType.payment,
        reminderDaysBefore: 3,
      ),
      FiscalCalendarModel(
        id: 'tax_payment_2',
        title: 'Paiement de l\'impôt - 2ème échéance',
        description:
            'Deuxième paiement de votre impôt sur le revenu (option mensuelle)',
        date: DateTime(currentYear, 2, 15),
        type: FiscalEventType.payment,
        reminderDaysBefore: 3,
      ),

      // Avis d'imposition
      FiscalCalendarModel(
        id: 'tax_notice',
        title: 'Avis d\'imposition',
        description:
            'Réception de votre avis d\'imposition et du montant à payer',
        date: DateTime(currentYear, 7, 15),
        type: FiscalEventType.notification,
        reminderDaysBefore: 7,
      ),

      // Taxe d'habitation (si applicable)
      FiscalCalendarModel(
        id: 'housing_tax',
        title: 'Taxe d\'habitation',
        description:
            'Paiement de la taxe d\'habitation (pour les contribuables concernés)',
        date: DateTime(currentYear, 11, 15),
        type: FiscalEventType.payment,
        reminderDaysBefore: 7,
      ),

      // Prime pour l'emploi
      FiscalCalendarModel(
        id: 'employment_bonus',
        title: 'Prime pour l\'emploi',
        description: 'Versement de la prime pour l\'emploi (si éligible)',
        date: DateTime(currentYear, 2, 5),
        type: FiscalEventType.payment,
        reminderDaysBefore: 3,
      ),
    ];
  }

  List<FiscalCalendarModel> getUpcomingEvents(
    List<FiscalCalendarModel> events,
  ) {
    final now = DateTime.now();
    return events.where((event) => event.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FiscalCalendarModel> getEventsForMonth(
    List<FiscalCalendarModel> events,
    int year,
    int month,
  ) {
    return events
        .where((event) => event.date.year == year && event.date.month == month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<FiscalCalendarModel> getEventsNeedingReminder(
    List<FiscalCalendarModel> events,
  ) {
    final now = DateTime.now();
    return events.where((event) {
      if (!event.isReminderEnabled) return false;

      final reminderDate = event.date.subtract(
        Duration(days: event.reminderDaysBefore),
      );
      final reminderEndDate = event.date;

      return now.isAfter(reminderDate) && now.isBefore(reminderEndDate);
    }).toList();
  }

  String getDepartmentForZipCode(String zipCode) {
    if (zipCode.isEmpty) return '';

    final departmentCode = int.tryParse(zipCode.substring(0, 2)) ?? 0;

    if (departmentCode >= 1 && departmentCode <= 19) return '1-19';
    if (departmentCode >= 20 && departmentCode <= 54) return '20-54';
    if (departmentCode >= 55 && departmentCode <= 99) return '55-976';

    return '1-19'; // Défaut
  }

  List<FiscalCalendarModel> getEventsForDepartment(
    List<FiscalCalendarModel> events,
    String department,
  ) {
    return events.where((event) {
      if (!event.isDepartmentSpecific) return true;
      return event.department == department;
    }).toList();
  }

  int getDaysUntilEvent(FiscalCalendarModel event) {
    final now = DateTime.now();
    return event.date.difference(now).inDays;
  }

  String getEventTypeDisplayName(FiscalEventType type) {
    switch (type) {
      case FiscalEventType.declaration:
        return 'Déclaration';
      case FiscalEventType.deadline:
        return 'Échéance';
      case FiscalEventType.contribution:
        return 'Cotisation';
      case FiscalEventType.payment:
        return 'Paiement';
      case FiscalEventType.notification:
        return 'Notification';
      case FiscalEventType.reminder:
        return 'Rappel';
    }
  }

  String getEventTypeIcon(FiscalEventType type) {
    switch (type) {
      case FiscalEventType.declaration:
        return '📝';
      case FiscalEventType.deadline:
        return '⏰';
      case FiscalEventType.contribution:
        return '💰';
      case FiscalEventType.payment:
        return '💳';
      case FiscalEventType.notification:
        return '📧';
      case FiscalEventType.reminder:
        return '🔔';
    }
  }
}
