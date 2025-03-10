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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Praticien ID: ${cr.praticien}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              cr.dateVisite.toIso8601String().split('T')[0],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Visiteur ID: ${cr.uuidVisiteur}'),
                        const SizedBox(height: 8),
                        const Text('Motif:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(cr.motif),
                        const SizedBox(height: 8),
                        const Text('Bilan:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(cr.bilan),
                        if (cr.medicaments != null &&
                            cr.medicaments!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Médicaments:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...cr.medicaments!.map((medicament) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 4.0),
                              child: Text(
                                  '- ${medicament['nom']} (Quantité: ${medicament['quantite']})'))),
                        ],
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
}
