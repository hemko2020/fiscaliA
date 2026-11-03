import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';
import 'advanced_devices_screen.dart';
import 'education/educational_center_screen.dart';
import 'fiscal_calendar_screen.dart';
import 'paywall_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Outils',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.workspace_premium,
                title: 'Dispositifs premium',
                subtitle: 'PER, LMNP, SCI, démembrement, Dutreil, IFI...',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedDevicesScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.calendar_today,
                title: 'Calendrier fiscal',
                subtitle: 'Dates importantes et échéances',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FiscalCalendarScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.school,
                title: 'Centre éducatif',
                subtitle: 'Fiches explicatives et FAQ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EducationalCenterScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.book,
                title: 'Glossaire',
                subtitle: 'Lexique des termes fiscaux',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Compte',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.person,
                title: 'Mon profil',
                subtitle: 'Situation familiale et paramètres',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.workspace_premium,
                title: 'Abonnement',
                subtitle: _sousTitreAbonnement(ref),
                onTap: () => PaywallScreen.ouvrir(context),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Application',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Configurer les rappels',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.dark_mode,
                title: 'Apparence',
                subtitle: 'Mode clair/sombre',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.language,
                title: 'Langue',
                subtitle: 'Français',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'À propos',
            children: [
              _buildMenuItem(
                context,
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.description,
                title: 'CGU',
                subtitle: 'Conditions générales',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.privacy_tip,
                title: 'Confidentialité',
                subtitle: 'Politique de confidentialité',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.help,
                title: 'Aide & Contact',
                subtitle: 'FAQ et support',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security,
                      color: AppColors.accentGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '100% local - Vos données ne quittent jamais votre appareil',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'FiscalIA - Barème 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _sousTitreAbonnement(WidgetRef ref) {
    final niveau = ref.watch(subscriptionProvider).niveau;
    return switch (niveau) {
      NiveauAbonnement.expert => 'FiscalIA Expert - Actif',
      NiveauAbonnement.pro => 'FiscalIA Pro - Actif',
      NiveauAbonnement.gratuit => 'Gratuit - Passer premium',
    };
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
