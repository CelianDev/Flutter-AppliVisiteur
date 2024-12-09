// drawer.dart
import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../dashboard/dashboard_view.dart';
import '../settings/settings_view.dart';
import '../login/login_view.dart';

class AppDrawer extends StatefulWidget {
  final bool isPermanent;
  final Future<void> Function()? userDataFetcher;

  const AppDrawer({super.key, this.isPermanent = false, this.userDataFetcher});

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
    Widget menuList = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _isLoading
            ? const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF66A2D3),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : _userData != null
                ? UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF66A2D3),
                    ),
                    accountName: Text(
                      _userData!['username'] ?? 'Nom de l\'utilisateur',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    accountEmail:
                        Text(_userData!['email'] ?? 'email@example.com'),
                    currentAccountPicture: _userData!['avatar'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(_userData!['avatar']),
                          )
                        : const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/default_avatar.png'),
                          ),
                  )
                : const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF66A2D3),
                    ),
                    child: Center(
                      child: Text(
                        'Utilisateur non connecté',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Tableau de bord'),
          onTap: () {
            Navigator.pushNamed(context, DashboardView.routeName);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Paramètres'),
          onTap: () {
            Navigator.pushNamed(context, SettingsView.routeName);
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Déconnexion'),
          onTap: () async {
            await _logout();
          },
        ),
      ],
    );

    return widget.isPermanent
        ? SizedBox(
            width: 250, // Ajustez la largeur si nécessaire
            child: Drawer(
              elevation: 0,
              child: menuList,
            ),
          )
        : Drawer(
            child: menuList,
          );
  }
}
