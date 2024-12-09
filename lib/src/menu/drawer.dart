import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../login/login_view.dart';

class AppDrawer extends StatefulWidget {
  final bool isPermanent;
  final ValueChanged<int>? onDestinationSelected;

  const AppDrawer({
    super.key,
    this.isPermanent = false,
    this.onDestinationSelected,
  });

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

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginView.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget headerWidget;

    if (_isLoading) {
      headerWidget = const DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFF66A2D3),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    } else if (_userData != null) {
      headerWidget = UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          color: Color(0xFF66A2D3),
        ),
        accountName: Text(
          _userData!['username'] ?? 'Nom de l\'utilisateur',
          style: const TextStyle(fontSize: 18),
        ),
        accountEmail: Text(_userData!['email'] ?? 'email@example.com'),
        currentAccountPicture: _userData!['avatar'] != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(_userData!['avatar']),
              )
            : const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/default_avatar.png'),
              ),
      );
    } else {
      // Aucune donnée utilisateur, afficher un message par défaut
      headerWidget = const DrawerHeader(
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
      );
    }

    return widget.isPermanent
        ? SizedBox(
            width: 250,
            child: Drawer(
              elevation: 0,
              child: Column(
                children: [
                  headerWidget,
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.dashboard),
                          title: const Text('Tableau de bord'),
                          onTap: () {
                            widget.onDestinationSelected?.call(0);
                            if (!widget.isPermanent) Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: const Text('Compte-Rendus'),
                          onTap: () {
                            widget.onDestinationSelected?.call(1);
                            if (!widget.isPermanent) Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Déconnexion'),
                    onTap: () async {
                      await _logout();
                    },
                  ),
                ],
              ),
            ),
          )
        : Drawer(
            child: Column(
              children: [
                headerWidget,
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: const Text('Tableau de bord'),
                        onTap: () {
                          widget.onDestinationSelected?.call(0);
                          if (!widget.isPermanent) Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('Compte-Rendus'),
                        onTap: () {
                          widget.onDestinationSelected?.call(1);
                          if (!widget.isPermanent) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () async {
                    await _logout();
                  },
                ),
              ],
            ),
          );
  }
}
