import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        ),
      ),
      home: DeliveryApp(),
    );
  }
}

class DeliveryApp extends StatefulWidget {
  @override
  _DeliveryAppState createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  String _currentScreen = 'splash';
  bool _isLogin = true;
  String _activeTab = 'enviar';
  bool _showDestinationForm = false;
  bool _showSenderForm = false;
  bool _showHistory = false;
  bool _showWallet = false;
  bool _showPixDeposit = false;
  bool _showCardForm = false;
  String _cardType = '';
  bool _showPayment = false;
  String _paymentMethod = '';
  String _selectedVehicle = 'moto';
  bool _pixCopied = false;
  bool _showProfile = false;
  bool _showItemDetails = false;
  bool _deliveryAddressSet = false; // Nova variável para controlar se o endereço foi definido

  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'phone': '',
    'password': '',
  };

  // Variáveis para detalhes do item
  String _selectedItemType = 'Itens pessoais';
  String _itemValue = '';
  String _deliveryNotes = '';

  void _copyPixCode() async {
    const pixCode = '00020126580014br.gov.bcb.pix0136a1b2c3d4-e5f6-7890-abcd-ef1234567890520400005303986540525NG EXPRESS LTDA6009SAO PAULO62070503***63041D3D';
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

  @override
  Widget build(BuildContext context) {
    // Configurar orientação e layout responsivo
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (_currentScreen == 'splash') {
      return _buildSplashScreen();
    }

    if (_currentScreen == 'auth') {
      return _buildAuthScreen();
    }

    if (_showProfile) {
      return _buildProfileScreen();
    }

    if (_showItemDetails) {
      return _buildItemDetailsScreen();
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

    return _buildMainScreen();
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
            colors: [Colors.orange[400]!, Colors.orange[500]!, Colors.deepOrange[400]!],
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
              SizedBox(
                width: 280,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentScreen = 'auth';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange[600],
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Começar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLogin ? Colors.orange[400] : Colors.white,
                              foregroundColor: _isLogin ? Colors.white : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Entrar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isLogin ? Colors.orange[400] : Colors.white,
                              foregroundColor: !_isLogin ? Colors.white : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Cadastrar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    if (!_isLogin) ...[
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                          hintText: 'Nome completo',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _authData['name'] = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.grey[400]),
                        hintText: 'E-mail',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _authData['email'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone, color: Colors.grey[400]),
                        hintText: 'Telefone (obrigatório)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _authData['phone'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                        hintText: 'Senha',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _authData['password'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentScreen = 'main';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          _isLogin ? 'Entrar' : 'Criar conta',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('ou', style: TextStyle(color: Colors.grey[500])),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentScreen = 'main';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey[200]!, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        icon: Icon(Icons.g_mobiledata, size: 24),
                        label: Text(
                          'Continuar com Google',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                          'G',
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
                  Text(
                    'Olá, Gabriele!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                                child: Icon(Icons.chevron_right, size: 24, color: Colors.black),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Icon(
                                    Icons.two_wheeler,
                                    size: 96,
                                    color: Colors.grey[400],
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    right: -5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange[400],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.check,
                                          size: 24, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 40),
                              Stack(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 96,
                                    color: Colors.grey[400],
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    right: -5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange[400],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.check,
                                          size: 24, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _activeTab = 'enviar';
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16),
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
                                            color: _activeTab == 'enviar' ? Colors.black : Colors.grey[400],
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
                                    onPressed: () {
                                      setState(() {
                                        _activeTab = 'receber';
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16),
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
                                            color: _activeTab == 'receber' ? Colors.black : Colors.grey[400],
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
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Para ENVIAR: Endereço do usuário (remetente) em cima, "Entregar para" embaixo
                                if (_activeTab == 'enviar') ...[
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
                                                  'Rua Olga Bernardes Amorim, 101',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Gabriele · 47996412384',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
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
                                              border: Border.all(
                                                color: Colors.orange[400]!,
                                                width: 2,
                                              ),
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
                                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] 
                                // Para RECEBER: "Enviar de" em cima, endereço do usuário (destinatário) embaixo
                                else ...[
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
                                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
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
                                              border: Border.all(
                                                color: Colors.orange[400]!,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Rua Olga Bernardes Amorim, 101',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Gabriele · 47996412384',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 16),
                                
                                // Seção de seleção de veículo - SÓ MOSTRA SE O ENDEREÇO DE ENTREGA FOI DEFINIDO
                                if (_deliveryAddressSet) ...[
                                  Container(
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selecione o tipo de veículo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedVehicle = 'moto';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: _selectedVehicle == 'moto' ? Colors.orange[50] : Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: _selectedVehicle == 'moto' ? Colors.orange[400]! : Colors.grey[200]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.two_wheeler,
                                                        size: 32,
                                                        color: _selectedVehicle == 'moto' ? Colors.orange[600] : Colors.grey[400],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Moto',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Mais rápido',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedVehicle = 'carro';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: _selectedVehicle == 'carro' ? Colors.orange[50] : Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: _selectedVehicle == 'carro' ? Colors.orange[400]! : Colors.grey[200]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.directions_car,
                                                        size: 32,
                                                        color: _selectedVehicle == 'carro' ? Colors.orange[600] : Colors.grey[400],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Carro',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Mais espaço',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ] else ...[
                                  // Veículos bloqueados com ícone de cadeado
                                  Container(
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selecione o tipo de veículo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Opacity(
                                                opacity: 0.5,
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Icon(
                                                            Icons.two_wheeler,
                                                            size: 32,
                                                            color: Colors.grey[400],
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Icon(
                                                              Icons.lock,
                                                              size: 16,
                                                              color: Colors.grey[500],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Moto',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                      Text(
                                                        'Mais rápido',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[400],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Opacity(
                                                opacity: 0.5,
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Icon(
                                                            Icons.directions_car,
                                                            size: 32,
                                                            color: Colors.grey[400],
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Icon(
                                                              Icons.lock,
                                                              size: 16,
                                                              color: Colors.grey[500],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Carro',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey[500],
                                                        ),
                                                      ),
                                                      Text(
                                                        'Mais espaço',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[400],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Center(
                                          child: Text(
                                            'Disponível após selecionar endereço de entrega',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                                
                                // Botão Continuar - habilitado apenas se o endereço foi definido
                                ElevatedButton(
                                  onPressed: _deliveryAddressSet
                                      ? () {
                                          setState(() {
                                            _showItemDetails = true;
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _deliveryAddressSet ? Colors.orange[400] : Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    minimumSize: Size(double.infinity, 0),
                                  ),
                                  child: Text(
                                    _deliveryAddressSet ? 'Continuar' : 'Selecione o endereço de entrega',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showHistory = true;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 24, color: Colors.grey[400]),
                  SizedBox(height: 4),
                  Text(
                    'Histórico',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.orange[400],
                child: Icon(Icons.search, size: 28),
                elevation: 4,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showWallet = true;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments, size: 24, color: Colors.grey[400]),
                  SizedBox(height: 4),
                  Text(
                    'Carteira',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
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
        title: Text('Detalhes da entrega'),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Tipo de item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Itens pessoais',
                  'Alimentação',
                  'Vestuário',
                  'Eletrônicos',
                  'Documentos',
                  'Chaves',
                  'Medicamentos',
                  'Outros',
                ].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: _selectedItemType == item,
                    onSelected: (selected) {
                      setState(() {
                        _selectedItemType = item;
                      });
                    },
                    selectedColor: Colors.orange[400],
                    labelStyle: TextStyle(
                      color: _selectedItemType == item ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              Text(
                'Valor do item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: 'Insira o valor do item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              Text(
                'Observações da entrega',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                maxLines: 4,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Adicione uma descrição ou observações',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Implement address selection
                },
              ),
              SizedBox(height: 16),
              TextField(
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                  labelText: 'Número de telefone*',
                  hintText: 'Telefone do destinatário',
                  prefix: Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇧🇷'),
                        SizedBox(width: 4),
                        Text('+55'),
                      ],
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                  setState(() {
                    _deliveryAddressSet = true; // Marca que o endereço foi definido
                    _showDestinationForm = false;
                    _showItemDetails = true;
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
                  'Continuar para detalhes do item',
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // Implement address selection
                },
              ),
              SizedBox(height: 16),
              TextField(
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                  labelText: 'Número de telefone*',
                  hintText: 'Telefone do remetente',
                  prefix: Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇧🇷'),
                        SizedBox(width: 4),
                        Text('+55'),
                      ],
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                  setState(() {
                    _showSenderForm = false;
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

  Widget _buildPaymentScreen() {
    double ridePrice = _selectedVehicle == 'moto' ? 15.00 : 28.00;

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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _selectedVehicle == 'moto' ? Icons.two_wheeler : Icons.directions_car,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 12),
                        Text(
                          _selectedVehicle == 'moto' ? 'Entrega de Moto' : 'Entrega de Carro',
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
                        Text('Valor total', style: TextStyle(color: Colors.grey[600])),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    _buildPaymentOption(
                      title: 'Carteira Digital',
                      subtitle: 'Saldo: R\$ 125,00',
                      icon: Icons.account_balance_wallet,
                      value: 'wallet',
                      color: Colors.grey[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildPaymentOption(
                      title: 'PIX',
                      subtitle: 'Pagamento instantâneo',
                      icon: Icons.pix,
                      value: 'pix',
                      color: Colors.blue[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildPaymentOption(
                      title: 'Cartão',
                      subtitle: 'Crédito ou Débito',
                      icon: Icons.credit_card,
                      value: 'card',
                      color: Colors.purple[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildPaymentOption(
                      title: 'Dinheiro',
                      subtitle: 'Pagar na entrega',
                      icon: Icons.money,
                      value: 'cash',
                      color: Colors.green[600]!,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_paymentMethod.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Sucesso'),
                        content: Text('Pagamento confirmado! Procurando motorista...'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _showPayment = false;
                                _paymentMethod = '';
                                _deliveryAddressSet = false; // Reseta para próxima entrega
                              });
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Atenção'),
                        content: Text('Por favor, selecione uma forma de pagamento'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
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
                  'Confirmar pagamento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _paymentMethod == value ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _paymentMethod == value ? Colors.orange[400]! : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _paymentMethod == value ? Colors.orange[400]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: _paymentMethod == value
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange[400],
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16),
            Icon(icon, color: color),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[100],
                      child: Icon(Icons.qr_code, size: 150, color: Colors.grey[800]),
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
                    child: Text('ou', style: TextStyle(color: Colors.grey[500])),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      label: Text(_pixCopied ? 'Copiado!' : 'Copiar código PIX'),
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
        title: Text(_cardType == 'credit' ? 'Cartão de Crédito' : 'Cartão de Débito'),
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                    borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
                          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
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
                    Text('Origem', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                    Text('Destino', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
              Icon(icon, size: 16, color: isCanceled ? Colors.grey[400] : Colors.grey[500]),
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
                style: TextStyle(fontSize: 12, color: isCanceled ? Colors.grey[400] : Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: isCanceled ? Colors.grey[400] : Colors.grey[500]),
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
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('💳 Crédito', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('📱 PIX', style: TextStyle(color: Colors.white)),
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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
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

  Widget _buildProfileScreen() {
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
              // Cabeçalho do perfil
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
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
                          'G',
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
                            'Gabriele',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Editar minhas informações',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Seção Atividade
              _buildProfileSection(
                title: 'Atividade',
                items: [
                  _buildProfileItem(
                    title: '99Pay',
                    subtitle: 'A6 R\$377',
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue[600]!,
                  ),
                ],
              ),
              
              // Seção principal
              _buildProfileSection(
                title: 'Ajuda',
                items: [
                  _buildProfileItem(
                    title: 'Mensagens',
                    icon: Icons.message,
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
              
              // Seção de convites
              _buildProfileSection(
                title: 'Convide',
                items: [
                  _buildProfileItem(
                    title: 'Convide Amigos',
                    icon: Icons.group_add,
                    iconColor: Colors.purple[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Convide Motoristas',
                    icon: Icons.directions_car,
                    iconColor: Colors.orange[600]!,
                  ),
                ],
              ),
              
              // Seção de oportunidades
              _buildProfileSection(
                title: 'Oportunidades',
                items: [
                  _buildProfileItem(
                    title: 'Seja Motorista',
                    icon: Icons.work,
                    iconColor: Colors.orange[600]!,
                  ),
                ],
              ),
              
              // Seção de benefícios
              _buildProfileSection(
                title: 'Benefícios',
                items: [
                  _buildProfileItem(
                    title: 'Descontos',
                    icon: Icons.discount,
                    iconColor: Colors.red[600]!,
                  ),
                  _buildProfileItem(
                    title: 'Escanear',
                    icon: Icons.qr_code_scanner,
                    iconColor: Colors.blue[600]!,
                  ),
                ],
              ),
              
              // Botão de sair
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentScreen = 'auth';
                      _showProfile = false;
                      _deliveryAddressSet = false; // Reseta o estado do endereço
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text('Sair'),
                ),
              ),
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
          child: Column(
            children: items,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfileItem({
    required String title,
    String? subtitle,
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
              child: Center(
                child: Icon(icon, size: 20, color: iconColor),
              ),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}