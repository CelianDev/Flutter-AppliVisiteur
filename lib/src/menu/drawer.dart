import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../login/login_view.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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

    // 🔹 Récupérer userProvider avant le await
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await _authService.getProtectedData('/protected/me');

      if (response != null && response.statusCode == 200) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
        });

        // 🔹 Ici, plus besoin d'accéder à context
        userProvider.setUser(_userData!['id'], _userData!['username']);
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

    // Nettoyage des données utilisateur
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearUser();

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
                backgroundImage: AssetImage('assets/images/default_avatar.png'),
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
                          leading: const Icon(
                              Icons.create), // Icône pour "Nouveau rapport"
                          title: const Text('Nouveau rapport'),
                          onTap: () {
                            widget.onDestinationSelected
                                ?.call(1); // Index 1 : Page Nouveau Rapport
                            if (!widget.isPermanent) Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                              Icons.list), // Icône pour "Mes comptes rendus"
                          title: const Text('Mes comptes rendus'),
                          onTap: () {
                            widget.onDestinationSelected
                                ?.call(2); // Index 2 : Page Mes Comptes Rendus
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
                        leading: const Icon(
                            Icons.create), // Icône pour "Nouveau rapport"
                        title: const Text('Nouveau rapport'),
                        onTap: () {
                          widget.onDestinationSelected
                              ?.call(1); // Index 1 : Page Nouveau Rapport
                          if (!widget.isPermanent) Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                            Icons.list), // Icône pour "Mes comptes rendus"
                        title: const Text('Mes comptes rendus'),
                        onTap: () {
                          widget.onDestinationSelected
                              ?.call(2); // Index 2 : Page Mes Comptes Rendus
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
