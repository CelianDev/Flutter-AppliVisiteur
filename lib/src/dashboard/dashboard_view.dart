// dashboard_view.dart
import 'package:flutter/material.dart';
import 'dashboard_service.dart';
import '../menu/drawer.dart'; // Assurez-vous que le chemin est correct

class DashboardView extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Définir un point de rupture pour la largeur de l'écran
        bool isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          // Mode bureau : Drawer fixe à gauche et contenu à droite
          return Scaffold(
            body: Row(
              children: [
                const SizedBox(
                  width: 250,
                  child: AppDrawer(isPermanent: true),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Barre d'application personnalisée
                      Container(
                        height: kToolbarHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Text(
                          'Bienvenue, utilisateur!',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // Contenu principal du dashboard
                      Expanded(
                        child: _buildDashboardContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mode mobile : Scaffold avec Drawer
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bienvenue, utilisateur!'),
            ),
            drawer: const AppDrawer(),
            body: _buildDashboardContent(),
          );
        }
      },
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(8, (index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Action lors du tap sur la carte
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.widgets,
                    size: 48,
                    color: Color(0xFF2B547E),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Module ${index + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
