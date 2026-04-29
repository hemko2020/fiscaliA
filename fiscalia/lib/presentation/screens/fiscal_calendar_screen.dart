import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/fiscal_calendar_model.dart';
import '../providers/fiscal_calendar_provider.dart';

class FiscalCalendarScreen extends ConsumerStatefulWidget {
  const FiscalCalendarScreen({super.key});

  @override
  ConsumerState<FiscalCalendarScreen> createState() =>
      _FiscalCalendarScreenState();
}

class _FiscalCalendarScreenState extends ConsumerState<FiscalCalendarScreen> {
  late PageController _pageController;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: DateTime.now().month - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showZipCodeDialog(BuildContext context) {
    final currentZipCode = ref.read(userZipCodeProvider);
    final controller = TextEditingController(text: currentZipCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Votre département'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre code postal pour obtenir les dates limites de déclaration spécifiques à votre département.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: const InputDecoration(
                labelText: 'Code postal',
                hintText: 'Ex: 75001',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.length >= 2) {
                ref
                    .read(userZipCodeProvider.notifier)
                    .setZipCode(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(fiscalCalendarProvider);
    final service = ref.watch(fiscalCalendarServiceProvider);
    final zipCode = ref.watch(userZipCodeProvider);

    final upcomingEvents = service.getUpcomingEvents(events);
    final currentMonthEvents = service.getEventsForMonth(
      events,
      _currentMonth.year,
      _currentMonth.month,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier Fiscal'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Définir le département',
            onPressed: () => _showZipCodeDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationBanner(context, zipCode, service),
            const SizedBox(height: 16),
            _buildUpcomingEventsSection(context, upcomingEvents, service),
            const SizedBox(height: 24),
            _buildMonthlyCalendarSection(context, currentMonthEvents, service),
            const SizedBox(height: 24),
            _buildEventTypesLegend(context, service),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBanner(
    BuildContext context,
    String zipCode,
    FiscalCalendarService service,
  ) {
    final hasZipCode = zipCode.isNotEmpty;
    final departmentInfo = hasZipCode
        ? 'Département: ${zipCode.substring(0, 2)} (Zone ${service.getDepartmentForZipCode(zipCode)})'
        : 'Département non renseigné';

    return InkWell(
      onTap: () => _showZipCodeDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasZipCode
              ? AppColors.accentGreen.withValues(alpha: 0.1)
              : AppColors.accentOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasZipCode
                ? AppColors.accentGreen.withValues(alpha: 0.5)
                : AppColors.accentOrange.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasZipCode ? Icons.check_circle : Icons.warning_amber,
              color: hasZipCode
                  ? AppColors.accentGreen
                  : AppColors.accentOrange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departmentInfo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hasZipCode
                          ? AppColors.accentGreen
                          : AppColors.accentOrange,
                    ),
                  ),
                  Text(
                    hasZipCode
                        ? 'Dates limites adaptées à votre département'
                        : 'Appuyez pour personnaliser vos dates limites',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsSection(
    BuildContext context,
    List<FiscalCalendarModel> events,
    FiscalCalendarService service,
  ) {
    if (events.isEmpty) {
      return Card(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun événement fiscal à venir',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous êtes à jour avec vos obligations fiscales',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.upcoming, color: AppColors.accentOrange),
            const SizedBox(width: 12),
            Text(
              'Prochains événements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...events
            .take(5)
            .map((event) => _buildEventCard(context, event, service)),
        if (events.length > 5) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              '+ ${events.length - 5} autres événements',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    FiscalCalendarModel event,
    FiscalCalendarService service,
  ) {
    final daysUntil = service.getDaysUntilEvent(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event.type).withValues(alpha: 0.2),
          child: Text(
            service.getEventTypeIcon(event.type),
            style: TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Text(
              _formatEventDate(event.date),
              style: TextStyle(
                color: daysUntil <= 7 ? AppColors.accentOrange : Colors.grey,
                fontWeight: daysUntil <= 7
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (daysUntil <= 30) ...[
              const SizedBox(height: 4),
              Text(
                daysUntil == 0
                    ? "Aujourd'hui"
                    : daysUntil == 1
                    ? "Demain"
                    : "Dans $daysUntil jours",
                style: TextStyle(
                  color: daysUntil <= 7
                      ? AppColors.accentOrange
                      : AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        trailing: daysUntil <= 7
            ? Icon(Icons.priority_high, color: AppColors.accentOrange, size: 24)
            : null,
      ),
    );
  }

  Widget _buildMonthlyCalendarSection(
    BuildContext context,
    List<FiscalCalendarModel> events,
    FiscalCalendarService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _formatMonthYear(_currentMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (events.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Aucun événement en ${_formatMonthYear(_currentMonth)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ] else ...[
          ...events.map(
            (event) => _buildCompactEventCard(context, event, service),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactEventCard(
    BuildContext context,
    FiscalCalendarModel event,
    FiscalCalendarService service,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getEventColor(event.type).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${event.date.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getEventColor(event.type),
              ),
            ),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          event.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.circle,
          color: _getEventColor(event.type),
          size: 12,
        ),
      ),
    );
  }

  Widget _buildEventTypesLegend(
    BuildContext context,
    FiscalCalendarService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Types d\'événements',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: FiscalEventType.values
              .map(
                (type) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: _getEventColor(type), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      service.getEventTypeDisplayName(type),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Color _getEventColor(FiscalEventType type) {
    switch (type) {
      case FiscalEventType.declaration:
        return AppColors.primaryBlue;
      case FiscalEventType.deadline:
        return AppColors.accentOrange;
      case FiscalEventType.contribution:
        return AppColors.accentGreen;
      case FiscalEventType.payment:
        return Colors.purple;
      case FiscalEventType.notification:
        return Colors.teal;
      case FiscalEventType.reminder:
        return Colors.amber;
    }
  }

  String _formatEventDate(DateTime date) {
    final days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${days[date.weekday % 7]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        _currentMonth.day,
      );
    });
  }
}
