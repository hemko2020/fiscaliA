import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/education_provider.dart';

class ContentSheetScreen extends ConsumerWidget {
  final String sheetId;

  const ContentSheetScreen({super.key, required this.sheetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(selectedSheetProvider(sheetId));

    if (sheet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fiche Introuvable')),
        body: const Center(child: Text('Cette fiche n\'existe pas.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sheet.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'C\'est quoi ?',
              content: sheet.whatIsIt,
              icon: Icons.lightbulb_outline,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Comment ça marche ?',
              content: sheet.howItWorks,
              icon: Icons.settings,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Plafonds & Limites',
              content: sheet.ceilings,
              icon: Icons.block,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Avantages',
              content: sheet.benefits,
              icon: Icons.star_border,
              isList: true,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Exemple concret',
              content: sheet.examples,
              icon: Icons.calculate,
              backgroundColor: AppColors.accentGreen.withValues(alpha: 0.1),
              iconColor: AppColors.accentGreen,
            ),
            const SizedBox(height: 24),
            _buildExpandableSection(
              context,
              title: 'Détails Techniques',
              content: sheet.technicalDetails,
              icon: Icons.article_outlined,
            ),
            const SizedBox(height: 24),
            if (sheet.relatedTerms.isNotEmpty)
              _buildRelatedTerms(context, sheet.relatedTerms),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    bool isList = false,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: backgroundColor != null
          ? const EdgeInsets.all(16)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor ?? AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedTerms(BuildContext context, List<String> terms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Termes associés',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms.map((term) {
            return Chip(
              label: Text(term),
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              labelStyle: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
