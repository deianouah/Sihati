import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
          _extractedText = '';
        });
        
        final text = await OcrService.recognizeText(pickedFile.path);
        
        setState(() {
          _extractedText = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _extractedText = 'خطأ في التقاط الصورة: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قراءة وصفة الطبيب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('الكاميرا'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('المعرض'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_imageFile != null) ...[
              const Text(
                'الصورة المحددة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_extractedText.isNotEmpty) ...[
              const Text(
                'النص المستخرج:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _extractedText,
                  style: const TextStyle(fontSize: 16),
                  textDirection: TextDirection.rtl, // Supports Arabic, English, French based on content naturally
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ملاحظة: تأكد من الأوقات والوجبات، ثم قم بإضافتها يدوياً أو سيتم تطوير ميزة الفهم التلقائي لاحقاً.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ] else if (_imageFile == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text(
                    'اختر صورة لاستخراج النص (يدعم العربية، الإنجليزية، والفرنسية)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
