import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_settings_model.dart';
import '../providers/notification_provider.dart';
import '../providers/fiscal_calendar_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _updateAndReschedule(WidgetRef ref, NotificationSettingsModel settings) async {
    final notifier = ref.read(notificationSettingsProvider.notifier);
    await notifier.updateSettings(settings);

    final notificationService = ref.read(notificationServiceProvider);
    final events = ref.read(fiscalCalendarProvider);
    if (settings.isPushEnabled) {
      await notificationService.scheduleEventNotifications(events);
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainSwitch(context, settings, notifier, ref),
          const SizedBox(height: 24),
          if (settings.isPushEnabled) ...[
            _buildSectionTitle(context, 'Types de notifications'),
            _buildSettingsCard(
              children: [
                SwitchListTile(
                  title: const Text('Échéances (ex: PER)'),
                  subtitle: const Text('Rappels pour les dates limites de cotisation'),
                  value: settings.notifyDeadlines,
                  onChanged: (value) {
                    _updateAndReschedule(ref, settings.copyWith(notifyDeadlines: value));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Déclarations'),
                  subtitle: const Text('Rappels pour les périodes de déclaration d\'impôts'),
                  value: settings.notifyDeclarations,
                  onChanged: (value) {
                    _updateAndReschedule(ref, settings.copyWith(notifyDeclarations: value));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Paiements'),
                  subtitle: const Text('Rappels pour les échéances de paiement'),
                  value: settings.notifyPayments,
                  onChanged: (value) {
                    _updateAndReschedule(ref, settings.copyWith(notifyPayments: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Délai de rappel'),
            _buildSettingsCard(
              children: [
                ListTile(
                  title: const Text('M\'avertir avant l\'événement'),
                  subtitle: Text('${settings.reminderDaysBefore} jours avant'),
                  trailing: DropdownButton<int>(
                    value: settings.reminderDaysBefore,
                    items: [1, 3, 7, 15, 30].map((days) {
                      return DropdownMenuItem<int>(
                        value: days,
                        child: Text('$days jours'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateAndReschedule(ref, settings.copyWith(reminderDaysBefore: value));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainSwitch(BuildContext context, NotificationSettingsModel settings, NotificationSettingsNotifier notifier, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: const Text(
          'Activer les notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Recevoir des rappels pour les dates fiscales importantes'),
        value: settings.isPushEnabled,
        activeTrackColor: AppColors.accentGreen,
        onChanged: (value) async {
          if (value) {
            final granted = await notifier.requestPermissions();
            if (granted) {
              _updateAndReschedule(ref, settings.copyWith(isPushEnabled: true));
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les permissions de notification ont été refusées.'),
                  ),
                );
              }
            }
          } else {
            _updateAndReschedule(ref, settings.copyWith(isPushEnabled: false));
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}