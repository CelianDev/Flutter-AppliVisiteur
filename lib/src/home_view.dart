import 'package:flutter/material.dart';
import 'dashboard/dashboard_view.dart';
import 'compte-rendus/compte_rendus_view.dart';
import 'menu/drawer.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/';

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const CompteRendusView(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Row(
        children: [
          // Utilisation d'AppDrawer pour le menu fixe
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
