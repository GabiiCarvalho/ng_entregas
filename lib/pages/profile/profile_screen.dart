import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  late UserModel _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      final userStream = _databaseService.getUserStream(user.uid);
      userStream.listen((userData) {
        setState(() {
          _currentUser = userData;
          _isLoading = false;
        });
      });
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.orange[600]),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: _currentUser.name,
                ),
                onChanged: (value) {
                  // Update name logic
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: _currentUser.phone,
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  // Update phone logic
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: _currentUser.email,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  // Update email logic
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              // Save changes
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[400],
            ),
            child: Text('Salvar'),
          ),
        ],
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
              child: Center(child: Icon(icon, size: 20, color: iconColor)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange[400]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Meu Perfil'),
        backgroundColor: Colors.orange[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: Container(
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
                        child: _currentUser.photoUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  _currentUser.photoUrl!,
                                ),
                                radius: 34,
                              )
                            : Text(
                                _currentUser.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 28,
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
                          _currentUser.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _currentUser.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: Text(
                            'Editar perfil',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[600],
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

            // Wallet Section
            _buildProfileSection(
              title: 'Carteira Digital',
              items: [
                _buildProfileItem(
                  title: 'Saldo disponível',
                  subtitle:
                      'R\$ ${_currentUser.wallet.balance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.blue[600]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen()),
                    );
                  },
                ),
              ],
            ),

            // Activity Section
            _buildProfileSection(
              title: 'Atividade',
              items: [
                _buildProfileItem(
                  title: 'Entregas realizadas',
                  subtitle: '${_currentUser.ratings.count} corridas',
                  icon: Icons.local_shipping,
                  iconColor: Colors.green[600]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
                _buildProfileItem(
                  title: 'Avaliação média',
                  subtitle:
                      '⭐ ${_currentUser.ratings.average.toStringAsFixed(1)}',
                  icon: Icons.star,
                  iconColor: Colors.amber[600]!,
                ),
              ],
            ),

            // Settings Section
            _buildProfileSection(
              title: 'Configurações',
              items: [
                _buildProfileItem(
                  title: 'Métodos de pagamento',
                  icon: Icons.payment,
                  iconColor: Colors.purple[600]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileItem(
                  title: 'Endereços salvos',
                  subtitle: '${_currentUser.recentAddresses.length} endereços',
                  icon: Icons.location_on,
                  iconColor: Colors.red[600]!,
                ),
                _buildProfileItem(
                  title: 'Notificações',
                  icon: Icons.notifications,
                  iconColor: Colors.blue[600]!,
                ),
                _buildProfileItem(
                  title: 'Privacidade',
                  icon: Icons.security,
                  iconColor: Colors.green[600]!,
                ),
              ],
            ),

            // Help Section
            _buildProfileSection(
              title: 'Ajuda',
              items: [
                _buildProfileItem(
                  title: 'Central de ajuda',
                  icon: Icons.help,
                  iconColor: Colors.blue[600]!,
                ),
                _buildProfileItem(
                  title: 'Termos de uso',
                  icon: Icons.description,
                  iconColor: Colors.grey[600]!,
                ),
                _buildProfileItem(
                  title: 'Política de privacidade',
                  icon: Icons.privacy_tip,
                  iconColor: Colors.green[600]!,
                ),
              ],
            ),

            // Sign Out Button
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth',
                    (route) => false,
                  );
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
    );
  }
}
