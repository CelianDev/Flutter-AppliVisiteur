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
    return map;
  }

  factory CompteRendu.fromMap(Map<String, dynamic> map) {
    return CompteRendu(
      dateVisite: DateTime.parse(map['date_visite']),
      praticien: map['praticien'],
      motif: map['motif'],
      bilan: map['bilan'],
      uuidVisiteur: map['uuid_visiteur'],
      medicaments: map['medicaments'] != null
          ? List<Map<String, dynamic>>.from(map['medicaments'])
          : null,
    );
  }
}
