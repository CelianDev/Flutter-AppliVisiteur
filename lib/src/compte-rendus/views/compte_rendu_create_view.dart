import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:intl/intl.dart';
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

  void _addMedicament() {
    if (selectedMedicament != null && quantiteController.text.isNotEmpty) {
      setState(() {
        selectedMedicaments.add({
          'id_medicament': selectedMedicament!['id'],
          'nom': selectedMedicament!['nom'],
          'quantite': int.parse(quantiteController.text),
        });
        selectedMedicament = null;
        quantiteController.clear();
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final compteRenduSubmission = CompteRenduSubmission(
        dateVisite: dateFormat.parse(dateVisiteController.text),
        bilan: bilanController.text,
        motif: isAutreMotif ? autreMotifController.text : selectedMotif!,
        praticien: selectedPraticien!.id,
        uuidVisiteur: "test_uuid", // Remplacer par l'UUID réel
        medicaments: selectedMedicaments,
      );
      Navigator.pop(context);
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
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(16.0), // Ajoute un padding autour du bouton
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Créer le compte rendu'),
          ),
        ),
      ],
    );
  }
}
