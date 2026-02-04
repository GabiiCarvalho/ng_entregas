import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Login com email/senha
  Future<UserModel?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        return await _getUserFromDatabase(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Erro ao fazer login: $e';
    }
  }

  // Cadastro com email/senha
  Future<UserModel?> signUpWithEmailAndPassword(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      // Validações
      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
        throw 'Preencha todos os campos';
      }

      if (!email.contains('@')) {
        throw 'Email inválido';
      }

      if (password.length < 6) {
        throw 'Senha deve ter pelo menos 6 caracteres';
      }

      if (phone.length < 10) {
        throw 'Telefone inválido';
      }

      // Criar usuário no Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Atualizar nome do usuário
        await user.updateDisplayName(name);
        await user.reload();

        // Criar usuário no Realtime Database
        await _createUserInDatabase(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          photoUrl: null,
          userType: 'client',
        );

        return await _getUserFromDatabase(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Erro ao cadastrar: $e';
    }
  }

  // Login com Google
  Future<UserModel?> loginWithGoogle() async {
    try {
      // Disparar o fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Login com Google cancelado';
      }

      // Obter os detalhes da autenticação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Criar uma credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Fazer login no Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Verificar se é um novo usuário
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // Criar usuário no banco de dados se for novo
          await _createUserInDatabase(
            uid: user.uid,
            name:
                user.displayName ?? googleUser.displayName ?? 'Usuário Google',
            email: user.email ?? googleUser.email,
            phone: user.phoneNumber ?? '',
            photoUrl: user.photoURL ?? googleUser.photoUrl,
            userType: 'client',
          );
        }

        return await _getUserFromDatabase(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Erro ao fazer login com Google: $e';
    }
  }

  // Criar usuário no Realtime Database
  Future<void> _createUserInDatabase({
    required String uid,
    required String name,
    required String? email,
    required String phone,
    required String? photoUrl,
    required String userType,
  }) async {
    try {
      await _dbRef.child('users').child(uid).set({
        'userId': uid,
        'name': name,
        'email': email ?? '',
        'phone': phone,
        'userType': userType,
        'createdAt': DateTime.now().toIso8601String(),
        'blockStatus': 'no',
        'photoUrl': photoUrl ?? '',
        'walletBalance': 0.0,
      });
    } catch (e) {
      print('Erro ao criar usuário no banco de dados: $e');
      throw 'Erro ao criar perfil do usuário';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      throw 'Erro ao fazer logout';
    }
  }

  // Stream do usuário atual
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser != null) {
        return await _getUserFromDatabase(firebaseUser.uid);
      }
      return null;
    });
  }

  // Obter usuário atual
  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel?> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await _getUserFromDatabase(user.uid);
    }
    return null;
  }

  // Buscar usuário do banco de dados
  Future<UserModel?> _getUserFromDatabase(String uid) async {
    try {
      final snapshot = await _dbRef.child('users').child(uid).once();

      if (snapshot.snapshot.value == null) {
        // Se não existe no banco, retornar informações básicas do Auth
        final User? user = _auth.currentUser;
        if (user != null) {
          return UserModel(
            uid: user.uid,
            name: user.displayName ?? user.email?.split('@').first ?? 'Usuário',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            photoUrl: user.photoURL,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            isDriver: false,
            wallet: WalletInfo(balance: 0.0, transactions: []),
            ratings: UserRatings(average: 5.0, count: 0),
            paymentMethods: ['cash'],
            recentAddresses: [],
          );
        }
        return null;
      }

      final data = Map<String, dynamic>.from(
        snapshot.snapshot.value as Map<dynamic, dynamic>,
      );

      return UserModel(
        uid: uid,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        photoUrl: data['photoUrl'],
        createdAt: DateTime.parse(
          data['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        isDriver: data['userType'] == 'driver',
        wallet: WalletInfo(
          balance: (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
          transactions: [],
        ),
        ratings: UserRatings(average: 5.0, count: 0),
        paymentMethods: ['cash'],
        recentAddresses: [],
      );
    } catch (e) {
      print('Erro ao buscar usuário do banco: $e');
      return null;
    }
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Erro ao enviar email de recuperação: $e';
    }
  }

  // Atualizar perfil
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        if (name != null) {
          await user.updateDisplayName(name);
        }

        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Atualizar no banco de dados também
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (phone != null) updates['phone'] = phone;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;

        if (updates.isNotEmpty) {
          await _dbRef.child('users').child(user.uid).update(updates);
        }
      }
    } catch (e) {
      throw 'Erro ao atualizar perfil: $e';
    }
  }

  // Tratar erros do Firebase Auth
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desativado';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'account-exists-with-different-credential':
        return 'Conta já existe com credenciais diferentes';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  // Verificar se email está verificado
  Future<bool> isEmailVerified() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Enviar email de verificação
  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Atualizar senha
  Future<void> updatePassword(String newPassword) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  // Deletar conta
  Future<void> deleteAccount() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Deletar do banco de dados
      await _dbRef.child('users').child(user.uid).remove();
      // Deletar do Firebase Auth
      await user.delete();
    }
  }
}
