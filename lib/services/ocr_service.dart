import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  // Default recognizer supports Latin scripts (English, French, etc.)
  // Arabic is handled by the on-device model automatically when detected.
  static final TextRecognizer _latinRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText result =
          await _latinRecognizer.processImage(inputImage);
      return result.text.trim().isEmpty
          ? 'لم يتم التعرف على أي نص. حاول التقاط صورة أوضح.'
          : result.text;
    } catch (e) {
      return 'حدث خطأ أثناء قراءة الصورة: $e';
    }
  }

  static void dispose() {
    _latinRecognizer.close();
  }
}

