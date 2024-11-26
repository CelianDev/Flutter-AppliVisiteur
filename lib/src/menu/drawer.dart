import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isPermanent;
  final ValueChanged<int>? onDestinationSelected;

  const AppDrawer({
    super.key,
    this.isPermanent = false,
    this.onDestinationSelected,
  });

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
