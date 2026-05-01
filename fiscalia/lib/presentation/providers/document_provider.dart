import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tax_document_model.dart';
import 'document_scanner_service.dart';

final documentProvider =
    StateNotifierProvider<DocumentNotifier, List<TaxDocumentModel>>((ref) {
      return DocumentNotifier(ref);
    });

class DocumentNotifier extends StateNotifier<List<TaxDocumentModel>> {
  final Ref _ref;
  final _box = Hive.box<TaxDocumentModel>('taxDocuments');

  DocumentNotifier(this._ref) : super([]) {
    _loadDocuments();
  }

  void _loadDocuments() {
    final docs = _box.values.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); // Newest first
    state = docs;
  }

  Future<void> addPdf() async {
    if (state.length >= 14) return; // Epic limit

    final service = _ref.read(documentScannerServiceProvider);
    final doc = await service.pickPdf();

    if (doc != null) {
      await _box.put(doc.id, doc);
      state = [doc, ...state];
    }
  }

  Future<void> addPhoto() async {
    if (state.length >= 14) return;

    final service = _ref.read(documentScannerServiceProvider);
    final doc = await service.takePhoto();

    if (doc != null) {
      await _box.put(doc.id, doc);
      state = [doc, ...state];
    }
  }

  Future<void> deleteDocument(String id) async {
    await _box.delete(id);
    state = state.where((doc) => doc.id != id).toList();
  }
}
