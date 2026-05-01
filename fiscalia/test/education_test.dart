import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiscalia/presentation/providers/education_provider.dart';

void main() {
  group('Education Providers', () {
    test('educationalSheetsProvider should return all sheets', () {
      final container = ProviderContainer();
      final sheets = container.read(educationalSheetsProvider);
      
      expect(sheets.isNotEmpty, isTrue);
      expect(sheets.any((s) => s.id == 'per'), isTrue);
      expect(sheets.any((s) => s.id == 'lmnp'), isTrue);
      
      container.dispose();
    });

    test('selectedSheetProvider should return correct sheet by ID', () {
      final container = ProviderContainer();
      
      final perSheet = container.read(selectedSheetProvider('per'));
      expect(perSheet, isNotNull);
      expect(perSheet!.title, contains('PER'));

      final invalidSheet = container.read(selectedSheetProvider('invalid_id'));
      expect(invalidSheet, isNull);
      
      container.dispose();
    });

    test('faqProvider should filter items based on search query', () {
      final container = ProviderContainer();
      
      // Default (empty query) returns all
      final allFaqs = container.read(faqProvider);
      expect(allFaqs.length, greaterThan(1));

      // Search specific term
      container.read(faqSearchQueryProvider.notifier).state = 'PAS';
      final filteredFaqs = container.read(faqProvider);
      
      expect(filteredFaqs.length, greaterThanOrEqualTo(1));
      expect(filteredFaqs.first.question, contains('PAS'));

      // Search tags
      container.read(faqSearchQueryProvider.notifier).state = 'Calendrier';
      final tagFilteredFaqs = container.read(faqProvider);
      
      expect(tagFilteredFaqs.isNotEmpty, isTrue);
      expect(tagFilteredFaqs.first.tags, contains('Calendrier'));
      
      container.dispose();
    });

    test('glossaryProvider should sort alphabetically and filter correctly', () {
      final container = ProviderContainer();
      
      // Test sorting
      final allTerms = container.read(glossaryProvider);
      expect(allTerms.isNotEmpty, isTrue);
      
      // Check if sorted alphabetically
      for (int i = 0; i < allTerms.length - 1; i++) {
        expect(allTerms[i].term.compareTo(allTerms[i+1].term) <= 0, isTrue);
      }

      // Test search
      container.read(glossarySearchQueryProvider.notifier).state = 'quotient';
      final filteredTerms = container.read(glossaryProvider);
      
      expect(filteredTerms.length, greaterThanOrEqualTo(1));
      expect(filteredTerms.first.term, contains('Quotient'));
      
      container.dispose();
    });
  });
}