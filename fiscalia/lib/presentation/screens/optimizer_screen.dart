import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'home_employment_credit_screen.dart';
import 'child_care_credit_screen.dart';
import 'donation_credit_screen.dart';
import 'school_fees_credit_screen.dart';
import 'union_dues_credit_screen.dart';
import 'alimony_deduction_screen.dart';
import 'device_distribution_screen.dart';
import 'per_tracker_screen.dart';
import 'fiscal_calendar_screen.dart';

class OptimizerScreen extends ConsumerWidget {
  const OptimizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimiser'),
        actions: [
          IconButton(icon: const Icon(Icons.psychology), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRadarFiscal(context),
            const SizedBox(height: 24),
            _buildRecommendations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarFiscal(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Radar Fiscal',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  width: 20,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyse',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez une recommandation pour optimiser vos impôts',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          context,
          icon: Icons.savings,
          title: 'Suivi PER',
          subtitle: 'Gérez vos versements et plafonds',
          economy: 'Optimiser',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerTrackerScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          context,
          icon: Icons.receipt_long,
          title: 'Frais réels',
          subtitle: 'Estimez vos dépenses professionnelles',
          economy: '+1,800 €',
          risk: 1,
          onTap: () {},
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.home,
          title: 'Emploi à domicile',
          subtitle: 'Garde d\'enfants ou ménage',
          economy: '+750 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeEmploymentCreditScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.child_care,
          title: 'Garde d\'enfants',
          subtitle: 'Crèche, assistante maternelle',
          economy: '+1,150 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChildCareCreditScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.favorite,
          title: 'Dons aux associations',
          subtitle: 'Réduction de 66% ou 75%',
          economy: '+330 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DonationCreditScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.school,
          title: 'Frais de scolarité',
          subtitle: 'Enseignement secondaire ou supérieur',
          economy: '+500 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SchoolFeesCreditScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.groups,
          title: 'Cotisations syndicales',
          subtitle: 'Crédit d\'impôt de 66%',
          economy: '+198 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnionDuesCreditScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.family_restroom,
          title: 'Pension alimentaire',
          subtitle: 'Déduction fiscale',
          economy: '+5 000 €',
          risk: 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlimonyDeductionScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.pie_chart,
          title: 'Répartition des dispositifs',
          subtitle: 'Visualisation et analyse',
          economy: '+0 €',
          risk: 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeviceDistributionScreen(),
              ),
            );
          },
        ),
        _buildRecommendationCard(
          context,
          icon: Icons.calendar_today,
          title: 'Calendrier Fiscal',
          subtitle: 'Dates clés et échéances',
          economy: '+0 €',
          risk: 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FiscalCalendarScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String economy,
    required int risk,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accentGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    economy,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.circle,
                        size: 8,
                        color: index < risk
                            ? AppColors.riskLow
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
