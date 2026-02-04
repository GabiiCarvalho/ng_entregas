import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

// Importações das telas de autenticação
import 'authentication/login_screen.dart';
import 'authentication/signup_screen.dart';

// Importações globais
import 'global/global_var.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  // Verificar se usuário já está logado
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // Carregar dados do usuário se já estiver logado
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        var userData = snap.snapshot.value as Map<dynamic, dynamic>;
        userName = userData["name"]?.toString() ?? "";
        userPhone = userData["phone"]?.toString() ?? "";
        userID = currentUser.uid;
      }
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NG EXPRESS',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[400],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: DeliveryApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DeliveryApp extends StatefulWidget {
  const DeliveryApp({super.key});

  @override
  _DeliveryAppState createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp>
    with SingleTickerProviderStateMixin {
  String _currentScreen = 'splash';
  bool _isLogin = true;
  String _activeTab = 'enviar';
  bool _showDestinationForm = false;
  bool _showSenderForm = false;
  bool _showHistory = false;
  bool _showWallet = false;
  bool _showPixDeposit = false;
  bool _showCardForm = false;
  bool _showVehicleSelection = false;
  String _cardType = '';
  bool _showPayment = false;
  String _paymentMethod = 'cash';
  String _selectedVehicle = 'moto';
  bool _pixCopied = false;
  bool _showProfile = false;
  bool _showItemDetails = false;
  bool _deliveryAddressSet = false;
  bool _showDeliveryDetails = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Variáveis para o método de pagamento
  String _selectedPaymentMethod = 'cash';

  // Mapeamentos para métodos de pagamento
  final Map<String, String> _paymentMethodDisplay = {
    'cash': 'Dinheiro',
    'card': 'Cartão',
    'pix': 'PIX',
    'wallet': 'Carteira Digital',
  };

  final Map<String, IconData> _paymentMethodIcons = {
    'cash': Icons.payments,
    'card': Icons.credit_card,
    'pix': Icons.pix,
    'wallet': Icons.account_balance_wallet,
  };

  final Map<String, Color> _paymentMethodColors = {
    'cash': Colors.green,
    'card': Colors.purple,
    'pix': Colors.blue,
    'wallet': Colors.orange,
  };

  final Map<String, String> _paymentMethodBalances = {
    'cash': 'Saldo disponível: R\$0,36',
    'card': 'Cartão salvo',
    'pix': 'PIX disponível',
    'wallet': 'Saldo: R\$125,00',
  };

  // Mapeamento de ícones para tipos de itens
  final Map<String, IconData> _itemIcons = {
    'Itens pessoais': Icons.person,
    'Alimentação': Icons.fastfood,
    'Vestuário': Icons.checkroom,
    'Eletrônicos': Icons.devices,
    'Documentos': Icons.description,
    'Chaves': Icons.key,
    'Medicamentos': Icons.medical_services,
    'Outros': Icons.more_horiz,
  };

  String _selectedItemType = 'Itens pessoais';
  String _itemValue = '';
  String _deliveryNotes = '';

  // Controladores para formulários
  final TextEditingController _destinationAddressController =
      TextEditingController();
  final TextEditingController _destinationDetailsController =
      TextEditingController();
  final TextEditingController _destinationNameController =
      TextEditingController();
  final TextEditingController _destinationPhoneController =
      TextEditingController();

  final TextEditingController _senderAddressController =
      TextEditingController();
  final TextEditingController _senderDetailsController =
      TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Verificar se usuário já está logado ao iniciar
    _checkIfUserIsLoggedIn();
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Usuário já está logado, ir direto para tela principal
      await Future.delayed(Duration(milliseconds: 1500)); // Tempo do splash
      setState(() {
        _currentScreen = 'main';
      });
    } else {
      // Usuário não está logado, mostrar splash e depois auth
      await Future.delayed(Duration(milliseconds: 2000));
      setState(() {
        _currentScreen = 'auth';
      });
    }
  }

  void _switchTabs(String newTab) {
    if (newTab != _activeTab) {
      _animationController.forward(from: 0.0).then((_) {
        setState(() {
          _activeTab = newTab;
        });
        _animationController.reverse();
      });
    }
  }

  void _copyPixCode() async {
    const pixCode =
        '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540525NG EXPRESS LTDA6009SAO PAULO62070503***63041D3D';
    await Clipboard.setData(ClipboardData(text: pixCode));
    setState(() {
      _pixCopied = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _pixCopied = false;
      });
    });
  }

  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentScreen = 'auth';
      _isLogin = true;
      _showProfile = false;
      _deliveryAddressSet = false;

      // Limpar dados do usuário
      userName = '';
      userPhone = '';
      userID = '';

      // Limpar formulários
      _destinationAddressController.clear();
      _destinationDetailsController.clear();
      _destinationNameController.clear();
      _destinationPhoneController.clear();
      _senderAddressController.clear();
      _senderDetailsController.clear();
      _senderNameController.clear();
      _senderPhoneController.clear();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _destinationAddressController.dispose();
    _destinationDetailsController.dispose();
    _destinationNameController.dispose();
    _destinationPhoneController.dispose();
    _senderAddressController.dispose();
    _senderDetailsController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Verificar se usuário está logado
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null &&
        _currentScreen != 'splash' &&
        _currentScreen != 'auth') {
      // Usuário deslogado, redirecionar para auth
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentScreen = 'auth';
          _isLogin = true;
        });
      });
    }

    // Sistema de navegação baseado no estado atual
    switch (_currentScreen) {
      case 'splash':
        return _buildSplashScreen();
      case 'auth':
        return _buildAuthScreen();
      case 'main':
        return _buildMainScreen();
    }

    // Telas modais (sobrepostas)
    if (_showProfile) {
      return _buildProfileScreen();
    }

    if (_showItemDetails) {
      return _buildItemDetailsScreen();
    }

    if (_showVehicleSelection) {
      return _buildVehicleSelectionScreen();
    }

    if (_showDestinationForm) {
      return _buildDestinationFormScreen();
    }

    if (_showSenderForm) {
      return _buildSenderFormScreen();
    }

    if (_showPayment) {
      return _buildPaymentScreen();
    }

    if (_showPixDeposit) {
      return _buildPixDepositScreen();
    }

    if (_showCardForm) {
      return _buildCardFormScreen();
    }

    if (_showHistory) {
      return _buildHistoryScreen();
    }

    if (_showWallet) {
      return _buildWalletScreen();
    }

    if (_showDeliveryDetails) {
      return _buildDeliveryDetailsScreen();
    }

    return _buildMainScreen(); // Fallback
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[400]!,
              Colors.orange[500]!,
              Colors.deepOrange[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.jpeg',
                    width: 125,
                    height: 125,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_shipping,
                        size: 60,
                        color: Colors.orange[400],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'NG',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'EXPRESS',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Seu pedido, nossa missão',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 60),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.orange[400],
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: Colors.orange[400],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'NG EXPRESS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLogin
                  ? LoginScreen() // Tela de login existente
                  : SignUpScreen(), // Tela de cadastro
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    // Obter dados do usuário logado
    String displayName = userName.isNotEmpty ? userName : 'Usuário';
    String displayInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';
    String displayPhone = userPhone.isNotEmpty ? userPhone : '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header com informações do usuário
            Container(
              width: double.infinity,
              color: Colors.orange[400],
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showProfile = true;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red[400]!, Colors.pink[400]!],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          displayInitial,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $displayName!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (displayPhone.isNotEmpty)
                          Text(
                            displayPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
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
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 40, bottom: 32),
                      child: Column(
                        children: [
                          Text(
                            'VOCÊ PRECISA,',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'NG EXPRESS Entrega',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          // BOTÕES DE SELEÇÃO ENVIAR/RECEBER
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _switchTabs('enviar'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Enviar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _activeTab == 'enviar'
                                                ? Colors.black
                                                : Colors.grey[400],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        if (_activeTab == 'enviar')
                                          Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[400],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(2),
                                                topRight: Radius.circular(2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _switchTabs('receber'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Receber',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _activeTab == 'receber'
                                                ? Colors.black
                                                : Colors.grey[400],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        if (_activeTab == 'receber')
                                          Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[400],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(2),
                                                topRight: Radius.circular(2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ÁREA DOS INPUTS COM ANIMAÇÃO
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0.0, 0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: _activeTab == 'enviar'
                                ? _buildSendContent()
                                : _buildReceiveContent(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botão Histórico
            GestureDetector(
              onTap: () {
                setState(() {
                  _showHistory = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 24, color: Colors.grey[400]),
                    SizedBox(height: 4),
                    Text(
                      'Histórico',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),

            // Botão Central (Pesquisar)
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: FloatingActionButton(
                onPressed: () {
                  // Abrir busca de entregas
                },
                backgroundColor: Colors.orange[400],
                elevation: 4,
                child: Icon(Icons.search, size: 28, color: Colors.white),
              ),
            ),

            // Botão Carteira
            GestureDetector(
              onTap: () {
                setState(() {
                  _showWallet = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments, size: 24, color: Colors.grey[400]),
                    SizedBox(height: 4),
                    Text(
                      'Carteira',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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

  Widget _buildSendContent() {
    return SingleChildScrollView(
      key: ValueKey('enviar'),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Endereço do remetente (usuário logado)
          GestureDetector(
            onTap: () {
              setState(() {
                _showSenderForm = true;
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange[400],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Seu nome',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          userPhone.isNotEmpty ? userPhone : 'Seu telefone',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Endereço de destino
          GestureDetector(
            onTap: () {
              setState(() {
                _showDestinationForm = true;
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange[400]!, width: 2),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Entregar para',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Botão de continuar
          ElevatedButton(
            onPressed: _deliveryAddressSet
                ? () {
                    setState(() {
                      _showDeliveryDetails = true;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _deliveryAddressSet
                  ? Colors.orange[400]
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              _deliveryAddressSet
                  ? 'Continuar'
                  : 'Selecione o endereço de entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveContent() {
    return SingleChildScrollView(
      key: ValueKey('receber'),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Endereço do remetente
          GestureDetector(
            onTap: () {
              setState(() {
                _showSenderForm = true;
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange[400],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Enviar de',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Endereço do destinatário (usuário logado)
          GestureDetector(
            onTap: () {
              setState(() {
                _showDestinationForm = true;
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange[400]!, width: 2),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Seu nome',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          userPhone.isNotEmpty ? userPhone : 'Seu telefone',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Botão de continuar
          ElevatedButton(
            onPressed: _deliveryAddressSet
                ? () {
                    setState(() {
                      _showDeliveryDetails = true;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _deliveryAddressSet
                  ? Colors.orange[400]
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              _deliveryAddressSet
                  ? 'Continuar'
                  : 'Selecione o endereço de entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    String displayName = userName.isNotEmpty ? userName : 'Usuário';
    String displayInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showProfile = false;
            });
          },
        ),
        title: Text('Meu Perfil'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header do perfil
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red[400]!, Colors.pink[400]!],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          displayInitial,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (userEmail.isNotEmpty)
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          SizedBox(height: 4),
                          if (userPhone.isNotEmpty)
                            Text(
                              userPhone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Editar perfil
                      },
                      icon: Icon(Icons.edit, color: Colors.orange[400]),
                    ),
                  ],
                ),
              ),

              // Seções do perfil
              _buildProfileSection(
                title: 'Conta',
                items: [
                  _buildProfileItem(
                    title: 'Minhas informações',
                    icon: Icons.person,
                    iconColor: Colors.blue[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Endereços salvos',
                    icon: Icons.location_on,
                    iconColor: Colors.green[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Formas de pagamento',
                    icon: Icons.credit_card,
                    iconColor: Colors.purple[600]!,
                  ),
                ],
              ),

              _buildProfileSection(
                title: 'Ajuda',
                items: [
                  _buildProfileItem(
                    title: 'Central de ajuda',
                    icon: Icons.help,
                    iconColor: Colors.blue[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Central de segurança',
                    icon: Icons.security,
                    iconColor: Colors.green[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Configurações',
                    icon: Icons.settings,
                    iconColor: Colors.grey[600]!,
                  ),
                ],
              ),

              _buildProfileSection(
                title: 'Convide',
                items: [
                  _buildProfileItem(
                    title: 'Convide Amigos',
                    icon: Icons.group_add,
                    iconColor: Colors.purple[600]!,
                    onTap: () {
                      // Compartilhar código de indicação
                    },
                  ),
                ],
              ),

              _buildProfileSection(
                title: 'Oportunidades',
                items: [
                  _buildProfileItem(
                    title: 'Seja Motorista',
                    icon: Icons.directions_car,
                    iconColor: Colors.orange[600]!,
                    onTap: () {
                      // Abrir cadastro de motorista
                    },
                  ),
                ],
              ),

              // Botão de logout
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _logoutUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Sair da conta'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfileItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 20, color: iconColor)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showItemDetails = false;
            });
          },
        ),
        title: Text('Detalhes do item'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Tipo de item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _itemIcons.keys.map((item) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _itemIcons[item]!,
                          size: 16,
                          color: _selectedItemType == item
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(item),
                      ],
                    ),
                    selected: _selectedItemType == item,
                    onSelected: (selected) {
                      setState(() {
                        _selectedItemType = item;
                      });
                    },
                    selectedColor: Colors.orange[400],
                    labelStyle: TextStyle(
                      color: _selectedItemType == item
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              Text(
                'Valor do item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money, color: Colors.grey[400]),
                  hintText: 'Insira o valor do item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _itemValue = value;
                  });
                },
              ),
              SizedBox(height: 8),
              Text(
                'A NG EXPRESS não sugere envio de itens com valor superior a R\$500',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              Text(
                'Observações da entrega',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              TextField(
                maxLines: 4,
                maxLength: 100,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.note, color: Colors.grey[400]),
                  hintText: 'Adicione uma descrição ou observações',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _deliveryNotes = value;
                  });
                },
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_deliveryNotes.length}/100',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showItemDetails = false;
                    _showPayment = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelectionScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showVehicleSelection = false;
            });
          },
        ),
        title: Text('Selecione o veículo'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolha o tipo de veículo para sua entrega',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = 'moto';
                          _showVehicleSelection = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _selectedVehicle == 'moto'
                              ? Colors.orange[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedVehicle == 'moto'
                                ? Colors.orange[400]!
                                : Colors.grey[200]!,
                            width: _selectedVehicle == 'moto' ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.two_wheeler,
                              size: 80,
                              color: _selectedVehicle == 'moto'
                                  ? Colors.orange[600]
                                  : Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Moto',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _selectedVehicle == 'moto'
                                    ? Colors.orange[600]
                                    : Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mais rápido • Ideal para itens pequenos',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Entrega rápida',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.money_off,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Mais econômico',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = 'carro';
                          _showVehicleSelection = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _selectedVehicle == 'carro'
                              ? Colors.orange[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedVehicle == 'carro'
                                ? Colors.orange[400]!
                                : Colors.grey[200]!,
                            width: _selectedVehicle == 'carro' ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 80,
                              color: _selectedVehicle == 'carro'
                                  ? Colors.orange[600]
                                  : Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Carro',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _selectedVehicle == 'carro'
                                    ? Colors.orange[600]
                                    : Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mais espaço • Ideal para itens maiores',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Mais espaço',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.security,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Mais seguro',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_selectedVehicle.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedVehicle == 'moto'
                            ? Icons.two_wheeler
                            : Icons.directions_car,
                        color: Colors.orange[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Veículo selecionado: ${_selectedVehicle == 'moto' ? 'Moto' : 'Carro'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600],
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

  Widget _buildDestinationFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showDestinationForm = false;
            });
          },
        ),
        title: Text('Informações do destinatário'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _destinationAddressController,
                decoration: InputDecoration(
                  labelText: 'Endereço*',
                  hintText: 'Selecionar endereço de entrega',
                  suffixIcon: Icon(Icons.arrow_forward_ios),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                onTap: () {
                  // Implementar seleção de endereço
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _destinationDetailsController,
                decoration: InputDecoration(
                  labelText: 'Detalhes do endereço',
                  hintText: 'Ex.: bloco A, apartamento 201',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _destinationNameController,
                decoration: InputDecoration(
                  labelText: 'Nome para contato*',
                  hintText: 'Digite o nome do destinatário',
                  suffixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _destinationPhoneController,
                decoration: InputDecoration(
                  labelText: 'Número de telefone*',
                  hintText: 'Telefone do destinatário',
                  prefix: Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('🇧🇷'), SizedBox(width: 4), Text('+55')],
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_destinationAddressController.text.isNotEmpty &&
                      _destinationNameController.text.isNotEmpty &&
                      _destinationPhoneController.text.isNotEmpty) {
                    setState(() {
                      _deliveryAddressSet = true;
                      _showDestinationForm = false;
                      _showDeliveryDetails = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSenderFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showSenderForm = false;
            });
          },
        ),
        title: Text('Informações do remetente'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _senderAddressController,
                decoration: InputDecoration(
                  labelText: 'Endereço*',
                  hintText: 'Selecionar endereço de coleta',
                  suffixIcon: Icon(Icons.arrow_forward_ios),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                onTap: () {
                  // Implementar seleção de endereço
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _senderDetailsController,
                decoration: InputDecoration(
                  labelText: 'Detalhes do endereço',
                  hintText: 'Ex.: bloco A, apartamento 201',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _senderNameController,
                decoration: InputDecoration(
                  labelText: 'Nome para contato*',
                  hintText: 'Digite o nome do remetente',
                  suffixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _senderPhoneController,
                decoration: InputDecoration(
                  labelText: 'Número de telefone*',
                  hintText: 'Telefone do remetente',
                  prefix: Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('🇧🇷'), SizedBox(width: 4), Text('+55')],
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_senderAddressController.text.isNotEmpty &&
                      _senderNameController.text.isNotEmpty &&
                      _senderPhoneController.text.isNotEmpty) {
                    setState(() {
                      _showSenderForm = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showDeliveryDetails = false;
            });
          },
        ),
        title: Text('Detalhes da entrega'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Endereço de origem
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _senderAddressController.text.isNotEmpty
                          ? _senderAddressController.text
                          : 'Endereço do remetente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_senderNameController.text} · ${_senderPhoneController.text}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // Seta para baixo
              Center(
                child: Icon(
                  Icons.arrow_downward,
                  color: Colors.orange[400],
                  size: 24,
                ),
              ),

              SizedBox(height: 8),

              // Endereço de destino
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _destinationAddressController.text.isNotEmpty
                          ? _destinationAddressController.text
                          : 'Endereço do destinatário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_destinationNameController.text} · ${_destinationPhoneController.text}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Título dos detalhes do item
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inserir detalhes do item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDeliveryDetails = false;
                        _showItemDetails = true;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Adicionar',
                          style: TextStyle(color: Colors.orange[400]),
                        ),
                        Icon(Icons.add, color: Colors.orange[400], size: 16),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4),

              Text(
                'Adicionar uma observação na entrega',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              SizedBox(height: 16),

              Divider(),

              SizedBox(height: 16),

              // Opção Entrega Moto
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicle = 'moto';
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedVehicle == 'moto'
                          ? Colors.orange[400]!
                          : Colors.grey[200]!,
                      width: _selectedVehicle == 'moto' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.two_wheeler,
                                color: Colors.orange[600],
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Entrega Moto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'R\$5,20',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '21:37 · 8 min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.straighten,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '40×34×36cm · 10kg',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Opção Entrega Carro
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicle = 'carro';
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedVehicle == 'carro'
                          ? Colors.orange[400]!
                          : Colors.grey[200]!,
                      width: _selectedVehicle == 'carro' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Colors.orange[600],
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Entrega Carro',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'R\$9,20',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '21:35 · 5 min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.straighten,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '100×70×60cm · 30kg',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Seção Verificar com PIN
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verificar com PIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_box_outline_blank,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Usar código de coleta',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.check_box_outline_blank,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Usar código de entrega',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Termos de uso
              Text(
                'Ao solicitar uma entrega, você concorda com os Termos de Uso',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              Divider(),

              SizedBox(height: 16),

              // Seção de pagamento
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Linha do método de pagamento
                    GestureDetector(
                      onTap: () {
                        _showPaymentMethodSelection();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _paymentMethodIcons[_selectedPaymentMethod]!,
                                color:
                                    _paymentMethodColors[_selectedPaymentMethod]!,
                              ),
                              SizedBox(width: 12),
                              Text(
                                _paymentMethodDisplay[_selectedPaymentMethod]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _paymentMethodBalances[_selectedPaymentMethod]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[500],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Linha do total a pagar
                    Divider(),

                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a pagar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedVehicle == 'moto' ? 'R\$5,20' : 'R\$9,20',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Botão de solicitar entrega
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showDeliveryDetails = false;
                    _showPayment = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Solicitar entrega',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle para arrastar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Selecionar método de pagamento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Divider(),

              // Opção Dinheiro
              _buildPaymentMethodOption(
                title: 'Dinheiro',
                subtitle: 'Pagar na entrega',
                icon: Icons.payments,
                iconColor: Colors.green[600]!,
                methodKey: 'cash',
              ),

              // Opção Carteira Digital
              _buildPaymentMethodOption(
                title: 'Carteira Digital',
                subtitle: 'Saldo: R\$125,00',
                icon: Icons.account_balance_wallet,
                iconColor: Colors.orange[600]!,
                methodKey: 'wallet',
              ),

              // Opção PIX
              _buildPaymentMethodOption(
                title: 'PIX',
                subtitle: 'Pagamento instantâneo',
                icon: Icons.pix,
                iconColor: Colors.blue[600]!,
                methodKey: 'pix',
              ),

              // Opção Cartão
              _buildPaymentMethodOption(
                title: 'Cartão',
                subtitle: 'Crédito ou Débito',
                icon: Icons.credit_card,
                iconColor: Colors.purple[600]!,
                methodKey: 'card',
              ),

              SizedBox(height: 20),

              // Botão de cancelar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String methodKey,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = methodKey;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == methodKey
              ? Colors.orange[50]
              : Colors.white,
          border: _selectedPaymentMethod == methodKey
              ? Border(left: BorderSide(color: Colors.orange[400]!, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 24)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedPaymentMethod == methodKey
                          ? Colors.orange[600]
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (_selectedPaymentMethod == methodKey)
              Icon(Icons.check_circle, color: Colors.orange[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScreen() {
    double ridePrice = _selectedVehicle == 'moto' ? 5.20 : 9.20;

    // Variáveis para o mapa
    final Completer<GoogleMapController> _mapController = Completer();
    final LatLng _userLocation = LatLng(-23.5505, -46.6333);
    final LatLng _driverLocation = LatLng(-23.5510, -46.6340);
    final Set<Marker> _mapMarkers = {};
    bool _mapReady = false;
    bool _driverAccepted = false;

    // Inicializa marcadores
    _mapMarkers.add(
      Marker(
        markerId: MarkerId('user_location'),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'Você está aqui'),
      ),
    );

    _mapMarkers.add(
      Marker(
        markerId: MarkerId('driver_location'),
        position: _driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Motorista'),
      ),
    );

    // Função para quando o mapa é criado
    void _onMapCreated(GoogleMapController controller) {
      _mapController.complete(controller);
      setState(() {
        _mapReady = true;
      });

      // Simula motorista aceitando a corrida após 3 segundos
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _driverAccepted = true;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showPayment = false;
            });
          },
        ),
        title: Text('Pagamento'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mapa com acompanhamento do motorista
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Mapa do Google Maps
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _userLocation,
                      zoom: 15.0,
                    ),
                    markers: _mapMarkers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),

                  if (!_mapReady)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('Carregando mapa...'),
                          ],
                        ),
                      ),
                    ),

                  // Overlay com informações do motorista
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: _driverAccepted ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: _driverAccepted
                          ? Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange[100],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.orange[600],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Motorista encontrado!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'João Silva • ABC-1234',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '4.8',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              _selectedVehicle == 'moto'
                                                  ? Icons.two_wheeler
                                                  : Icons.directions_car,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _selectedVehicle == 'moto'
                                                  ? 'Honda CG 160'
                                                  : 'Fiat Uno',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.phone,
                                    color: Colors.green[600],
                                    size: 28,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ),

                  // Overlay de "Procurando motorista"
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange[400]!,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              _driverAccepted
                                  ? 'Motorista a caminho'
                                  : 'Procurando motorista...',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _driverAccepted
                                    ? Colors.green[700]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Resumo do pagamento
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo da corrida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                _selectedVehicle == 'moto'
                                    ? Icons.two_wheeler
                                    : Icons.directions_car,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 12),
                              Text(
                                _selectedVehicle == 'moto'
                                    ? 'Entrega de Moto'
                                    : 'Entrega de Carro',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Valor total',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'R\$ ${ridePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Forma de pagamento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Mostra o método selecionado com destaque
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange[400]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _paymentMethodIcons[_selectedPaymentMethod]!,
                                  color:
                                      _paymentMethodColors[_selectedPaymentMethod]!,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _paymentMethodDisplay[_selectedPaymentMethod]!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _paymentMethodBalances[_selectedPaymentMethod]!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.check, color: Colors.green[600]),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          Text(
                            'Para alterar o método de pagamento, volte para a tela anterior.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _driverAccepted
                          ? () {
                              if (_paymentMethod.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Corrida confirmada'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 60,
                                        ),
                                        SizedBox(height: 16),
                                        Text('Seu motorista está a caminho!'),
                                        SizedBox(height: 8),
                                        Text(
                                          'João Silva está vindo buscar sua encomenda',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tempo estimado: 5-8 minutos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            _showPayment = false;
                                            _paymentMethod = 'cash';
                                            _selectedPaymentMethod = 'cash';
                                            _deliveryAddressSet = false;
                                            // Limpar formulários
                                            _destinationAddressController
                                                .clear();
                                            _destinationDetailsController
                                                .clear();
                                            _destinationNameController.clear();
                                            _destinationPhoneController.clear();
                                            _senderAddressController.clear();
                                            _senderDetailsController.clear();
                                            _senderNameController.clear();
                                            _senderPhoneController.clear();
                                          });
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _driverAccepted
                            ? Colors.orange[400]
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Text(
                        _driverAccepted
                            ? 'Acompanhar corrida'
                            : 'Aguardando motorista...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixDepositScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showPixDeposit = false;
            });
          },
        ),
        title: Text('Depósito via PIX'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Escaneie o QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.qr_code,
                        size: 150,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Abra o app do seu banco e escaneie o código',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PIX Copia e Cola',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540525NG EXPRESS LTDA6009SAO PAULO62070503***63041D3D',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _copyPixCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      icon: _pixCopied ? Icon(Icons.check) : Icon(Icons.copy),
                      label: Text(
                        _pixCopied ? 'Copiado!' : 'Copiar código PIX',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue[800]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dica: Após realizar o pagamento, o saldo será creditado automaticamente em até 2 minutos.',
                        style: TextStyle(color: Colors.blue[800]),
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

  Widget _buildCardFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showCardForm = false;
              _cardType = '';
            });
          },
        ),
        title: Text(
          _cardType == 'credit' ? 'Cartão de Crédito' : 'Cartão de Débito',
        ),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[800]!, Colors.grey[900]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      '•••• •••• •••• ••••',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'monospace',
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nome do titular',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'SEU NOME',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Validade',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'MM/AA',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número do cartão*',
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome do titular*',
                  hintText: 'Como está no cartão',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[400]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Validade*',
                        hintText: 'MM/AA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV*',
                        hintText: '000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showCardForm = false;
                    _showWallet = false;
                    _cardType = '';
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Sucesso'),
                      content: Text('Cartão salvo com sucesso!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Salvar cartão',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showHistory = false;
            });
          },
        ),
        title: Text('Histórico de Entregas'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildHistoryCard(
              id: '#1234',
              date: '14/01/2026 - 11:30',
              status: 'Concluída',
              statusColor: Colors.green[100]!,
              statusTextColor: Colors.green[700]!,
              origin: 'Rua Olga Bernardes Amorim, 101',
              destination: 'Av. Santos Dumont, 500',
              vehicle: 'Honda CG 160',
              plate: 'ABC-1234',
              driver: 'Carlos Silva',
              price: 15.00,
              icon: Icons.two_wheeler,
            ),
            SizedBox(height: 12),
            _buildHistoryCard(
              id: '#1233',
              date: '13/01/2026 - 15:45',
              status: 'Concluída',
              statusColor: Colors.green[100]!,
              statusTextColor: Colors.green[700]!,
              origin: 'Centro, 234',
              destination: 'Bairro Industrial, 890',
              vehicle: 'Fiat Uno',
              plate: 'XYZ-5678',
              driver: 'Maria Santos',
              price: 28.00,
              icon: Icons.directions_car,
            ),
            SizedBox(height: 12),
            _buildHistoryCard(
              id: '#1232',
              date: '12/01/2026 - 09:20',
              status: 'Cancelada',
              statusColor: Colors.red[100]!,
              statusTextColor: Colors.red[700]!,
              origin: 'Rua das Flores, 67',
              destination: 'Av. Principal, 123',
              vehicle: 'Yamaha Fazer 250',
              plate: 'DEF-9012',
              driver: 'João Pereira',
              price: 0.00,
              icon: Icons.two_wheeler,
              isCanceled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String id,
    required String date,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String origin,
    required String destination,
    required String vehicle,
    required String plate,
    required String driver,
    required double price,
    required IconData icon,
    bool isCanceled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCanceled ? Colors.grey[300] : Colors.orange[400],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Origem',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      origin,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCanceled ? Colors.grey[500] : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCanceled ? Colors.grey[300]! : Colors.orange[400]!,
                    width: 2,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destino',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      destination,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCanceled ? Colors.grey[500] : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isCanceled ? Colors.grey[400] : Colors.grey[500],
              ),
              SizedBox(width: 8),
              Text(
                vehicle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isCanceled ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '• $plate',
                style: TextStyle(
                  fontSize: 12,
                  color: isCanceled ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: isCanceled ? Colors.grey[400] : Colors.grey[500],
              ),
              SizedBox(width: 8),
              Text(
                driver,
                style: TextStyle(
                  fontSize: 14,
                  color: isCanceled ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCanceled ? 'Corrida cancelada' : 'Valor da corrida',
                style: TextStyle(
                  fontSize: 14,
                  color: isCanceled ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              Text(
                isCanceled ? 'R\$ 0,00' : 'R\$ ${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCanceled ? Colors.grey[400] : Colors.green[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showWallet = false;
            });
          },
        ),
        title: Text('Minha Carteira'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange[400]!, Colors.orange[500]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo disponível',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'R\$ 125,00',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '💳 Crédito',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '📱 PIX',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Adicionar saldo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              _buildWalletOption(
                title: 'PIX',
                subtitle: 'Transferência instantânea',
                icon: Icons.pix,
                color: Colors.blue[100]!,
                iconColor: Colors.blue[600]!,
                onTap: () {
                  setState(() {
                    _showPixDeposit = true;
                  });
                },
              ),
              SizedBox(height: 12),
              _buildWalletOption(
                title: 'Cartão de Crédito',
                subtitle: 'Visa, Master, Elo',
                icon: Icons.credit_card,
                color: Colors.purple[100]!,
                iconColor: Colors.purple[600]!,
                onTap: () {
                  setState(() {
                    _cardType = 'credit';
                    _showCardForm = true;
                  });
                },
              ),
              SizedBox(height: 12),
              _buildWalletOption(
                title: 'Cartão de Débito',
                subtitle: 'Débito direto',
                icon: Icons.credit_card,
                color: Colors.green[100]!,
                iconColor: Colors.green[600]!,
                onTap: () {
                  setState(() {
                    _cardType = 'debit';
                    _showCardForm = true;
                  });
                },
              ),
              SizedBox(height: 24),
              Text(
                'Histórico de transações',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              _buildTransactionItem(
                title: 'Recarga PIX',
                date: '10/01/2026',
                amount: 100.00,
                isPositive: true,
              ),
              SizedBox(height: 8),
              _buildTransactionItem(
                title: 'Entrega #1234',
                date: '14/01/2026',
                amount: 15.00,
                isPositive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required double amount,
    required bool isPositive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
          Text(
            '${isPositive ? '+' : '-'} R\$ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPositive ? Colors.green[600] : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }
}
