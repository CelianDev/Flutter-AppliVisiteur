import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../dashboard/dashboard_view.dart';
import '../settings/settings_view.dart';
import '../login/login_view.dart';

class AppDrawer extends StatefulWidget {
  final bool isPermanent;
  final Future<void> Function()? userDataFetcher;
  final ValueChanged<int>? onDestinationSelected;

  const AppDrawer({super.key, this.isPermanent = false, this.userDataFetcher, this.onDestinationSelected});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Méthode pour récupérer les données de l'utilisateur
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await _authService.getProtectedData('/protected/me');

      if (response != null && response.statusCode == 200) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _message = 'Échec de la récupération des données utilisateur.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur : $e';
        _isLoading = false;
      });
    }
  }

  /// Méthode pour gérer la déconnexion
  Future<void> _logout() async {
    await _authService.deleteJwtToken();

    // Check if the widget is still mounted before accessing the context
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginView.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF66A2D3),
            ),
            accountName: Text(
              'Nom de l\'utilisateur',
              style: TextStyle(fontSize: 18),
            ),
            accountEmail: Text('email@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://www.example.com/images/avatar.png',
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Tableau de bord'),
                  onTap: () {
                    onDestinationSelected?.call(0);
                    if (!isPermanent) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Compte-Rendus'),
                  onTap: () {
                    onDestinationSelected?.call(1);
                    if (!isPermanent) Navigator.pop(context);
                  },
                ),
                // Ajoutez d'autres options ici
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
