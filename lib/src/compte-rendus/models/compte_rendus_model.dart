class CompteRendu {
  final DateTime dateVisite; // Utilisez DateTime pour date_visite
  final String bilan;
  final String motif;
  final int praticien; // Utilisez un entier pour l'ID du praticien ou la spécialité
  final Map<String, dynamic>? praticienInfo; // Informations complètes du praticien
  final String uuidVisiteur; // Utilisez String pour uuid_visiteur
  final List<Map<String, dynamic>>?
      medicaments; // Liste optionnelle de médicaments

  CompteRendu({
    required this.dateVisite,
    required this.bilan,
    required this.motif,
    required this.praticien,
    required this.uuidVisiteur,
    this.praticienInfo, // Nouveau paramètre optionnel
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
    
    // Ajouter les informations du praticien si disponibles
    if (praticienInfo != null) {
      map['praticien_info'] = praticienInfo;
    }
    
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
      praticien:
          map['praticien'] is Map ? map['praticien']['id'] : map['praticien'],
      motif: map['motif'],
      bilan: map['bilan'],
      uuidVisiteur: map['uuid_visiteur'],
      medicaments: medicamentsList,
    );
  }
}

class CompteRenduList {
  final DateTime dateVisite; // Utilisez DateTime pour date_visite
  final String bilan;
  final String motif;
  final Map<String, dynamic>? praticien; // Informations de base du praticien
  final Map<String, dynamic>? praticienInfo; // Informations complètes du praticien
  final String uuidVisiteur; // Utilisez String pour uuid_visiteur
  final List<Map<String, dynamic>>?
      medicaments; // Liste optionnelle de médicaments

  CompteRenduList({
    required this.dateVisite,
    required this.bilan,
    required this.motif,
    required this.praticien,
    required this.uuidVisiteur,
    this.praticienInfo, // Nouveau paramètre optionnel
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

  factory CompteRenduList.fromMap(Map<String, dynamic> map) {
    // Traitement des médicaments
    List<Map<String, dynamic>>? medicamentsList;
    if (map['medicaments'] != null) {
      medicamentsList = List<Map<String, dynamic>>.from(
        (map['medicaments'] as List).map((m) {
          // Vérifier si le médicament est déjà au bon format
          if (m is Map<String, dynamic>) {
            // S'assurer que le nom est correctement extrait
            if (!m.containsKey('nom') && (m.containsKey('nom_commercial') || m.containsKey('id_medicament'))) {
              m['nom'] = m['nom_commercial'] ?? 'Médicament ${m['id_medicament']}'; 
            }
            return m;
          }
          // Sinon, convertir en Map
          return {
            'id_medicament': m['id'] ?? m['id_medicament'],
            'nom': m['nom_commercial'] ?? m['nom'] ?? 'Médicament sans nom',
            'quantite': m['quantite'] ?? 0,
            'presenter': m['presenter'] ?? false,
          };
        }),
      );
    }
    
    // Traitement du praticien
    Map<String, dynamic>? praticienMap;
    if (map['praticien'] != null) {
      if (map['praticien'] is Map) {
        praticienMap = Map<String, dynamic>.from(map['praticien']);
        
        // S'assurer que l'ID du praticien est correctement extrait
        if (praticienMap.containsKey('id') && praticienMap['id'] is int) {
          // L'ID est déjà correct
        } else if (map.containsKey('praticien_id')) {
          // Utiliser l'ID du praticien depuis le niveau supérieur
          praticienMap['id'] = map['praticien_id'];
        }
      } else if (map['praticien'] is int) {
        // Si praticien est juste un ID, créer un map avec cet ID
        praticienMap = {
          'id': map['praticien'],
          'nom': 'Praticien ${map['praticien']}',
          'prenom': '',
        };
      }
    }
    
    // Traitement des informations complètes du praticien
    Map<String, dynamic>? praticienInfoMap;
    if (map['praticien_info'] != null) {
      praticienInfoMap = Map<String, dynamic>.from(map['praticien_info']);
      print('Informations complètes du praticien extraites: $praticienInfoMap');
    }
    
    return CompteRenduList(
      dateVisite: DateTime.parse(map['date_visite']),
      praticien: praticienMap,
      praticienInfo: praticienInfoMap, // Ajouter les informations complètes du praticien
      motif: map['motif'],
      bilan: map['bilan'],
      uuidVisiteur: map['uuid_visiteur'],
      medicaments: medicamentsList,
    );
  }
}
