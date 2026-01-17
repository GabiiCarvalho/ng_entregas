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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            //Header
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFF97316),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack (
                children: [
                  // Botão voltar
                  Positioned(
                    left: 16,
                    top: 16,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon (
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAligment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.smartphone,
                            size: 40,
                            color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verificação',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Digite o código de 6 dígitos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um SMS para\n${_formatPhone(widget.phoneNumber)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Campos de código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _digitControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _code.length > index ? const Color(0xFFF97316) : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),

                // Botão verificar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _code.length == 6
                    ? () => widget.onCodeVerified(_code)
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Verificar código',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Mensagem de demonstração
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade100,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Para fins de demonstração, use o código 123456 para autenticação.',
                        style: TextStyle(
                          color: Colors(0xFF1E40AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
  // =============== MAIN SCREEN ===============
  class MainScreen extends StatefulWidget {
    final String userPhone;
    final VoidCallback onLogout

    const MainScreen({
      super.key,
      required this.userPhone,
      required this.onLogout,
    });

    @override
    State<MainScreen> createState() => _MainScreenState();
  }

  class _MainScreenState extends State<MainScreen> {
    with SingleTickerProviderStateMixin {
      late TabController _tabController;
      int _selectedIndex = 0;
      bool _showDestinationForm = false;
      String _selectedVehicle = '';
      String _destinationAddress = '';

      final List<Map<String, dynamic>> _recentAddress = [
        {
      'address': 'Rua Victor. P Correia, 184 - apto 1',
      'name': 'Veronica',
      'phone': '47996674426',
      'type': 'home',
    },
    {
      'address': 'Posto Portal Camboriú, Avenida Santa Catarina',
      'name': 'Trabalho',
      'phone': '',
      'type': 'work',
    },
    {
      'address': 'Rua Tereza Evangelista Gonçalves, 273',
      'name': 'Favorito',
      'phone': '',
      'type': 'favorite',
    },
  ];
    
     @override
     void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this);
     }

     @override
     void dispose() {
      _tabController.dispose();
      super.dispose();
     }

     void _selectAddress(Map<String, dynamic> address) {
      setState(() {
        _destinationAddress = address['address'];
        _showDestinationForm = false;
      })
     }

     @override
     Widget build(BuildContext context) {
      if (_showDestinationForm) {
        return _buildDestinationScreen();
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF111827)),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              Icon: const Icon(Icons.person_outline, color: Color(0zFF111827)),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            //Header personalizado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Olá, Gabriele!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Text(
                    'VOCÊ PRECISA,',
                    style: TextStyle(
                      fontSize:20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Text(
                    'NG Entrega',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFF97316),
                labelColor: const Color(0xFFF97316),
                unselectedLabelColor: Color(0xFF6B7280),
                tabs: const [
                  Tab(text: 'Enviar'),
                  Tab(text: 'Receber'),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Enviar
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Remetente
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAligment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enviar de',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Alterar',
                                      style: TextStyle(
                                        color: Color(0xFFF97316),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFF97316),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Rua Olga Bernardes Amorim, 101',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Gabriele - (47) 99641-2384',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Destinatário
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showDestinationForm = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icon.circle,
                                  color: Color(0xFFF97316),
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entregar para',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _destinationAddress.isNotEmpty
                                      ? _destinationAddress
                                      : 'Selecionar endereço de entrega',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _destinationAddress.isNotEmpty
                                        ? Color.black
                                        : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_destinationAddress.isNotEmpty) ...[
                        const SizedBox(height: 16),

                        // Detalhes da entrega
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Endereços
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFF97316),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Rua Olga Bernardes Amorim, 101',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Gabriele - (47) 99641-2384',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Linha divisória
                              Container(
                                height: 20,
                                width: 1,
                                margin: const EdgeInsets.only(left: 9),
                                color: Colors.grey.shade300,
                              ),

                              const SizedBox(height: 16),

                              // Destino
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Destinatário',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Botão detalhes do item

                            ],
                          ),
                        ),
                      ]