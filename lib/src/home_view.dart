import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const DashboardView(),
    const CompteRenduCreateWizard(),
    const CompteRendusView(),
  ];

  final List<String> _pageTitles = [
    'Tableau de bord',
    'Nouveau compte rendu',
    'Mes comptes rendus',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupérer l'index de l'onglet à afficher depuis les arguments de navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int) {
      int newIndex = args.clamp(0, _pages.length - 1);
      if (newIndex != _selectedIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index.clamp(0, _pages.length - 1);
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(
                _pageTitles[_selectedIndex],
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Implémenter la fonctionnalité de notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Notifications: Fonctionnalité à venir')),
                    );
                  },
                  tooltip: 'Notifications',
                ),
              ],
            ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'GSB',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Appli-Visiteur',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: AppDrawer(
                      isPermanent: true,
                      onDestinationSelected: _onDestinationSelected,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _pages.length > _selectedIndex
                  ? FadeTransition(
                      key: ValueKey<int>(_selectedIndex),
                      opacity: _animationController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: _pages[_selectedIndex],
                      ),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : AppDrawer(
              isPermanent: false,
              onDestinationSelected: _onDestinationSelected,
            ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: 'Tableau de bord',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.add_circle_outline),
                  selectedIcon: const Icon(Icons.add_circle),
                  label: 'Nouveau CR',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  selectedIcon: const Icon(Icons.assignment),
                  label: 'Mes CRs',
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 1, end: 0),
    );
  }
}
