import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/tax_document_model.dart';

final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) {
  return DocumentScannerService();
});

class DocumentScannerService {
  static const MethodChannel _ocrChannel = MethodChannel('fr.fiscalia/ocr');
  final ImagePicker _imagePicker = ImagePicker();
  final _uuid = const Uuid();

  Future<TaxDocumentModel?> pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final text = await _extractTextFromPdf(file);

      final savedFile = await _saveFileLocally(file, result.files.single.name);

      return TaxDocumentModel(
        id: _uuid.v4(),
        fileName: result.files.single.name,
        filePath: savedFile.path,
        dateAdded: DateTime.now(),
        documentType: 'pdf',
        extractedText: text,
      );
    }
    return null;
  }

  Future<TaxDocumentModel?> takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // High quality for better OCR
    );

    if (image != null) {
      final file = File(image.path);
      final text = await _extractTextFromImage(file);

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await _saveFileLocally(file, fileName);

      return TaxDocumentModel(
        id: _uuid.v4(),
        fileName: fileName,
        filePath: savedFile.path,
        dateAdded: DateTime.now(),
        documentType: 'image',
        extractedText: text,
      );
    }
    return null;
  }

  Future<String> _extractTextFromPdf(File file) async {
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: file.readAsBytesSync(),
      );
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text.trim();
    } catch (e) {
      return "Erreur d'extraction du texte PDF: $e";
    }
  }

  Future<String> _extractTextFromImage(File file) async {
    try {
      if (Platform.isIOS) {
        return await _extractTextFromImageOnIos(file);
      }

      return await _extractTextFromImageWithMlKit(file);
    } catch (e) {
      return "Erreur d'extraction du texte (OCR): $e";
    }
  }

  Future<String> _extractTextFromImageOnIos(File file) async {
    final recognizedText = await _ocrChannel.invokeMethod<String>(
      'recognizeText',
      {'filePath': file.path},
    );
    return recognizedText?.trim() ?? '';
  }

  Future<String> _extractTextFromImageWithMlKit(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      textRecognizer.close();
      return recognizedText.text.trim();
    } catch (e) {
      return "Erreur d'extraction du texte (OCR): $e";
    }
  }

  Future<File> _saveFileLocally(File sourceFile, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${directory.path}/tax_documents');
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    final destinationFile = File('${docsDir.path}/$fileName');
    return await sourceFile.copy(destinationFile.path);
  }
}
