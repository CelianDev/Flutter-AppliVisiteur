class Praticien {
  final int id;
  final String nom;
  final String prenom;
  final int specialite;
  final Adresse adresse;

  Praticien({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.specialite,
    required this.adresse,
  });

  factory Praticien.fromMap(Map<String, dynamic> map) {
    return Praticien(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      specialite: map['specialite'],
      adresse: Adresse.fromMap(map['adresse']),
    );
  }
}

class Adresse {
  final String rue;
  final String codePostal;
  final String? complementAdresse;
  final int id;

  Adresse({
    required this.rue,
    required this.codePostal,
    this.complementAdresse,
    required this.id,
  });

  factory Adresse.fromMap(Map<String, dynamic> map) {
    return Adresse(
      rue: map['rue'],
      codePostal: map['code_postal'],
      complementAdresse: map['complement_adresse'],
      id: map['id'],
    );
  }
}
