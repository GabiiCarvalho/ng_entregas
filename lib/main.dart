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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 200,
              decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: Color(0xFFF97316),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'NG Entregas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                         ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Conteúdo

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        Children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Insira seu número de telefone',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enviaremos um código de 6 dígitos por SMS para autenticação',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Campo de telefone
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Color.grey,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '+55',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 20,
                                      ),
                                      hintText: '(00) 00000-0000',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                    onChanged: (value) {
                                      final formatted = _formatPhone(value);
                                      if (formatted != value) {
                                        _phoneController.value = 
                                            _phoneController.value.copyWith(
                                            text: formatted,
                                            selection: TextSelection.collapsed(
                                              offset: formatted.length),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botão continuar
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_phoneController.text.isNotEmpty) {
                                  widget.onPhoneSubmitted(_phoneController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divisor

                        Row(
                          children: [
                            Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // Botão Google
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                              _phoneController.text = '(47) 99641-2384';
                              widget.onPhoneSubmitted(_phoneController.text);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(color: Colors.grey.shade300,
                                width: 2
                              ),
                          ),
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                      'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                                      ),
                                   ),
                                 ),
                               ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continuar com o Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Termos e condições
                      const Text(
                        'Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // =============== SMS VERIFY SCREEN ===============
  class SMSVerifyScreen extends StatefulWidget {
    final String phoneNumber;
    final Function(String) onCodeVerified;

    const SMSVerifyScreen({
      super.key,
      required this.phone
      required this.onCodeVerified,
    });

    @override
    State<SMSVerifyScreenState> createState() => _SMSVerifyScreenState();
  }

  class _SMSVerifyScreenState extends State<SMSVerifyScreen> {
    final List<TextEditingController> _digitControllers = List.generate(6, (_) => TextEditingController());
    final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
    String _code = '';

    @override
    void initState() {
      super.initState();
      for (int i = 0; i < 6; i++) {
        _digitControllers[i].addListener(() {
          if (_digitControllers[i].text.isNotEmpty && i < 5) {
            _focusNodes[i + 1].requestFocus();
          }
          _updateCode();
        });
      }
    }

    void _updateCode() {
      String newCode = '';
      for (var controller in _digitControllers) {
        newCode += controller.text;
      }
      setState(() => _code = newCode);
      if (newCode.length == 6) {
        widget.onCodeVerified(newCode);
      }
    }

    String _formatPhone(String value) {
      String Cleaned = phone.replaceAll(RegExp('r[ˆ\d]'), '');
      if (cleaned.length == 11) {
        return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }