import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre supérieure avec un titre
        Container(
          height: kToolbarHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text(
            'Bienvenue, utilisateur!',
            style: TextStyle(fontSize: 20),
          ),
        ),
        // Contenu principal
        Expanded(
          child: Padding(
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
                      // Action lors du clic sur une carte
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Module ${index + 1} sélectionné'),
                      ));
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
          ),
        ),
      ],
    );
  }
}
