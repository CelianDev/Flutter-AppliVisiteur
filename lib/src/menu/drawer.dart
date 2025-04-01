import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
      headerWidget = Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        height: 150,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    } else if (_userData != null) {
      headerWidget = Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _userData!['avatar'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            _userData!['avatar'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF66A2D3),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Color(0xFF66A2D3),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData!['username'] ?? 'Nom de l\'utilisateur',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData!['email'] ?? 'email@example.com',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    } else {
      // Aucune donnée utilisateur, afficher un message par défaut
      headerWidget = Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Utilisateur non connecté',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms);
    }

    final theme = Theme.of(context);
    final selectedIndex = widget.onDestinationSelected != null ? 0 : -1;
    
    // Liste des destinations de navigation
    final List<Map<String, dynamic>> navigationItems = [
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'label': 'Tableau de bord',
        'index': 0,
      },
      {
        'icon': Icons.note_add_outlined,
        'activeIcon': Icons.note_add,
        'label': 'Nouveau rapport',
        'index': 1,
      },
      {
        'icon': Icons.assignment_outlined,
        'activeIcon': Icons.assignment,
        'label': 'Mes comptes rendus',
        'index': 2,
      },
    ];
    
    // Construction des éléments de navigation
    List<Widget> buildNavigationItems() {
      return navigationItems.map((item) {
        final isSelected = selectedIndex == item['index'];
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                widget.onDestinationSelected?.call(item['index']);
                if (!widget.isPermanent) Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                    ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1)
                    : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? item['activeIcon'] : item['icon'],
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (100 * item['index']).ms).slideX(begin: -0.1, end: 0);
      }).toList();
    }
    
    // Widget pour le footer avec le bouton de déconnexion
    Widget buildFooter() {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _logout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: theme.colorScheme.error.withOpacity(0.8),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Déconnexion',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.error.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
    }
    
    return widget.isPermanent
        ? SizedBox(
            width: 250,
            child: Drawer(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              child: Column(
                children: [
                  headerWidget,
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'NAVIGATION',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      children: buildNavigationItems(),
                    ),
                  ),
                  buildFooter(),
                ],
              ),
            ),
          )
        : Drawer(
            backgroundColor: theme.colorScheme.surface,
            child: Column(
              children: [
                headerWidget,
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'NAVIGATION',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: buildNavigationItems(),
                  ),
                ),
                buildFooter(),
              ],
            ),
          );
  }
}
