import 'package:flutter/material.dart';
import 'dashboard/dashboard_view.dart';
import 'compte-rendus/views/compte_rendu_create_view.dart';
import 'compte-rendus/views/compte_rendus_view.dart';
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
    const CompteRenduCreateWizard(),
    const CompteRendusView(),
  ];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupérer l'index de l'onglet à afficher depuis les arguments de navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int) {
      setState(() {
        _selectedIndex = args.clamp(0, _pages.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      backgroundColor: Colors.white, // Arrière-plan blanc par défaut
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: AppDrawer(
                isPermanent: true,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index.clamp(0, _pages.length - 1);
                  });
                },
              ),
            ),
          Expanded(
            child: _pages.length > _selectedIndex
                ? _pages[_selectedIndex]
                : Container(),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : AppDrawer(
              isPermanent: false,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index.clamp(0, _pages.length - 1);
                });
              },
            ),
    );
  }
}
