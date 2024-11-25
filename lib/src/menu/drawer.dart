// drawer.dart
import 'package:flutter/material.dart';
import '../dashboard/dashboard_view.dart';
import '../settings/settings_view.dart';

class AppDrawer extends StatelessWidget {
  final bool isPermanent;

  const AppDrawer({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context) {
    Widget menuList = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color:  Color(0xFF66A2D3),
          ),
          accountName: Text(
            'Nom de l\'utilisateur',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          accountEmail: Text('email@example.com'),
          currentAccountPicture: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://www.example.com/images/avatar.png'),
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
          onTap: () {
            // Ajouter la logique de déconnexion ici
          },
        ),
      ],
    );

    return isPermanent
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
