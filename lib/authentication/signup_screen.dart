import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '/authentication/login_screen.dart';
import '/methods/common_methods.dart';
import '/widgets/loading_dialog.dart';
import '../global/global_var.dart';
import '/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    userNameTextEditingController.dispose();
    userPhoneTextEditingController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  checkIfNetworkIsAvailable() async {
    bool isConnected = await cMethods.checkConnectivity(context);
    if (isConnected && _formKey.currentState!.validate()) {
      signUpFormValidation();
    }
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar(
        "Seu nome deve ter pelo menos 4 caracteres.",
        context,
      );
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar(
        "Seu telefone deve ter pelo menos 8 caracteres.",
        context,
      );
    } else if (!emailTextEditingController.text.contains("@") ||
        !emailTextEditingController.text.contains(".")) {
      cMethods.displaySnackBar("Por favor, insira um email válido.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
        "Sua senha deve ter pelo menos 6 caracteres.",
        context,
      );
      return;
    }

    registerNewUser();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Criando sua conta..."),
    );

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          );

      if (!context.mounted) return;
      Navigator.pop(context);

      // Salvar dados do usuário no Realtime Database
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userCredential.user!.uid);

      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": userCredential.user!.uid,
        "blockStatus": "no",
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "walletBalance": 0.0,
        "profileImage": "",
        "userType": "client",
      };

      await usersRef.set(userDataMap);

      // Salvar dados nas variáveis globais
      userName = userNameTextEditingController.text.trim();
      userPhone = userPhoneTextEditingController.text.trim();
      userID = userCredential.user!.uid;

      if (!context.mounted) return;

      // Navegar para a tela principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => MyApp()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      Navigator.pop(context);

      String errorMessage = "Ocorreu um erro ao criar a conta.";
      if (error.code == 'email-already-in-use') {
        errorMessage = "Este email já está em uso. Tente fazer login.";
      } else if (error.code == 'weak-password') {
        errorMessage = "A senha é muito fraca. Use pelo menos 6 caracteres.";
      } else if (error.code == 'invalid-email') {
        errorMessage = "Email inválido. Verifique o formato.";
      } else if (error.code == 'operation-not-allowed') {
        errorMessage = "Operação não permitida. Contate o suporte.";
      }

      cMethods.displaySnackBar(errorMessage, context);
    } catch (errorMsg) {
      if (!context.mounted) return;
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão de voltar (opcional)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Logo e título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
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
                          child: Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: Colors.orange[400],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'NG EXPRESS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[400],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Criar nova conta',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Formulário de cadastro
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo Nome
                      TextFormField(
                        controller: userNameTextEditingController,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange[400]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          hintText: 'Digite seu nome completo',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, digite seu nome';
                          }
                          if (value.trim().length < 3) {
                            return 'Nome deve ter pelo menos 4 caracteres';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),

                      SizedBox(height: 16),

                      // Campo Telefone
                      TextFormField(
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(
                            Icons.phone_android,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange[400]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          hintText: '(11) 99999-9999',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, digite seu telefone';
                          }
                          if (value.trim().length < 7) {
                            return 'Telefone deve ter pelo menos 8 caracteres';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Campo Email
                      TextFormField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange[400]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          hintText: 'seu@email.com',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, digite seu email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Digite um email válido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Campo Senha
                      TextFormField(
                        controller: passwordTextEditingController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange[400]!,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          hintText: 'Digite sua senha',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, digite sua senha';
                          }
                          if (value.trim().length < 5) {
                            return 'Senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 8),

                      // Dica da senha
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          'Use pelo menos 6 caracteres incluindo letras e números',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Botão de cadastrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : checkIfNetworkIsAvailable,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            elevation: 3,
                            shadowColor: Colors.orange[200],
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Divisor
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou continue com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Botão Google
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // Implementar login com Google
                                  cMethods.displaySnackBar(
                                    "Login com Google em desenvolvimento",
                                    context,
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 1,
                          ),
                          icon: Container(
                            width: 24,
                            height: 24,
                            child: Image.asset(
                              'assets/images/google.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.g_mobiledata,
                                  size: 24,
                                  color: Colors.red[400],
                                );
                              },
                            ),
                          ),
                          label: Text(
                            'Continuar com Google',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Link para login
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Já tem uma conta?',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => LoginScreen(),
                                        ),
                                      );
                                    },
                              child: Text(
                                'Faça login aqui',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[400],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // Termos de uso
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            height: 1.5,
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
      ),
    );
  }
}
