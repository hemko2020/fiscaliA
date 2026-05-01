import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/document_provider.dart';
import 'document_detail_screen.dart';

class DocumentScannerScreen extends ConsumerStatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  ConsumerState<DocumentScannerScreen> createState() =>
      _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends ConsumerState<DocumentScannerScreen> {
  bool _isProcessing = false;

  Future<void> _handlePdfUpload() async {
    setState(() => _isProcessing = true);
    await ref.read(documentProvider.notifier).addPdf();
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _handleCameraScan() async {
    setState(() => _isProcessing = true);
    await ref.read(documentProvider.notifier).addPhoto();
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showAddDocumentBottomSheet() {
    final docCount = ref.read(documentProvider).length;
    if (docCount >= 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 14 documents atteinte.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajouter un document fiscal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text('Prendre une photo'),
                  subtitle: const Text('Fiche de paie, reçu, etc.'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleCameraScan();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accentOrange,
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: const Text('Importer un PDF'),
                  subtitle: const Text('Depuis vos fichiers'),
                  onTap: () {
                    Navigator.pop(context);
                    _handlePdfUpload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse Documentaire IA'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          documents.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(documents),

          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyse en cours...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Extraction des données fiscales (OCR local)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _showAddDocumentBottomSheet,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('${documents.length}/14 Docs'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text(
              'Aucun document',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajoutez vos fiches de paie ou reçus fiscaux. Notre IA locale analysera le texte pour trouver des déductions sans que vos données ne quittent votre téléphone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(List documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isPdf = doc.documentType == 'pdf';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isPdf
                  ? AppColors.accentOrange.withValues(alpha: 0.1)
                  : AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: isPdf ? AppColors.accentOrange : AppColors.primaryBlue,
              ),
            ),
            title: Text(
              doc.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy à HH:mm').format(doc.dateAdded),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    ref.read(documentProvider.notifier).deleteDocument(doc.id);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentDetailScreen(document: doc),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
