import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/praticien_model.dart';
import '../services/compte_rendus_api_service.dart';
import '../models/compte_rendus_model.dart';
import '../services/compte_rendus_service.dart';
import '../../auth/auth_service.dart';

class CompteRenduCreateWizard extends StatefulWidget {
  const CompteRenduCreateWizard({super.key});

  @override
  State<CompteRenduCreateWizard> createState() => _CompteRenduCreateWizardState();
}

class _CompteRenduCreateWizardState extends State<CompteRenduCreateWizard> {
  // Formulaire et contrôleurs
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final dateVisiteController = TextEditingController();
  final bilanController = TextEditingController();
  final autreMotifController = TextEditingController();
  final quantiteController = TextEditingController();

  // Données
  List<Praticien> praticiens = [];
  Praticien? selectedPraticien;
  bool _isLoading = true;
  int activeStep = 0;
  final AuthService _authService = AuthService();

  // Motifs de visite
  final List<String> motifs = [
    "Périodicité",
    "Nouveautés / Actualisations",
    "Remontage",
    "Demande du médecin",
    "Autre"
  ];

  // Sélections
  String? selectedMotif;
  bool isAutreMotif = false;
  List<Map<String, dynamic>> selectedMedicaments = [];
  List<Map<String, dynamic>> availableMedicaments = [];
  Map<String, dynamic>? selectedMedicament;
  bool isPresentedMedicament = true;

  @override
  void initState() {
    super.initState();
    _fetchPraticiens();
    _fetchMedicaments();
    // Initialiser la date de visite à aujourd'hui
    dateVisiteController.text = dateFormat.format(DateTime.now());
  }

