import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tax_document_model.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final TaxDocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.fileName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.documentType == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(document.filePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
              ),
            
            if (document.documentType == 'pdf')
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentOrange),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: AppColors.accentOrange),
                    SizedBox(height: 16),
                    Text('Document PDF', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            const Text(
              'Texte extrait par l\'IA Locale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                document.extractedText.isEmpty 
                    ? 'Aucun texte n\'a pu être extrait. L\'image est-elle floue ?'
                    : document.extractedText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}