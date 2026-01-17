import 'package:flutter/material.dart';
import 'package:flutter/services.dart;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NG Entregas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0XFFF9FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.white,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: true,
        ),
        fontFamily: 'Inter',
      ),
      home: const AppNavigatior(),
    );
      
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'splash';
  String _authStep = 'phone';
  String _phoneNumber = '';
  String _smsCode = '';
  
  void _goToAuth() {
    setState(() {
      _currentScreen = 'auth';
      _authStep = 'phone';
    });
  }

  void _handlePhoneSubmitted(String phone) {
    setState(() {
      _phoneNumber = phone;
      _authStep = 'sms';
    });
  }

  void _handleSMSVerified(String code) {
    setState(() {
      _smsCode = code;
      if (code == '123456')
      _currentScreen = 'main';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScreen == 'splash')
      return SplashScreen(onComplete: _goToAuth);
    }

    if (_currentScreen == 'auth') {
      if(_authStep == 'phone') {
        return PhoneAuthScreen(onPhoneSubmitted: _handlePhoneSubmitted);
        }
        
        if (_authStep == 'sms') {
          return SMSVerifyScreen(
            phoneNumber: _phoneNumber,
            onCodeVerified: _handleSMSVerified,
            )
          }
      }

      return MainScreen(
        userPhone: _phoneNumber,
        onLogout: () {
          setState(() {
            _currentScreen = 'auth';
            _authStep = 'phone';
            _phoneNumber = '';
            _smsCode = '';
          });
        },
      );
    }
  }

  // =============== SPLASH SCREEN ===============
  class SplashScreen extends StatelessWidget {
    final VoidCallback onComplete;

    const SplashScreen({super.key, required this.onComplete});

    @override
    Widget build(BuildContext) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF97316),
              Color(0xFFEA580C),
              Color(0xFFDC2626),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAligment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping,
                  size: 60,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'NG',
                style: TextSTyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Color.white,
                ),
              ),
              const Text(
                'Entregas',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.white,
                ),
              ),
              const SizedBox (height: 48),
              const Text(
                'Seu pedido, nossa missão',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.white,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Começar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }
  }

  // =============== PHONE AUTH SCREEN ===============
  class PhoneAuthScreen extends StatefulWidget {
    final Function(String) onPhoneSubmitted;

    const PhoneAuthScreen({super.key, required this.onPhoneSubmitted});

    @override
    State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
  }

  class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
    final _phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    String _formatPhone(String value) {
      value = value.replaceAll(RegExp(r'[ˆ\d]'), '');
      if (value.length <= 11) {
        if (value.length > 2) {
          value = '(${value.substring(0, 2)}) ${value.substring(2)}';
      }
      if (value.length > 10) {
        value = '${value.substring(0, 10)}-${value.substring(10)}';
      }
    }
    return value;
  }