import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/tax_document_model.dart';

void main() {
  group('TaxDocumentModel', () {
    test('should create valid model and copy correctly', () {
      final date = DateTime.now();
      final doc = TaxDocumentModel(
        id: '123',
        fileName: 'fiche_paie.pdf',
        filePath: '/docs/fiche_paie.pdf',
        dateAdded: date,
        documentType: 'pdf',
        extractedText: 'Salaire Net: 2500€',
      );

      expect(doc.id, '123');
      expect(doc.fileName, 'fiche_paie.pdf');
      expect(doc.documentType, 'pdf');

      final copied = doc.copyWith(fileName: 'renamed.pdf');
      expect(copied.id, '123');
      expect(copied.fileName, 'renamed.pdf');
      expect(copied.extractedText, 'Salaire Net: 2500€');
    });
  });
}