import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class StudentTypeSelectionScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const StudentTypeSelectionScreen({super.key, required this.onComplete});

  @override
  State<StudentTypeSelectionScreen> createState() => _StudentTypeSelectionScreenState();
}

class _StudentTypeSelectionScreenState extends State<StudentTypeSelectionScreen> {
  final _apiService = ApiService();
  String? _selectedType;
  bool _isLoading = false;
  bool _isCheckingToken = true;

  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
  }

  Future<void> _checkTokenAndRedirect() async {
    final token = await _apiService.getToken();
    if (token == null) {
      // Token yoksa direkt login ekranına yönlendir
      if (mounted) {
        widget.onComplete(); // Bu main.dart'ta login ekranına dönecek
      }
      return;
    }

    // Token geçerliliğini kontrol et
    try {
      final result = await _apiService.get('verify_token.php');
      if (result['success'] != true) {
        // Token geçersiz veya süresi dolmuş
        await _apiService.deleteToken();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum süresi dolmuş, lütfen tekrar giriş yapın'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onComplete(); // Login ekranına yönlendir
        }
        return;
      }
    } catch (e) {
      // Hata durumunda da login ekranına yönlendir
      await _apiService.deleteToken();
      if (mounted) {
        widget.onComplete();
      }
      return;
    }

    setState(() {
      _isCheckingToken = false;
    });
  }

  Future<void> _saveStudentType() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir seçenek seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    final result = await _apiService.setStudentType(_selectedType!);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Öğrenci tipini kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_type', _selectedType!);
        
        widget.onComplete();
      } else {
        // Token geçersiz veya süresi dolmuş
        if (result['message']?.contains('token') == true || 
            result['message']?.contains('Token') == true ||
            result['message']?.contains('Geçersiz') == true) {
          await _apiService.deleteToken();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum süresi dolmuş, lütfen tekrar giriş yapın'),
              backgroundColor: Colors.orange,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onComplete(); // Login ekranına yönlendir
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Kayıt başarısız')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Token kontrolü yapılıyorsa loading göster
    if (_isCheckingToken) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Kontrol ediliyor...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

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
                
                // Icon
                Icon(
                  Icons.school,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Hangi Sınava Hazırlanıyorsun?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulamayı senin için özelleştirelim',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // LGS Option
                _StudentTypeCard(
                  title: 'LGS',
                  subtitle: 'Liselere Geçiş Sınavı',
                  icon: Icons.school,
                  isSelected: _selectedType == 'LGS',
                  onTap: () {
                    setState(() {
                      _selectedType = 'LGS';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // YKS Option
                _StudentTypeCard(
                  title: 'YKS',
                  subtitle: 'TYT, AYT ve YDS sınavları',
                  icon: Icons.menu_book,
                  isSelected: _selectedType == 'YKS',
                  onTap: () {
                    setState(() {
                      _selectedType = 'YKS';
                    });
                  },
                ),
                const SizedBox(height: 48),

                // Continue Button
                FilledButton(
                  onPressed: _isLoading ? null : _saveStudentType,
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
                          'Devam Et',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StudentTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? colorScheme.onPrimary 
                      : colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? colorScheme.onPrimaryContainer 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

