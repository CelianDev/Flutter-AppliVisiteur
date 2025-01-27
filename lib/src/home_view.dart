import 'package:flutter/material.dart';
import 'dashboard/dashboard_view.dart';
import 'compte-rendus/views/compte_rendu_create_view.dart'; // Nouveau rapport
import 'compte-rendus/views/compte_rendus_view.dart'; // Mes comptes rendus
import 'menu/drawer.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Ajoutez ici les pages pour la navigation
  final List<Widget> _pages = [
    const DashboardView(), // Index 0 : Tableau de bord
    const CompteRenduCreateView(), // Index 1 : Nouveau rapport
    const CompteRendusView(), // Index 2 : Mes comptes rendus
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Row(
        children: [
          // Menu latéral fixe pour les grands écrans
          if (isDesktop)
            SizedBox(
              width: 250,
              child: AppDrawer(
                isPermanent: true,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          // Contenu principal
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      // Menu Drawer pour les petits écrans
      drawer: isDesktop
          ? null
          : AppDrawer(
              isPermanent: false,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
    );
  }
}
