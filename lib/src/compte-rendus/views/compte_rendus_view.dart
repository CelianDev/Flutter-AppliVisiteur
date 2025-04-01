import 'package:flutter/material.dart';
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

class _CompteRendusViewState extends State<CompteRendusView> {
  late Future<List<CompteRendu>> _compteRendusFuture;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _compteRendusFuture = CompteRendusService().getAllCompteRendus();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'actualisation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes comptes rendus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshCompteRendus,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCompteRendus,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List<CompteRendu>>(
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
                  itemCount: compteRendus.length,
                  itemBuilder: (context, index) {
                    final cr = compteRendus[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showCompteRenduDetails(cr),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Praticien #${cr.praticien}',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _dateFormat.format(cr.dateVisite),
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            cr.medicaments?.length.toString() ?? '0',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 18,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Motif:',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            cr.motif,
                                            style: theme.textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.notes_outlined,
                                          size: 18,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bilan:',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 26.0, top: 4.0),
                                      child: Text(
                                        cr.bilan,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (cr.medicaments != null && cr.medicaments!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.medication_outlined,
                                            size: 18,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Médicaments:',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 26.0, top: 4.0),
                                        child: Wrap(
                                          spacing: 8,
                                          children: cr.medicaments!.map((medicament) => Chip(
                                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                            side: BorderSide.none,
                                            label: Text(
                                              '${medicament['nom']} (${medicament['quantite']})',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                            avatar: Icon(
                                              medicament['presenter'] == true 
                                                ? Icons.check_circle_outline
                                                : Icons.cancel_outlined,
                                              size: 16,
                                              color: medicament['presenter'] == true
                                                ? Colors.green
                                                : Colors.red,
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.2, end: 0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/compte-rendu/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Créer un compte rendu',
      ),
    );
  }
  
  // Affiche les détails d'un compte rendu dans une boîte de dialogue
  void _showCompteRenduDetails(CompteRendu cr) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Détails du compte rendu',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                    title: const Text('Date de visite'),
                    subtitle: Text(_dateFormat.format(cr.dateVisite)),
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: theme.colorScheme.primary),
                    title: const Text('Praticien'),
                    subtitle: Text('ID: ${cr.praticien}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.description, color: theme.colorScheme.primary),
                    title: const Text('Motif'),
                    subtitle: Text(cr.motif),
                  ),
                  ListTile(
                    leading: Icon(Icons.notes, color: theme.colorScheme.primary),
                    title: const Text('Bilan'),
                    subtitle: Text(cr.bilan),
                    isThreeLine: true,
                  ),
                  if (cr.medicaments != null && cr.medicaments!.isNotEmpty) ...[                    
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(
                        'Médicaments',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    ...cr.medicaments!.map((med) => ListTile(
                      leading: Icon(
                        med['presenter'] == true ? Icons.check_circle : Icons.cancel,
                        color: med['presenter'] == true ? Colors.green : Colors.red,
                      ),
                      title: Text(med['nom']),
                      subtitle: Text('Quantité: ${med["quantite"]}'),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          med['presenter'] == true ? 'Présenté' : 'Non présenté',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    )),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Widget pour afficher un état de chargement avec effet shimmer
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
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget pour afficher un message d'erreur
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshCompteRendus,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
  
  // Widget pour afficher un message quand la liste est vide
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 60,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun compte rendu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore créé de compte rendu',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/compte-rendu/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un compte rendu'),
          ),
        ],
      ),
    );
  }
}
