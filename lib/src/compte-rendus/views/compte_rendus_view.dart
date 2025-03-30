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
        title: const Text('Mes comptes rendus',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Text('Erreur: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Aucun compte rendu disponible',
                      style: TextStyle(fontSize: 16)));
            }

            final compteRendus = snapshot.data!;
            return ListView.builder(
              itemCount: compteRendus.length,
              itemBuilder: (context, index) {
                final cr = compteRendus[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Motif avec la date à droite
                        _buildMotifSection(cr.motif, cr.dateVisite),
                        const Divider(height: 10),
                        _buildDetailSection('Bilan', cr.bilan),
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
                const Text('Motif',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.blueAccent)),
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

  Widget _buildDetailSection(String title, String content) => Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.blueAccent)),
            const SizedBox(height: 4),
            Text(content),
          ],
        ),
      );

  Widget _buildMedicamentsSection(List<dynamic> medicaments) => Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Médicaments',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.blueAccent)),
            const SizedBox(height: 4),
            ...medicaments.map((medicament) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.medication, color: Colors.blueAccent),
                  title: Text(medicament['nom_commercial'],
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      'Quantité: ${medicament['quantite']} | Présenté: ${medicament['presenter'] ? "Oui" : "Non"}'),
                )),
          ],
        ),
      );
}
