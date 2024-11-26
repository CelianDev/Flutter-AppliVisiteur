import 'package:flutter/material.dart';

class CompteRendusView extends StatefulWidget {
  const CompteRendusView({super.key});

  @override
  State<CompteRendusView> createState() => _CompteRendusViewState();
}

class _CompteRendusViewState extends State<CompteRendusView> {
  final List<Map<String, dynamic>> _compteRendus = []; // Liste de compte-rendus

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre supérieure avec un titre
        Container(
          height: kToolbarHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Compte-Rendus',
                style: TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showAddCompteRenduDialog();
                },
              ),
            ],
          ),
        ),
        // Contenu principal
        Expanded(
          child: _compteRendus.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun compte-rendu disponible.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _compteRendus.length,
                  itemBuilder: (context, index) {
                    final compteRendu = _compteRendus[index];
                    return ListTile(
                      title: Text(compteRendu['praticien']),
                      subtitle: Text(
                          'Motif : ${compteRendu['motif']} | Date : ${compteRendu['date']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _compteRendus.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Fonction pour afficher le dialogue d'ajout de compte-rendu
  void _showAddCompteRenduDialog() {
    final praticienController = TextEditingController();
    final motifController = TextEditingController();
    final commentaireController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Compte-Rendu'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: praticienController,
                  decoration: const InputDecoration(labelText: 'Praticien'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: motifController,
                  decoration: const InputDecoration(labelText: 'Motif'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: commentaireController,
                  decoration: const InputDecoration(labelText: 'Commentaire'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _compteRendus.add({
                    'praticien': praticienController.text,
                    'motif': motifController.text,
                    'commentaire': commentaireController.text,
                    'date': DateTime.now().toString(),
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
