import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '/authentication/signup_screen.dart';
import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '/pages/home_page.dart';
import '/widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Por favor, insira um e-mail válido.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
        "Sua senha deve ter pelo menos 6 caracteres.",
        context,
      );
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar(
        "Seu telefone deve ter pelo menos 8 caracteres.",
        context,
      );
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Autenticando..."),
    );

    try {
      // 1. Primeiro faz login com email e senha
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          );

      final User? userFirebase = userCredential.user;

      if (userFirebase != null) {
        // 2. Verifica no Realtime Database se o telefone corresponde
        DatabaseReference usersRef = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(userFirebase.uid);

        await usersRef.once().then((snap) {
          if (snap.snapshot.value != null) {
            final userData = snap.snapshot.value as Map;

            // Verifica status de bloqueio
            if (userData["blockStatus"] == "no") {
              // Obtém o telefone armazenado
              final storedPhone = userData["phone"]?.toString() ?? "";
              final enteredPhone = userPhoneTextEditingController.text.trim();

              // Verifica se o telefone informado corresponde ao cadastrado
              if (storedPhone.isEmpty) {
                // Se não há telefone cadastrado, permite login
                userName = userData["name"];
                userPhone = storedPhone;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => HomePage()),
                );
              } else if (storedPhone == enteredPhone) {
                // Telefone correto
                userName = (snap.snapshot.value as Map)["name"];
                userPhone = storedPhone;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => HomePage()),
                );
              } else {
                // Telefone incorreto
                FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pop(context);
                cMethods.displaySnackBar(
                  "Telefone incorreto. Por favor, verifique seu número.",
                  context,
                );
              }
            } else {
              FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pop(context);
              cMethods.displaySnackBar(
                "Você está bloqueado. Contate o administrador: comercial.ngexpress@gmail.com",
                context,
              );
            }
          } else {
            FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pop(context);
            cMethods.displaySnackBar(
              "Seu registro não existe como usuário.",
              context,
            );
          }
        });
      }
    } catch (errorMsg) {
      if (!context.mounted) return;
      Navigator.pop(context);
      cMethods.displaySnackBar(
        errorMsg.toString().replaceAll("Exception: ", ""),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 40),

            Image.asset("assets/images/logo.png"),
            SizedBox(height: 32),

            // Botões de alternância
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.white,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[600],
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

            // Campos de entrada
            TextField(
              controller: emailTextEditingController,
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
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            TextField(
              controller: userPhoneTextEditingController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.grey[400]),
                hintText: 'Telefone',
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
            ),
            SizedBox(height: 16),

            TextField(
              controller: passwordTextEditingController,
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
            ),
            SizedBox(height: 24),

            // Botão de entrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  checkIfNetworkIsAvailable();
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
                  'Entrar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Divisor
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

            // Botão do Google
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implementar login com Google
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

            // Link para cadastro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => SignUpScreen()),
                );
              },
              child: Text(
                'Não tem uma conta? Cadastre-se aqui',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
