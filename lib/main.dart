import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/student_type_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;
  bool _needsStudentType = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final studentType = prefs.getString('student_type');
    
    print('🔍 _checkAuthStatus - token: ${token != null ? "var" : "yok"}');
    print('🔍 _checkAuthStatus - studentType: $studentType');
    
    if (token != null) {
      // Öğrenci tipi null veya boş string ise seçim ekranını göster
      final needsType = studentType == null || studentType.isEmpty;
      print('🔍 _checkAuthStatus - needsStudentType: $needsType');
      setState(() {
        _isAuthenticated = true;
        _needsStudentType = needsType;
      });
    }
  }

  void _handleLogin() async {
    // Login sonrası token'ın kaydedilmesini bekle
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final studentType = prefs.getString('student_type');
    
    print('🔍 _handleLogin - token: ${token != null ? "var" : "yok"}');
    print('🔍 _handleLogin - studentType: $studentType');
    
    // Token varsa kontrol et
    if (token != null) {
      // Öğrenci tipi null veya boş string ise seçim ekranını göster
      final needsType = studentType == null || studentType.isEmpty;
      print('🔍 _handleLogin - needsStudentType: $needsType');
      setState(() {
        _isAuthenticated = true;
        _needsStudentType = needsType;
      });
    } else {
      // Token yoksa login ekranında kal
      print('🔍 _handleLogin - Token yok, login ekranında kal');
      setState(() {
        _isAuthenticated = false;
        _needsStudentType = false;
      });
    }
  }

  void _handleRegister() async {
    // Register sonrası login ekranına dönüyor, bu yüzden burada bir şey yapmıyoruzz
    // Kullanıcı login yaptığında _handleLogin çağrılacak
  }

  Future<void> _handleStudentTypeSelected() async {
    // Öğrenci tipi seçildi veya token geçersiz olduğu için kontrol et
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final studentType = prefs.getString('student_type');
    
    if (token == null || studentType == null) {
      // Token yoksa veya öğrenci tipi seçilmemişse login ekranına dön
      setState(() {
        _isAuthenticated = false;
        _needsStudentType = false;
      });
    } else {
      // Her şey tamam, ana ekrana geç
      setState(() {
        _isAuthenticated = true;
        _needsStudentType = false;
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _needsStudentType = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;
    
    if (!_isAuthenticated) {
      homeWidget = LoginScreen(onLogin: _handleLogin);
    } else if (_needsStudentType) {
      homeWidget = StudentTypeSelectionScreen(onComplete: _handleStudentTypeSelected);
    } else {
      homeWidget = MainNavigation(onLogout: _handleLogout);
    }

    return MaterialApp(
      title: 'Çalış Benimle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeWidget,
      onGenerateRoute: (settings) {
        if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (context) => RegisterScreen(onRegister: _handleRegister),
          );
        }
        return null;
      },
    );
  }
}
