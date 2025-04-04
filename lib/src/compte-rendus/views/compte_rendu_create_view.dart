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
  State<CompteRenduCreateWizard> createState() =>
      _CompteRenduCreateWizardState();
}

class _CompteRenduCreateWizardState extends State<CompteRenduCreateWizard>
    with SingleTickerProviderStateMixin {
  // Formulaire et contrôleurs
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final dateVisiteController = TextEditingController();
  final bilanController = TextEditingController();
  final autreMotifController = TextEditingController();
  final quantiteController = TextEditingController();
  final searchController = TextEditingController();

  // Contrôleur d'animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Données
  List<Praticien> praticiens = [];
  List<Praticien> filteredPraticiens = [];
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
  List<Map<String, dynamic>> filteredMedicaments = [];
  Map<String, dynamic>? selectedMedicament;
  bool isPresentedMedicament = true;
  bool hasSampleProvided = false;

  @override
  void initState() {
    super.initState();
    _fetchPraticiens();
    _fetchMedicaments();
    // Initialiser la date de visite à aujourd'hui
    dateVisiteController.text = dateFormat.format(DateTime.now());

    // Initialiser l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    dateVisiteController.dispose();
    bilanController.dispose();
    autreMotifController.dispose();
    quantiteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPraticiens() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getJwtToken();
      if (token != null) {
        final fetchedPraticiens =
            await CompteRendusApiService().fetchPraticiens();
        if (mounted) {
          setState(() {
            praticiens = fetchedPraticiens;
            filteredPraticiens = praticiens;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors du chargement des praticiens : $e',
            isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchMedicaments() async {
    try {
      final fetchedMedicaments =
          await CompteRendusApiService().fetchMedicaments();
      if (mounted) {
        setState(() {
          availableMedicaments = fetchedMedicaments;
          filteredMedicaments = availableMedicaments;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors du chargement des médicaments : $e',
            isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year - 2),
      lastDate: currentDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
            dialogBackgroundColor: Colors.white,
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

  // Convertir le code de spécialité en texte explicite
  String _getSpecialiteText(int specialiteCode) {
    switch (specialiteCode) {
      case 1:
        return 'Médecin généraliste';
      case 2:
        return 'Cardiologue';
      case 3:
        return 'Dermatologue';
      case 4:
        return 'Gastro-entérologue';
      case 5:
        return 'Neurologue';
      case 6:
        return 'Ophtalmologue';
      case 7:
        return 'ORL';
      case 8:
        return 'Pédiatre';
      case 9:
        return 'Psychiatre';
      case 10:
        return 'Radiologue';
      default:
        return 'Spécialité $specialiteCode';
    }
  }

  void _filterPraticiens(String query) {
    setState(() {
      filteredPraticiens = praticiens
          .where((praticien) =>
              '${praticien.nom} ${praticien.prenom}'
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              praticien.specialite
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterMedicaments(String query) {
    setState(() {
      filteredMedicaments = availableMedicaments.where((medicament) {
        final nom = medicament['nom_commercial'] ?? medicament['nom'] ?? '';
        return nom.toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _addMedicament() {
    if (selectedMedicament != null) {
      // Vérifier si un échantillon a été fourni
      final int quantite =
          hasSampleProvided && quantiteController.text.isNotEmpty
              ? int.parse(quantiteController.text)
              : 0;

      // S'assurer que le nom est une chaîne de caractères
      final String nomMedicament =
          selectedMedicament!['nom_commercial']?.toString() ??
              selectedMedicament!['nom']?.toString() ??
              'Médicament sans nom';

      setState(() {
        selectedMedicaments.add({
          'id_medicament': selectedMedicament!['id'],
          'nom': nomMedicament,
          'quantite': quantite,
          'presenter': isPresentedMedicament,
        });
        selectedMedicament = null;
        quantiteController.clear();
        isPresentedMedicament = true;
        hasSampleProvided = false;
      });

      _showSnackBar('Médicament ajouté avec succès');
    } else {
      _showSnackBar('Veuillez sélectionner un médicament', isError: true);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedPraticien == null) {
        _showSnackBar('Veuillez sélectionner un praticien', isError: true);
        return;
      }

      if (selectedMotif == null) {
        _showSnackBar('Veuillez sélectionner un motif', isError: true);
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
        final uuid = decodedToken[
            'sub']; // 'sub' est généralement l'identifiant de l'utilisateur

        if (uuid == null) {
          throw Exception('Impossible de récupérer l\'UUID de l\'utilisateur');
        }

        // Ajouter des logs pour déboguer l'ID du praticien
        print(
            'Praticien sélectionné - ID: ${selectedPraticien!.id}, Nom: ${selectedPraticien!.nom} ${selectedPraticien!.prenom}, Spécialité: ${selectedPraticien!.specialite}');

        // Le problème est que nous devons envoyer la spécialité comme valeur pour le champ 'praticien'
        // mais nous voulons aussi stocker l'ID du praticien pour l'afficher correctement
        print(
            'Utilisation de la spécialité du praticien (${selectedPraticien!.specialite}) comme valeur pour le champ praticien');
        print(
            'Sauvegarde de l\'ID du praticien (${selectedPraticien!.id}) et son nom (${selectedPraticien!.nom} ${selectedPraticien!.prenom}) dans un champ séparé');

        // Créer un objet contenant les informations complètes du praticien
        final praticienInfo = {
          'id': selectedPraticien!.id,
          'nom': selectedPraticien!.nom,
          'prenom': selectedPraticien!.prenom,
          'specialite': selectedPraticien!.specialite,
        };

        final compteRendu = CompteRendu(
          dateVisite: dateFormat.parse(dateVisiteController.text),
          bilan: bilanController.text,
          motif: isAutreMotif ? autreMotifController.text : selectedMotif!,
          praticien: selectedPraticien!
              .specialite, // Utiliser la spécialité comme valeur pour le champ praticien
          praticienInfo:
              praticienInfo, // Stocker les informations complètes du praticien
          uuidVisiteur: uuid,
          medicaments: selectedMedicaments,
        );

        // Vérifier les données du compte-rendu avant envoi
        print('Données du compte-rendu à envoyer:');
        print('- Date visite: ${dateFormat.parse(dateVisiteController.text)}');
        print('- Praticien ID: ${selectedPraticien!.id}');
        print(
            '- Motif: ${isAutreMotif ? autreMotifController.text : selectedMotif!}');
        print('- Médicaments: $selectedMedicaments');

        // Envoyer le compte-rendu au serveur
        await CompteRendusService().addCompteRendu(compteRendu);

        _showSnackBar('Compte-rendu créé avec succès');

        // Rediriger vers la page "Mes comptes-rendus"
        if (!mounted) return;
        await Future.delayed(const Duration(
            milliseconds: 800)); // Attendre que le SnackBar apparaisse

        // Naviguer vers la page "Mes comptes-rendus" au lieu de simplement revenir en arrière
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mes-comptes-rendus', // Route correcte vers la page des comptes-rendus
          (route) => route
              .isFirst, // Conserver uniquement la première route (page d'accueil)
        );
      } catch (e) {
        if (mounted) {
          _showSnackBar('Erreur lors de la création du compte rendu : $e',
              isError: true);
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
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description
          Text(
            'Date de la visite',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(),
          const SizedBox(height: 12),
          Text(
            'Sélectionnez la date à laquelle vous avez effectué la visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideX(),
          const SizedBox(height: 32),

          // Widget de calendrier amélioré
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date de visite',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateVisiteController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_calendar,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 500))
              .scale(),

          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber[800],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La date ne peut pas être dans le futur. Seules les visites déjà effectuées peuvent être enregistrées.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  // Étape 2: Sélection du praticien
  Widget _stepPraticien() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description
          Text(
            'Sélection du praticien',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(),
          const SizedBox(height: 12),
          Text(
            'Choisissez le praticien que vous avez visité',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideX(),
          const SizedBox(height: 32),

          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un praticien...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: _filterPraticiens,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

          const SizedBox(height: 24),

          // Liste de praticiens
          if (filteredPraticiens.isEmpty && !_isLoading)
            _buildEmptyPraticiens()
          else
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: filteredPraticiens.length,
                itemBuilder: (context, index) {
                  final praticien = filteredPraticiens[index];
                  final isSelected = selectedPraticien?.id == praticien.id;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.white,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedPraticien = praticien;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${praticien.prenom} ${praticien.nom}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: colorScheme.primary
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          'ID: ${praticien.id}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: colorScheme.secondary
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          // Convertir la spécialité en texte plus explicite
                                          'Spécialité: ${_getSpecialiteText(praticien.specialite)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                      );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPraticiens() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person_off,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun praticien disponible',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  // Étape 3: Motif de la visite
  Widget _stepMotif() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description
          Text(
            'Motif de la visite',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(),
          const SizedBox(height: 12),
          Text(
            'Indiquez la raison de votre visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideX(),
          const SizedBox(height: 32),

          // Liste des motifs
          ...motifs.map((motif) {
            final isSelected = selectedMotif == motif;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.grey.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : Colors.white,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedMotif = motif;
                    isAutreMotif = motif == 'Autre';
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMotifIcon(motif),
                          color:
                              isSelected ? Colors.white : colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          motif,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(
                  duration: Duration(
                      milliseconds: 300 + (motifs.indexOf(motif) * 100)),
                );
          }).toList(),

          // Si "Autre" est sélectionné, afficher le champ de texte
          if (isAutreMotif) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: autreMotifController,
                decoration: InputDecoration(
                  labelText: 'Précisez le motif',
                  hintText: 'Décrivez votre motif de visite...',
                  prefixIcon: Icon(Icons.edit_note, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (isAutreMotif && (value == null || value.isEmpty)) {
                    return 'Veuillez préciser le motif';
                  }
                  return null;
                },
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
          ],
        ],
      ),
    );
  }

  IconData _getMotifIcon(String motif) {
    switch (motif) {
      case 'Périodicité':
        return Icons.repeat;
      case 'Nouveautés / Actualisations':
        return Icons.new_releases;
      case 'Remontage':
        return Icons.upgrade;
      case 'Demande du médecin':
        return Icons.person_search;
      case 'Autre':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  // Étape 4: Bilan de la visite
  Widget _stepBilan() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description
          Text(
            'Bilan de la visite',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(),
          const SizedBox(height: 12),
          Text(
            'Décrivez le déroulement et les résultats de votre visite',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideX(),
          const SizedBox(height: 32),

          // Zone de texte pour le bilan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: bilanController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Bilan',
                hintText: 'Décrivez votre visite en détail...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
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
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 500))
              .scale(),

          const SizedBox(height: 24),

          // Conseils
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Conseils pour un bon bilan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBulletPoint(
                    'Soyez précis et concis dans votre description'),
                _buildBulletPoint(
                    'Indiquez les points importants abordés lors de la visite'),
                _buildBulletPoint(
                    'Mentionnez les questions ou préoccupations du praticien'),
                _buildBulletPoint(
                    'Notez les actions à suivre ou sujets à aborder lors de la prochaine visite'),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u2022',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Étape 5: Médicaments présentés
  Widget _stepMedicament() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et description
          Text(
            'Médicaments présentés',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(),
          const SizedBox(height: 12),
          Text(
            'Indiquez les médicaments présentés et les échantillons fournis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideX(),
          const SizedBox(height: 24),

          // Barre de recherche de médicaments
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Rechercher un médicament...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: _filterMedicaments,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),

          const SizedBox(height: 24),

          // Liste déroulante des médicaments
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedMedicament,
              decoration: InputDecoration(
                labelText: 'Sélectionner un médicament',
                prefixIcon: Icon(Icons.medication, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: filteredMedicaments.map((medicament) {
                final nomMedicament =
                    medicament['nom_commercial']?.toString() ??
                        medicament['nom']?.toString() ??
                        'Sans nom';
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: medicament,
                  child: Text(
                    nomMedicament,
                    style: GoogleFonts.poppins(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedicament = value;
                });
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              dropdownColor: Colors.white,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),

          const SizedBox(height: 24),

          // Options pour le médicament
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Options',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Présentation du médicament
                _buildOptionTile(
                  title: 'Médicament présenté',
                  subtitle: 'Le médicament a été présenté lors de la visite',
                  icon: Icons.present_to_all,
                  color: Colors.green,
                  isSelected: isPresentedMedicament,
                  onTap: () {
                    setState(() {
                      isPresentedMedicament = true;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _buildOptionTile(
                  title: 'Médicament non présenté',
                  subtitle:
                      'Le médicament n\'a pas été présenté lors de la visite',
                  icon: Icons.cancel_presentation,
                  color: Colors.red,
                  isSelected: !isPresentedMedicament,
                  onTap: () {
                    setState(() {
                      isPresentedMedicament = false;
                    });
                  },
                ),

                const Divider(height: 32),

                // Échantillon fourni
                _buildOptionTile(
                  title: 'Échantillon fourni',
                  subtitle: 'Un échantillon a été fourni au praticien',
                  icon: Icons.inventory_2,
                  color: colorScheme.secondary,
                  isSelected: hasSampleProvided,
                  onTap: () {
                    setState(() {
                      hasSampleProvided = !hasSampleProvided;
                    });
                  },
                ),

                // Champ quantité (affiché uniquement si échantillon fourni)
                if (hasSampleProvided)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: quantiteController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantité d\'échantillons',
                        prefixIcon: Icon(Icons.inventory_2,
                            color: colorScheme.secondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (hasSampleProvided &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez indiquer une quantité';
                        }
                        return null;
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 300)),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 700)),

          const SizedBox(height: 24),

          // Bouton d'ajout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedMedicament != null ? _addMedicament : null,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter ce médicament'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                disabledForegroundColor: Colors.white70,
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 800)),

          const SizedBox(height: 32),

          // Liste des médicaments ajoutés
          if (selectedMedicaments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Médicaments ajoutés (${selectedMedicaments.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...selectedMedicaments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final med = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: med['presenter'] == true
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              med['presenter'] == true
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: med['presenter'] == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['nom']?.toString() ?? 'Sans nom',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      med['presenter'] == true
                                          ? 'Présenté'
                                          : 'Non présenté',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: med['presenter'] == true
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (med['quantite'] > 0) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inventory_2,
                                              size: 14,
                                              color: colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${med['quantite']} échantillon${med['quantite'] > 1 ? 's' : ''}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedMedicaments.removeAt(index);
                              });
                            },
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                          duration: Duration(milliseconds: 300 + (index * 100)))
                      .slideY(begin: 0.2, end: 0);
                }).toList(),
              ],
            ).animate().fadeIn(duration: const Duration(milliseconds: 900))
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun médicament ajouté',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez un médicament et ajoutez-le à la liste',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 900)),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer un compte rendu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.8),
                colorScheme.primary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Quitter sans sauvegarder ?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Toutes les données saisies seront perdues. Êtes-vous sûr de vouloir quitter ?',
                  style: GoogleFonts.poppins(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fermer la boîte de dialogue
                      Navigator.pop(context); // Quitter l'écran
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Quitter',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
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
                        lineStyle: const LineStyle(
                          lineLength: 50,
                          lineType: LineType.normal,
                          activeLineColor: Colors.blue,
                          unreachedLineColor: Colors.grey,
                        ),
                        stepShape: StepShape.circle,
                        stepBorderRadius: 15,
                        borderThickness: 2,
                        padding: const EdgeInsets.all(10),
                        stepRadius: 28,
                        finishedStepBorderColor: colorScheme.primary,
                        finishedStepTextColor: colorScheme.primary,
                        finishedStepBackgroundColor: colorScheme.primary,
                        activeStepIconColor: Colors.white,
                        activeStepBorderColor: colorScheme.primary,
                        activeStepBackgroundColor: colorScheme.primary,
                        activeStepTextColor: colorScheme.primary,
                        loadingAnimation: 'loading',
                        unreachedStepBackgroundColor: Colors.white,
                        unreachedStepBorderColor: Colors.grey.shade300,
                        unreachedStepIconColor: Colors.grey,
                        unreachedStepTextColor: Colors.grey,
                        showLoadingAnimation: false,
                        steps: [
                          EasyStep(
                            customStep: Icon(
                              Icons.calendar_today,
                              color:
                                  activeStep >= 0 ? Colors.white : Colors.grey,
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
                              color:
                                  activeStep >= 1 ? Colors.white : Colors.grey,
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
                              color:
                                  activeStep >= 2 ? Colors.white : Colors.grey,
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
                              color:
                                  activeStep >= 3 ? Colors.white : Colors.grey,
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
                              color:
                                  activeStep >= 4 ? Colors.white : Colors.grey,
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
                        onStepReached: (index) {
                          if (_formKey.currentState!.validate()) {
                            setState(() => activeStep = index);
                            _animationController.reset();
                            _animationController.forward();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FadeTransition(
                          opacity: _animation,
                          child: _buildStepContent(),
                        ),
                      ),
                    ),
                    // Boutons de navigation
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bouton Précédent
                          if (activeStep > 0)
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    activeStep--;
                                  });
                                  _animationController.reset();
                                  _animationController.forward();
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Précédent'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(color: colorScheme.primary),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Spacer(flex: 1),

                          const SizedBox(width: 16),

                          // Bouton Suivant ou Terminer
                          Expanded(
                            flex: 2,
                            child: activeStep < 4
                                ? ElevatedButton.icon(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          activeStep++;
                                        });
                                        _animationController.reset();
                                        _animationController.forward();
                                      }
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Suivant'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _submit,
                                    icon: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    label: Text(_isLoading
                                        ? 'Création en cours...'
                                        : 'Terminer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
