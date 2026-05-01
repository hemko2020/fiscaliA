import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/education_models.dart';
import '../../data/repositories/education_repository.dart';

// --- Educational Sheets ---
final educationalSheetsProvider = Provider<List<EducationalSheetModel>>((ref) {
  return EducationRepository.sheets;
});

final selectedSheetProvider = Provider.family<EducationalSheetModel?, String>((
  ref,
  id,
) {
  return EducationRepository.sheets
      .where((sheet) => sheet.id == id)
      .firstOrNull;
});

// --- FAQ ---
final faqSearchQueryProvider = StateProvider<String>((ref) => '');

final faqProvider = Provider<List<FaqItemModel>>((ref) {
  final query = ref.watch(faqSearchQueryProvider).toLowerCase();
  final allFaqs = EducationRepository.faqItems;

  if (query.isEmpty) return allFaqs;

  return allFaqs.where((faq) {
    return faq.question.toLowerCase().contains(query) ||
        faq.answer.toLowerCase().contains(query) ||
        faq.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});

// --- Glossary ---
final glossarySearchQueryProvider = StateProvider<String>((ref) => '');

final glossaryProvider = Provider<List<GlossaryTermModel>>((ref) {
  final query = ref.watch(glossarySearchQueryProvider).toLowerCase();
  final allTerms = EducationRepository.glossaryTerms;

  // Sort alphabetically by default
  final sortedTerms = List<GlossaryTermModel>.from(allTerms)
    ..sort((a, b) => a.term.compareTo(b.term));

  if (query.isEmpty) return sortedTerms;

  return sortedTerms.where((term) {
    return term.term.toLowerCase().contains(query) ||
        term.definition.toLowerCase().contains(query);
  }).toList();
});