  Future<void> _fetchPraticiens() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getJwtToken();
      if (token != null) {
        // Nous n'utilisons pas decodedToken pour l'instant
        // final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        // final String userId = decodedToken['sub'];
        
        final fetchedPraticiens = await CompteRendusApiService().fetchPraticiens();
        if (mounted) {
          setState(() {
            praticiens = fetchedPraticiens;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des praticiens : $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchMedicaments() async {
    try {
      final fetchedMedicaments = await CompteRendusApiService().fetchMedicaments();
      if (mounted) {
        setState(() {
          availableMedicaments = fetchedMedicaments;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des médicaments : $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
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
          'nom': selectedMedicament!['nom_commercial'] ?? selectedMedicament!['nom'],
          'quantite': int.parse(quantiteController.text),
          'presenter': isPresentedMedicament,
        });
        selectedMedicament = null;
        quantiteController.clear();
        isPresentedMedicament = true;
      });
    } else {
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
      
      setState(() => _isLoading = true);
      try {
        // Récupérer le token JWT
        final token = await _authService.getJwtToken();
        if (token == null) {
          throw Exception('Token invalide ou expiré');
        }
        
        // Décoder le token pour obtenir l'UUID de l'utilisateur
        final decodedToken = JwtDecoder.decode(token);
        final uuid = decodedToken['sub']; // 'sub' est généralement l'identifiant de l'utilisateur
        
        if (uuid == null) {
          throw Exception('Impossible de récupérer l\'UUID de l\'utilisateur');
        }
        
        final compteRendu = CompteRendu(
          dateVisite: dateFormat.parse(dateVisiteController.text),
          bilan: bilanController.text,
          motif: isAutreMotif ? autreMotifController.text : selectedMotif!,
          praticien: selectedPraticien!.specialite,
          uuidVisiteur: uuid,
          medicaments: selectedMedicaments,
        );
        
        // Envoyer le compte-rendu au serveur
        await CompteRendusService().addCompteRendu(compteRendu);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte-rendu créé avec succès')),
        );
        
        // Rediriger vers la page d'accueil
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la création du compte rendu : $e')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }
  
  // Widget pour afficher le contenu de l'étape en cours
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
  
  // Étape 1: Date de visite
  Widget _stepDateVisite() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date de la visite',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez la date à laquelle vous avez effectué la visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: dateVisiteController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date de visite',
                hintText: 'JJ/MM/AAAA',
                prefixIcon: Icon(Icons.calendar_today, color: theme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner une date';
                }
                return null;
              },
              onTap: () => _selectDate(context),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(),
          const SizedBox(height: 16),
          Text(
            'Note: La date ne peut pas être dans le futur.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  // Étape 2: Sélection du praticien
  Widget _stepPraticien() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélection du praticien',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
          const SizedBox(height: 8),
          Text(
            'Choisissez le praticien que vous avez visité',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(),
          const SizedBox(height: 24),
          if (praticiens.isEmpty && !_isLoading)
            Center(
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun praticien disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Veuillez ajouter des praticiens avant de créer un compte-rendu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<Praticien>(
                value: selectedPraticien,
                decoration: InputDecoration(
                  labelText: 'Praticien',
                  prefixIcon: Icon(Icons.person, color: theme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: praticiens.map((praticien) {
                  return DropdownMenuItem<Praticien>(
                    value: praticien,
                    child: Text(
                      '${praticien.nom} ${praticien.prenom} (${praticien.specialite})',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPraticien = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un praticien';
                  }
                  return null;
                },
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                dropdownColor: Colors.white,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(),
        ],
      ),
    );
  }

  // Étape 3: Motif de la visite
  Widget _stepMotif() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motif de la visite',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
          const SizedBox(height: 8),
          Text(
            'Indiquez la raison de votre visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedMotif,
              decoration: InputDecoration(
                labelText: 'Motif',
                prefixIcon: Icon(Icons.subject, color: theme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: motifs.map((motif) {
                return DropdownMenuItem<String>(
                  value: motif,
                  child: Text(motif, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMotif = value;
                  isAutreMotif = value == 'Autre';
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un motif';
                }
                return null;
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              dropdownColor: Colors.white,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(),
          if (isAutreMotif) ...[  
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: autreMotifController,
                decoration: InputDecoration(
                  labelText: 'Précisez le motif',
                  prefixIcon: Icon(Icons.edit, color: theme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (isAutreMotif && (value == null || value.isEmpty)) {
                    return 'Veuillez préciser le motif';
                  }
                  return null;
                },
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 600)).scale(),
          ],
        ],
      ),
    );
  }

  // Étape 4: Bilan de la visite
  Widget _stepBilan() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bilan de la visite',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
          const SizedBox(height: 8),
          Text(
            'Décrivez le déroulement et les résultats de votre visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: bilanController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Bilan',
                hintText: 'Décrivez votre visite...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Icon(Icons.description, color: theme.primaryColor),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir un bilan';
                } else if (value.length < 10) {
                  return 'Le bilan doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(),
          const SizedBox(height: 16),
          Text(
            'Conseil: Soyez précis et concis dans votre description pour faciliter le suivi.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  // Étape 5: Médicaments présentés
  Widget _stepMedicament() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Médicaments présentés',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
          const SizedBox(height: 8),
          Text(
            'Indiquez les médicaments que vous avez présentés lors de la visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideX(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedMedicament,
                    decoration: InputDecoration(
                      labelText: 'Médicament',
                      prefixIcon: Icon(Icons.medication, color: theme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: availableMedicaments.map((medicament) {
                      final nomMedicament = medicament['nom_commercial'] ?? medicament['nom'];
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: medicament,
                        child: Text(nomMedicament, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedicament = value;
                      });
                    },
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: quantiteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Qté',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: isPresentedMedicament,
                onChanged: (value) {
                  setState(() {
                    isPresentedMedicament = value!;
                  });
                },
                activeColor: theme.primaryColor,
              ),
              Text(
                'Médicament présenté',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: !isPresentedMedicament,
                onChanged: (value) {
                  setState(() {
                    isPresentedMedicament = !value!;
                  });
                },
                activeColor: theme.primaryColor,
              ),
              Text(
                'Médicament non présenté',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 700)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMedicament,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter ce médicament'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
          const SizedBox(height: 24),
          if (selectedMedicaments.isEmpty)
            Center(
              child: Text(
                'Aucun médicament ajouté',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 900))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Médicaments ajoutés:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...selectedMedicaments.map((med) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        med['presenter'] ? Icons.check_circle : Icons.cancel,
                        color: med['presenter'] ? Colors.green : Colors.red,
                      ),
                      title: Text(med['nom'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      subtitle: Text('Quantité: ${med['quantite']}', style: GoogleFonts.poppins()),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedMedicaments.remove(med);
                          });
                        },
                      ),
                    ),
                  );
                }),
              ],
            ).animate().fadeIn(duration: const Duration(milliseconds: 900)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer un compte rendu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: EasyStepper(
                        activeStep: activeStep,
                        lineStyle: const LineStyle(lineLength: 50),
                        stepShape: StepShape.circle,
                        stepBorderRadius: 15,
                        borderThickness: 2,
                        padding: const EdgeInsets.all(8),
                        stepRadius: 28,
                        finishedStepBorderColor: Theme.of(context).primaryColor,
                        finishedStepTextColor: Theme.of(context).primaryColor,
                        finishedStepBackgroundColor: Theme.of(context).primaryColor,
                        activeStepIconColor: Colors.white,
                        activeStepBorderColor: Theme.of(context).primaryColor,
                        activeStepBackgroundColor: Theme.of(context).primaryColor,
                        activeStepTextColor: Theme.of(context).primaryColor,
                        unreachedStepBackgroundColor: Colors.white,
                        unreachedStepBorderColor: Colors.grey.shade300,
                        unreachedStepIconColor: Colors.grey,
                        unreachedStepTextColor: Colors.grey,
                        steps: [
                          EasyStep(
                            customStep: Icon(
                              Icons.calendar_today,
                              color: activeStep >= 0 ? Colors.white : Colors.grey,
                            ),
                            customTitle: Text(
                              'Date',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          EasyStep(
                            customStep: Icon(
                              Icons.person,
                              color: activeStep >= 1 ? Colors.white : Colors.grey,
                            ),
                            customTitle: Text(
                              'Praticien',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          EasyStep(
                            customStep: Icon(
                              Icons.subject,
                              color: activeStep >= 2 ? Colors.white : Colors.grey,
                            ),
                            customTitle: Text(
                              'Motif',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          EasyStep(
                            customStep: Icon(
                              Icons.description,
                              color: activeStep >= 3 ? Colors.white : Colors.grey,
                            ),
                            customTitle: Text(
                              'Bilan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          EasyStep(
                            customStep: Icon(
                              Icons.medication,
                              color: activeStep >= 4 ? Colors.white : Colors.grey,
                            ),
                            customTitle: Text(
                              'Médicaments',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        onStepReached: (index) => setState(() => activeStep = index),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildStepContent().animate().fadeIn(duration: const Duration(milliseconds: 300)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (activeStep > 0)
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  activeStep--;
                                });
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Précédent'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          activeStep < 4
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        activeStep++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Suivant'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _submit,
                                  icon: _isLoading
                                      ? Container(
                                          width: 24,
                                          height: 24,
                                          padding: const EdgeInsets.all(2.0),
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Icon(Icons.check),
                                  label: const Text('Terminer'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
