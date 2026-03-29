import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final result = await _apiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      if (result['success']) {
        // Kullanıcı adını kaydet
        final prefs = await SharedPreferences.getInstance();
        if (result['user'] != null && result['user']['name'] != null) {
          await prefs.setString('user_name', result['user']['name']);
        }
        
        // User ID'yi kaydet (student_type seçiminde kullanılacak)
        if (result['user'] != null && result['user']['id'] != null) {
          await prefs.setInt('user_id', result['user']['id']);
        }
        
        // Öğrenci tipini kontrol et ve kaydet
        final needsStudentType = result['needs_student_type'] == true;
        final studentTypeFromBackend = result['user']?['student_type'];
        
        print('🔍 Login - needs_student_type: $needsStudentType');
        print('🔍 Login - student_type from backend: $studentTypeFromBackend');
        
        if (needsStudentType || studentTypeFromBackend == null || studentTypeFromBackend.toString().isEmpty) {
          // Öğrenci tipi seçilmemişse SharedPreferences'tan sil
          await prefs.remove('student_type');
          print('🔍 Login - student_type SharedPreferences\'tan silindi');
        } else {
          // Öğrenci tipi varsa kaydet
          await prefs.setString('student_type', studentTypeFromBackend.toString());
          print('🔍 Login - student_type kaydedildi: $studentTypeFromBackend');
        }
        
        // Token'ı kaydet
        if (result['token'] != null) {
          await _apiService.saveToken(result['token']);
        }
        
        widget.onLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Giriş başarısız')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Çalış Benimle',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'YKS Çalışma Takip Uygulaması',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                  ),
                ),
                const SizedBox(height: 24),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                FilledButton(
                  onPressed: _isLoading ? null : _login,
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
                      : const Text(
                          'Giriş Yap',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Register Button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

