import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Pour décoder le token JWT
import '../models/praticien_model.dart';
import '../services/compte_rendus_api_service.dart';
import '../models/compte_rendus_model.dart'; // Importez le modèle CompteRendu
import '../services/compte_rendus_service.dart'; // Importez le service CompteRendusService
import '../../auth/auth_service.dart'; // Importez AuthService

class CompteRenduCreateView extends StatefulWidget {
  const CompteRenduCreateView({super.key});

  @override
  State<CompteRenduCreateView> createState() => _CompteRenduCreateViewState();
}

class _CompteRenduCreateViewState extends State<CompteRenduCreateView> {
  final _formKey = GlobalKey<FormState>();
  final motifController = TextEditingController();
  final dateVisiteController = TextEditingController();
  final bilanController =
      TextEditingController(); // Contrôleur pour le champ bilan

  List<Praticien> praticiens = [];
  Praticien? selectedPraticien;
  bool _isLoading = true;
  final AuthService _authService = AuthService(); // Instance de AuthService

  @override
  void initState() {
    super.initState();
    _fetchPraticiens();
  }

  @override
  void dispose() {
    motifController.dispose();
    dateVisiteController.dispose();
    bilanController.dispose(); // Libérez le contrôleur
    super.dispose();
  }

  Future<void> _fetchPraticiens() async {
    try {
      final fetchedPraticiens =
          await CompteRendusApiService().fetchPraticiens();
      setState(() {
        praticiens = fetchedPraticiens;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<String?> getUuidVisiteur() async {
    final token = await _authService.getJwtToken(); // Récupérez le token JWT
    if (token == null) return null;

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['sub']; // Supposons que 'sub' contient l'uuid_visiteur
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final uuidVisiteur = await getUuidVisiteur(); // Récupérez l'uuid_visiteur
      if (uuidVisiteur == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Erreur : Impossible de récupérer l\'uuid_visiteur')),
        );
        return;
      }

      final compteRendu = CompteRendu(
        dateVisite:
            DateTime.parse(dateVisiteController.text), // Convertir en DateTime
        bilan:
            bilanController.text, // Utilisez la valeur saisie par l'utilisateur
        motif: motifController.text,
        praticien: selectedPraticien!.id, // Utilisez l'ID du praticien
        uuidVisiteur: uuidVisiteur, // Utilisez l'uuid_visiteur récupéré
        medicaments: [], // Optionnel : ajoutez des médicaments si nécessaire
      );

      try {
        await CompteRendusService().addCompteRendu(compteRendu);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte rendu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Praticien>(
                      decoration: const InputDecoration(labelText: 'Praticien'),
                      value: selectedPraticien,
                      items: praticiens.map((praticien) {
                        return DropdownMenuItem(
                          value: praticien,
                          child: Text('${praticien.nom} ${praticien.prenom}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPraticien = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Veuillez choisir un praticien'
                          : null,
                    ),
              TextFormField(
                controller: motifController,
                decoration: const InputDecoration(labelText: 'Motif'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: dateVisiteController,
                decoration: const InputDecoration(
                    labelText: 'Date de visite (YYYY-MM-DD)'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: bilanController, // Champ pour le bilan
                decoration: const InputDecoration(labelText: 'Bilan'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
