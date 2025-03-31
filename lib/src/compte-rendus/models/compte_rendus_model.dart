class CompteRendu {
  final DateTime dateVisite; // Utilisez DateTime pour date_visite
  final String bilan;
  final String motif;
  final int praticien; // Utilisez un entier pour l'ID du praticien
  final String uuidVisiteur; // Utilisez String pour uuid_visiteur
  final List<Map<String, dynamic>>?
      medicaments; // Liste optionnelle de médicaments

  CompteRendu({
    required this.dateVisite,
    required this.bilan,
    required this.motif,
    required this.praticien,
    required this.uuidVisiteur,
    this.medicaments,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'date_visite': dateVisite.toIso8601String(), // Convertir en ISO 8601
      'praticien': praticien,
      'motif': motif,
      'bilan': bilan,
      'uuid_visiteur': uuidVisiteur,
      'medicaments': medicaments, // Inclure les médicaments si présents
    };
    print('Données envoyées: $map');
    return map;
  }

  factory CompteRendu.fromMap(Map<String, dynamic> map) {
    // Traitement des médicaments
    List<Map<String, dynamic>>? medicamentsList;
    if (map['medicaments'] != null) {
      medicamentsList = List<Map<String, dynamic>>.from(
        (map['medicaments'] as List).map((m) {
          // Vérifier si le médicament est déjà au bon format
          if (m is Map<String, dynamic>) {
            return m;
          }
          // Sinon, convertir en Map
          return {
            'id_medicament': m['id'] ?? m['id_medicament'],
            'nom': m['nom_commercial'] ?? m['nom'],
            'quantite': m['quantite'],
            'presenter': m['presenter'] ?? false,
          };
        }),
      );
    }

    return CompteRendu(
      dateVisite: DateTime.parse(map['date_visite']),
      praticien: map['praticien'] is Map ? map['praticien']['id'] : map['praticien'],
      motif: map['motif'],
      bilan: map['bilan'],
      uuidVisiteur: map['uuid_visiteur'],
      medicaments: medicamentsList,
    );
  }
}
