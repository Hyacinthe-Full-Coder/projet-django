class Ticket {
  //? CHAMPS PRINCIPAUX
  final int id;
  final String titre;
  final String description;
  
  //? CHAMPS DE CATÉGORISATION
  final String type;
  final String status;
  final String priorite;
  
  //? CHAMPS RELATIONNELS (AUTEUR ET ASSIGNATION)
  final String auteurNom;
  final String dateCreation;
  final String? assigneA;
  final int? assigneAId;
  final List<dynamic> commentaires;

  //? CONSTRUCTEUR
  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    required this.status,
    required this.priorite,
    required this.auteurNom,
    required this.dateCreation,
    this.assigneA,
    this.assigneAId,
    this.commentaires = const [],
  });

  //? CONVERSION JSON → OBJET DART
  factory Ticket.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final assigne = json['assigne_a'] as Map<String, dynamic>?;
    return Ticket(
      id: json['id'],
      titre: json['titre'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type_ticket'] ?? json['type'] ?? '',
      status: json['statut'] ?? json['status'] ?? '',
      priorite: json['priorite'] ?? '',
      auteurNom: auteur != null
          ? '${auteur['first_name']} ${auteur['last_name']}'
          : 'Inconnu',
      dateCreation: json['date_creation'] ?? json['dateCreation'] ?? '',
      assigneAId: assigne != null ? assigne['id'] : null,
      assigneA: assigne != null
          ? '${assigne['first_name']} ${assigne['last_name']}'
          : null,
      commentaires: json['commentaires'] ?? [],
    );
  }

  //? CONVERSION OBJET DART → JSON (POUR ENVOI API)
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'type_ticket': type,
      'priorite': priorite,
    };
  }
}