import 'package:hive/hive.dart';

part 'tax_document_model.g.dart';

@HiveType(typeId: 20)
class TaxDocumentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final DateTime dateAdded;

  @HiveField(4)
  final String documentType; // 'pdf' or 'image'

  @HiveField(5)
  final String extractedText;

  const TaxDocumentModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.dateAdded,
    required this.documentType,
    required this.extractedText,
  });

  TaxDocumentModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    DateTime? dateAdded,
    String? documentType,
    String? extractedText,
  }) {
    return TaxDocumentModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      dateAdded: dateAdded ?? this.dateAdded,
      documentType: documentType ?? this.documentType,
      extractedText: extractedText ?? this.extractedText,
    );
  }
}