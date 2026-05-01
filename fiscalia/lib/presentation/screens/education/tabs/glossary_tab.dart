import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/education_provider.dart';

class GlossaryTab extends ConsumerWidget {
  const GlossaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(glossaryProvider);
    final searchQuery = ref.watch(glossarySearchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un terme (ex: TMI, Quotient...)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          ref.read(glossarySearchQueryProvider.notifier).state =
                              '',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) =>
                ref.read(glossarySearchQueryProvider.notifier).state = value,
          ),
        ),
        Expanded(
          child: terms.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: terms.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    return InkWell(
                      onTap: () => _showTermDefinition(context, term),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  term.term[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                term.term,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showTermDefinition(BuildContext context, term) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                term.term,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                term.definition,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              if (term.crossReferences.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Voir aussi :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: term.crossReferences.map<Widget>((ref) {
                    return Chip(
                      label: Text(ref),
                      backgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      labelStyle: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Ce terme n\'est pas dans le glossaire',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
