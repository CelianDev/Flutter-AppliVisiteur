import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/praticien_model.dart';
import '../services/compte_rendus_api_service.dart';
import '../models/compte_rendus_model.dart';
import '../services/compte_rendus_service.dart';
import '../../auth/auth_service.dart';

class CompteRenduCreateWizard extends StatefulWidget {
  const CompteRenduCreateWizard({super.key});

  @override
  State<CompteRenduCreateWizard> createState() =>
      _CompteRenduCreateWizardState();
}

class _CompteRenduCreateWizardState extends State<CompteRenduCreateWizard> {
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final dateVisiteController = TextEditingController();
  final bilanController = TextEditingController();
  final autreMotifController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();

  List<Praticien> praticiens = [];
  Praticien? selectedPraticien;
  bool _isLoading = true;
  int activeStep = 0;
  final AuthService _authService = AuthService();

  final List<String> motifs = [
    "Périodicité",
    "Nouveautés / Actualisations",
    "Remontage",
    "Demande du médecin",
    "Autre"
  ];

  String? selectedMotif;
  bool isAutreMotif = false;
  List<Map<String, dynamic>> selectedMedicaments = [];
  List<Map<String, dynamic>> availableMedicaments = [];
  Map<String, dynamic>? selectedMedicament;

  @override
  void initState() {
    super.initState();
    _fetchPraticiens();
    _fetchMedicaments();
    dateVisiteController.text = dateFormat.format(DateTime.now());
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

  Future<void> _fetchMedicaments() async {
    try {
      final fetchedMedicaments =
          await CompteRendusApiService().fetchMedicaments();
      setState(() {
        availableMedicaments = fetchedMedicaments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des médicaments : $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        dateVisiteController.text = dateFormat.format(picked);
      });
    }
  }

  // Variable pour suivre si le médicament a été présenté
  bool isPresentedMedicament = true;

  void _addMedicament() {
    if (selectedMedicament != null && quantiteController.text.isNotEmpty) {
      setState(() {
        selectedMedicaments.add({
          'id_medicament': selectedMedicament!['id'],
          'nom': selectedMedicament!['nom_commercial'] ?? selectedMedicament!['nom'],
          'quantite': int.parse(quantiteController.text),
          'presenter': isPresentedMedicament,
        });
        selectedMedicament = null;
        quantiteController.clear();
        isPresentedMedicament = true; // Réinitialiser pour le prochain médicament
      });
    } else {
      // Afficher un message d'erreur si les champs ne sont pas remplis
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médicament et indiquer une quantité')),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedPraticien == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un praticien')),
        );
        return;
      }
      
      if (selectedMotif == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un motif')),
        );
        return;
      }
      
      if (bilanController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez saisir un bilan')),
        );
        return;
      }
      
      try {
        setState(() => _isLoading = true);
        
        // Récupérer le token JWT
        final token = await _authService.getJwtToken();
        if (token == null || await _authService.isTokenExpired()) {
          throw Exception('Token invalide ou expiré');
        }
        
        // Décoder le token pour obtenir l'UUID de l'utilisateur
        final decodedToken = JwtDecoder.decode(token);
        final uuid = decodedToken['sub']; // 'sub' est généralement l'identifiant de l'utilisateur
        
        if (uuid == null) {
          throw Exception('Impossible de récupérer l\'UUID de l\'utilisateur');
        }
        
        // Préparer les médicaments au format attendu par l'API
        final formattedMedicaments = selectedMedicaments.map((med) => {
          'id_medicament': med['id_medicament'],
          'quantite': med['quantite'],
          'presenter': med['presenter'],
        }).toList();
        
        final compteRendu = CompteRendu(
          dateVisite: dateFormat.parse(dateVisiteController.text),
          bilan: bilanController.text,
          motif: isAutreMotif ? autreMotifController.text : selectedMotif!,
          praticien: selectedPraticien!.specialite, // Utiliser la spécialité du praticien au lieu de son ID
          uuidVisiteur: uuid,
          medicaments: formattedMedicaments,
        );
        
        // Afficher les données envoyées pour débogage
        print('Données envoyées au serveur: ${compteRendu.toMap()}');
        
        // Envoyer le compte-rendu au serveur
        await CompteRendusService().addCompteRendu(compteRendu);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte-rendu créé avec succès')),
        );
        
        // Rediriger vers la page d'accueil
        if (!mounted) return;
        
        // Utiliser une approche plus simple: naviguer vers la page d'accueil
        // et utiliser un argument pour indiquer quel onglet afficher
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Route vers la page d'accueil
          (route) => false, // Supprime toutes les routes précédentes de la pile
          arguments: 2, // Index de CompteRendusView
        );
      } catch (e) {
        print('Erreur lors de la création du compte-rendu: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte rendu')),
      body: Column(
        children: [
          EasyStepper(
            activeStep: activeStep,
            steps: const [
              EasyStep(
                  icon: Icon(Icons.calendar_today), title: 'Date de visite'),
              EasyStep(icon: Icon(Icons.person), title: 'Praticien'),
              EasyStep(icon: Icon(Icons.note), title: 'Motif'),
              EasyStep(icon: Icon(Icons.description), title: 'Bilan'),
              EasyStep(icon: Icon(Icons.medical_services), title: 'Médicament'),
            ],
            onStepReached: (index) {
              setState(() {
                activeStep = index;
              });
            },
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (activeStep) {
      case 0:
        return _stepDateVisite();
      case 1:
        return _stepPraticien();
      case 2:
        return _stepMotif();
      case 3:
        return _stepBilan();
      case 4:
        return _stepMedicament();
      default:
        return Container();
    }
  }

  Widget _stepDateVisite() {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(16.0), // Ajoute un padding autour du champ
          child: TextFormField(
            controller: dateVisiteController,
            decoration: InputDecoration(
              labelText: 'Date de visite',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Ajoute du padding interne
            ),
            readOnly: true,
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => activeStep++),
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _stepPraticien() {
    return Column(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Padding(
            padding:
                const EdgeInsets.all(16.0), // Ajoute un padding autour du champ
            child: DropdownButtonFormField<Praticien>(
              decoration: const InputDecoration(
                labelText: 'Praticien',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0), // Ajoute du padding interne
              ),
              value: selectedPraticien,
              items: praticiens.map((praticien) {
                return DropdownMenuItem(
                  value: praticien,
                  child: Text(praticien.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPraticien = value;
                });
              },
            ),
          ),
        ElevatedButton(
          onPressed: () => setState(() => activeStep++),
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _stepMotif() {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(16.0), // Ajoute un padding autour du champ
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Motif',
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Ajoute du padding interne
            ),
            value: selectedMotif,
            items: motifs.map((motif) {
              return DropdownMenuItem(value: motif, child: Text(motif));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMotif = value;
                isAutreMotif = value == 'Autre';
              });
            },
          ),
        ),
        if (isAutreMotif)
          Padding(
            padding:
                const EdgeInsets.all(16.0), // Ajoute un padding autour du champ
            child: TextFormField(
              controller: autreMotifController,
              decoration: const InputDecoration(
                labelText: 'Précisez votre motif',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0), // Ajoute du padding interne
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () => setState(() => activeStep++),
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _stepBilan() {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(16.0), // Ajoute un padding autour du champ
          child: TextFormField(
            controller: bilanController,
            decoration: const InputDecoration(
              labelText: 'Bilan',
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Ajoute du padding interne
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => activeStep++),
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  Widget _stepMedicament() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de l'étape
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ajouter des médicaments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Sélection du médicament
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: 'Sélectionner un médicament',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),
              value: selectedMedicament,
              items: availableMedicaments.map((medicament) {
                return DropdownMenuItem(
                  value: medicament,
                  child: Text(medicament['nom_commercial'] ?? 'Médicament sans nom'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedicament = value;
                });
              },
              isExpanded: true,
            ),
          ),
          
          // Saisie de la quantité
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: quantiteController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          
          // Option pour indiquer si le médicament a été présenté
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Médicament présenté au praticien ?', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isPresentedMedicament,
                      onChanged: (value) {
                        setState(() {
                          isPresentedMedicament = value!;
                        });
                      },
                    ),
                    const Text('Oui'),
                  ],
                ),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isPresentedMedicament,
                      onChanged: (value) {
                        setState(() {
                          isPresentedMedicament = value!;
                        });
                      },
                    ),
                    const Text('Non'),
                  ],
                ),
              ],
            ),
          ),
          
          // Bouton pour ajouter le médicament à la liste
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _addMedicament,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter ce médicament'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Liste des médicaments sélectionnés
          if (selectedMedicaments.isNotEmpty) ...[  
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Médicaments sélectionnés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedMedicaments.length,
              itemBuilder: (context, index) {
                final med = selectedMedicaments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.medication, color: Colors.blue),
                    title: Text(med['nom']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantité: ${med['quantite']}'),
                        Text('Présenté: ${med['presenter'] ? 'Oui' : 'Non'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedMedicaments.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Bouton pour soumettre le formulaire
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Créer le compte rendu'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
