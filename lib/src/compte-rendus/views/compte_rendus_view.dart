import 'package:flutter/material.dart';
import '../models/compte_rendus_model.dart';
import '../services/compte_rendus_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class CompteRendusView extends StatefulWidget {
  const CompteRendusView({super.key});

  @override
  State<CompteRendusView> createState() => _CompteRendusViewState();
}

class _CompteRendusViewState extends State<CompteRendusView> {
  late Future<List<CompteRendu>> _compteRendusFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _compteRendusFuture = userProvider.uuid != null
        ? CompteRendusService().getAllCompteRendus(userProvider.uuid!)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes comptes rendus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<CompteRendu>>(
          future: _compteRendusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun compte rendu disponible',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final compteRendus = snapshot.data!;
            return ListView.builder(
              itemCount: compteRendus.length,
              itemBuilder: (context, index) {
                final cr = compteRendus[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Motif avec la date à droite
                        _buildMotifSection(cr.motif, cr.dateVisite),
                        const Divider(height: 10),
                        // Section Praticien (affichage du premier élément de la liste)
                        if (cr.praticien != null && cr.praticien!.isNotEmpty)
                          _buildPraticienSection(cr.praticien!),
                        const Divider(height: 10),
                        // Section Bilan
                        _buildDetailSection('Bilan', cr.bilan),
                        // Section Médicaments
                        if (cr.medicaments != null &&
                            cr.medicaments!.isNotEmpty)
                          _buildMedicamentsSection(cr.medicaments!),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMotifSection(String motif, DateTime dateVisite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motif',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(motif),
              ],
            ),
          ),
          Text(
            '${dateVisite.day}/${dateVisite.month}/${dateVisite.year}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Extraction du premier élément de la liste pour afficher le praticien
  Widget _buildPraticienSection(Map<String, dynamic> praticienData) {
    final nom = praticienData['nom'] ?? '';
    final prenom = praticienData['prenom'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Praticien',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text('$prenom $nom'),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildMedicamentsSection(List<dynamic> medicaments) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Médicaments',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          // Liste des médicaments affichés en ligne (Wrap) : si ça déborde, ça passe à la ligne
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: medicaments.map((medicament) {
              final nom = medicament['nom_commercial'];
              final quantite = medicament['quantite'];
              final presenter = medicament['presenter'] ? 'Oui' : 'Non';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medication, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  Text(
                    '$nom (Quantité: $quantite, Présenté: $presenter)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
