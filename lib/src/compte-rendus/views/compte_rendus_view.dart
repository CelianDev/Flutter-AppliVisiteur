import 'package:flutter/material.dart';
import '../models/compte_rendus_model.dart';
import '../services/compte_rendus_service.dart';

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
    _compteRendusFuture = CompteRendusService().getAllCompteRendus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes comptes rendus')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<CompteRendu>>(
          future: _compteRendusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Erreur: ${snapshot.error.toString()}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun compte rendu trouvé'));
            }

            final compteRendus = snapshot.data!;
            return ListView.builder(
              itemCount: compteRendus.length,
              itemBuilder: (context, index) {
                final cr = compteRendus[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      'Praticien ID: ${cr.praticien}', // Affichez l'ID du praticien
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Motif: ${cr.motif}'),
                        Text('Bilan: ${cr.bilan}'), // Affichez le bilan
                        // Text('Commentaire: ${cr.commentaire}'),
                        if (cr.medicaments != null &&
                            cr.medicaments!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Médicaments:'),
                              ...cr.medicaments!.map((medicament) {
                                return Text(
                                  '- ${medicament['nom']} (Quantité: ${medicament['quantite']})',
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                    trailing: Text(
                      'Date: ${cr.dateVisite.toIso8601String().split('T')[0]}', // Affichez uniquement la date
                      style: const TextStyle(color: Colors.grey),
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
}
