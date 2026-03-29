import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddQuestionCountScreen extends StatefulWidget {
  final String examType;
  final String subject;
  
  const AddQuestionCountScreen({
    super.key,
    required this.examType,
    required this.subject,
  });

  @override
  State<AddQuestionCountScreen> createState() => _AddQuestionCountScreenState();
}

class _AddQuestionCountScreenState extends State<AddQuestionCountScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _questionCountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _questionCountController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestionCount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final questionCount = int.tryParse(_questionCountController.text);
    if (questionCount == null || questionCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir sayı girin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.saveSubjectQuestionCount(
      examType: widget.examType,
      subject: widget.subject,
      questionCount: questionCount,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        Navigator.pop(context, true); // Başarılı, geri dön
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Kayıt başarısız')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} - Soru Sayısı Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              Text(
                'Kaç soru çözdün?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.examType} - ${widget.subject}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              TextFormField(
                controller: _questionCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Soru Sayısı',
                  hintText: 'Örn: 50',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Soru sayısı gerekli';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _isLoading ? null : _saveQuestionCount,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

