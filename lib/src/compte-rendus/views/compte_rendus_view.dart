import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../models/compte_rendus_model.dart';
import '../services/compte_rendus_service.dart';

class CompteRendusView extends StatefulWidget {
  const CompteRendusView({super.key});

  @override
  State<CompteRendusView> createState() => _CompteRendusViewState();
}

class _CompteRendusViewState extends State<CompteRendusView>
    with SingleTickerProviderStateMixin {
  late Future<List<CompteRenduList>> _compteRendusFuture;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showFloatingButton = true;

  @override
  void initState() {
    super.initState();
    _compteRendusFuture = CompteRendusService().getAllCompteRendus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFloatingButton) {
        setState(() {
          _showFloatingButton = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFloatingButton) {
        setState(() {
          _showFloatingButton = true;
        });
      }
    }
  }

  Future<void> _refreshCompteRendus() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final newData = await CompteRendusService().getAllCompteRendus();
      setState(() {
        _compteRendusFuture = Future.value(newData);
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      if (mounted) {
        _showErrorSnackBar('Erreur lors de l\'actualisation: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
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

  // Cette méthode sécurisée extrait le nom du praticien et gère les valeurs null
  String _getPraticienNom(Map<String, dynamic>? praticien,
      {Map<String, dynamic>? praticienInfo}) {
    // Si nous avons des informations complètes du praticien, utilisons-les en priorité
    if (praticienInfo != null) {
      final prenom = praticienInfo['prenom']?.toString() ?? '';
      final nom = praticienInfo['nom']?.toString() ?? '';
      final id = praticienInfo['id']?.toString() ?? '';

      print(
          'Utilisation des informations complètes du praticien - ID: $id, Nom: $nom, Prénom: $prenom');

      final nomComplet = '$prenom $nom'.trim();
      return nomComplet.isEmpty ? 'Praticien inconnu' : nomComplet;
    }

    // Sinon, utiliser les informations de base du praticien
    if (praticien == null) return 'Praticien inconnu';

    final prenom = praticien['prenom']?.toString() ?? '';
    final nom = praticien['nom']?.toString() ?? '';

    final nomComplet = '$prenom $nom'.trim();
    return nomComplet.isEmpty ? 'Praticien inconnu' : nomComplet;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Mes comptes rendus',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ).animate().fadeIn(duration: 600.ms),
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
        actions: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return IconButton(
                icon: _isRefreshing
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isRefreshing ? null : _refreshCompteRendus,
                tooltip: 'Actualiser',
              ).animate().scale(
                    duration: 300.ms,
                    curve: Curves.easeInOut,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                  );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Hero section with statistics
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 100, left: 16, right: 16, bottom: 8),
                  child: FutureBuilder<List<CompteRenduList>>(
                    future: _compteRendusFuture,
                    builder: (context, snapshot) {
                      // Only show stats when we have data
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final compteRendus = snapshot.data!;
                        final totalMedicaments = compteRendus.fold(
                          0,
                          (prev, cr) => prev + (cr.medicaments?.length ?? 0),
                        );

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Résumé',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      context,
                                      Icons.description_outlined,
                                      compteRendus.length.toString(),
                                      'Comptes rendus',
                                      colorScheme.primary,
                                    ),
                                    _buildStatItem(
                                      context,
                                      Icons.medication_outlined,
                                      totalMedicaments.toString(),
                                      'Médicaments',
                                      colorScheme.secondary,
                                    ),
                                    _buildStatItem(
                                      context,
                                      Icons.calendar_today_outlined,
                                      compteRendus.isNotEmpty
                                          ? _dateFormat.format(
                                              compteRendus.last.dateVisite)
                                          : 'Aucune',
                                      'Dernière visite',
                                      colorScheme.tertiary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms);
                      }
                      return const SizedBox(height: 0);
                    },
                  ),
                ),
              ),
            ],
            body: RefreshIndicator(
              onRefresh: _refreshCompteRendus,
              color: colorScheme.primary,
              backgroundColor: Colors.white,
              displacement: 40,
              edgeOffset: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<CompteRenduList>>(
                  future: _compteRendusFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingShimmer();
                    } else if (snapshot.hasError) {
                      return _buildErrorView(snapshot.error.toString());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyView();
                    }

                    final compteRendus = snapshot.data!;
                    return AnimationLimiter(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: compteRendus.length,
                        itemBuilder: (context, index) {
                          final cr = compteRendus[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildCompteRenduCard(cr, index, theme),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFloatingButton ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFloatingButton ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/compte-rendu/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Nouveau compte rendu'),
            elevation: 4,
            tooltip: 'Créer un compte rendu',
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 80,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompteRenduCard(CompteRenduList cr, int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    // Vérifier si nous avons des informations complètes du praticien
    Map<String, dynamic>? praticienInfo;
    if (cr.praticienInfo != null) {
      praticienInfo = Map<String, dynamic>.from(cr.praticienInfo!);
      print('Informations complètes du praticien disponibles: $praticienInfo');
    }

    final praticienNom =
        _getPraticienNom(cr.praticien, praticienInfo: praticienInfo);

    final hasMedPresentes = cr.medicaments != null &&
        cr.medicaments!.any((medicament) => medicament['presenter'] == true);
    final hasEchantillons = cr.medicaments != null &&
        cr.medicaments!.any((medicament) => medicament['quantite'] > 0);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showCompteRenduDetails(cr),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with practitioner info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Hero(
                          tag:
                              'practitioner-avatar-${cr.dateVisite.millisecondsSinceEpoch}',
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag:
                                    'practitioner-name-${cr.dateVisite.millisecondsSinceEpoch}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    praticienNom,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dateFormat.format(cr.dateVisite),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medication_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cr.medicaments?.length.toString() ?? '0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Motif and Bilan sections
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motif section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motif de visite',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cr.motif,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bilan section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notes_outlined,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bilan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cr.bilan,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Médicaments section
              if (cr.medicaments != null && cr.medicaments!.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Badges section for medicines
                Row(
                  children: [
                    if (hasMedPresentes)
                      _buildBadge(
                        'Médicaments présentés',
                        Icons.present_to_all,
                        colorScheme.primary,
                        theme,
                      ),
                    const SizedBox(width: 8),
                    if (hasEchantillons)
                      _buildBadge(
                        'Échantillons donnés',
                        Icons.medication_outlined,
                        colorScheme.secondary,
                        theme,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Medications grid view
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...cr.medicaments!.map((med) => _buildMedicamentChip(
                          med,
                          theme,
                          colorScheme,
                        )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBadge(String text, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentChip(Map<String, dynamic> medicament, ThemeData theme,
      ColorScheme colorScheme) {
    final isPresented = medicament['presenter'] == true;
    final hasQuantity = medicament['quantite'] > 0;

    // Assurez-vous que le nom est toujours une chaîne
    final String nom = medicament['nom']?.toString() ?? 'Médicament sans nom';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isPresented ? colorScheme.primary : colorScheme.secondary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (isPresented ? colorScheme.primary : colorScheme.secondary)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPresented
                ? Icons.check_circle_outline
                : Icons.medication_outlined,
            size: 16,
            color: isPresented ? Colors.green : colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            nom,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasQuantity) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${medicament['quantite']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Affiche les détails d'un compte rendu dans une boîte de dialogue améliorée
  void _showCompteRenduDetails(CompteRenduList cr) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Détails du compte rendu',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final praticienNom = _getPraticienNom(cr.praticien);

        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag:
                                  'practitioner-avatar-${cr.dateVisite.millisecondsSinceEpoch}',
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: colorScheme.primary,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag:
                                        'practitioner-name-${cr.dateVisite.millisecondsSinceEpoch}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        praticienNom,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _dateFormat.format(cr.dateVisite),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content with scrolling
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Motif de visite
                          _buildDetailSection(
                            title: 'Motif de visite',
                            icon: Icons.description_outlined,
                            color: colorScheme.primary,
                            content: cr.motif,
                            theme: theme,
                          ),

                          const SizedBox(height: 24),

                          // Bilan
                          _buildDetailSection(
                            title: 'Bilan',
                            icon: Icons.notes_outlined,
                            color: colorScheme.secondary,
                            content: cr.bilan,
                            theme: theme,
                          ),

                          if (cr.medicaments != null &&
                              cr.medicaments!.isNotEmpty) ...[
                            const SizedBox(height: 24),

                            // Médicaments présentés
                            _buildMedicamentsSection(
                              title: 'Médicaments présentés',
                              icon: Icons.present_to_all,
                              color: Colors.green,
                              medicaments: cr.medicaments!
                                  .where((med) => med['presenter'] == true)
                                  .toList(),
                              theme: theme,
                              emptyText:
                                  'Aucun médicament présenté lors de cette visite.',
                            ),

                            const SizedBox(height: 24),

                            // Échantillons fournis
                            _buildMedicamentsSection(
                              title: 'Échantillons fournis',
                              icon: Icons.medication_outlined,
                              color: colorScheme.secondary,
                              medicaments: cr.medicaments!
                                  .where((med) => med['quantite'] > 0)
                                  .toList(),
                              theme: theme,
                              showQuantity: true,
                              emptyText:
                                  'Aucun échantillon fourni lors de cette visite.',
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Footer with action buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Fermer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
              curve: Curves.easeOutBack,
            );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> medicaments,
    required ThemeData theme,
    bool showQuantity = false,
    required String emptyText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (medicaments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                emptyText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicaments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final med = medicaments[index];
                // S'assurer que le nom est une chaîne
                final String nom =
                    med['nom']?.toString() ?? 'Médicament sans nom';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.medication_outlined,
                            color: color,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nom,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (showQuantity && med['quantite'] > 0)
                              Text(
                                'Quantité: ${med['quantite']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (showQuantity && med['quantite'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${med['quantite']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Widget pour afficher un état de chargement amélioré avec effet shimmer
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour afficher un message d'erreur amélioré
  Widget _buildErrorView(String errorMessage) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colorScheme.error,
              ),
            ).animate().shake(duration: 700.ms, delay: 300.ms),
            const SizedBox(height: 20),
            Text(
              'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshCompteRendus,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  // Widget pour afficher un message amélioré quand la liste est vide
  Widget _buildEmptyView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                  delay: 300.ms,
                ),
            const SizedBox(height: 32),
            Text(
              'Aucun compte rendu',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 12),
            Text(
              'Vous n\'avez pas encore créé de compte rendu de visite médicale.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 700.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/compte-rendu/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer un compte rendu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 900.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
