/// Modele pour le calculateur de demembrement de propriete (Story 8.4).
///
/// Reference : Art. 669 CGI (bareme de valorisation usufruit/nue-propriete),
/// Art. 777 et 779 CGI (abattement et bareme en ligne directe).
class DemembrementModel {
  /// Age de l'usufruitier (le donateur qui conserve l'usufruit).
  final int ageUsufruitier;

  /// Valeur du bien en pleine propriete.
  final double valeurBien;

  /// Nombre d'enfants beneficiaires de la donation.
  final int nbEnfants;

  /// Nombre de parents donateurs (1 ou 2 : chacun a son abattement).
  final int nbParents;

  const DemembrementModel({
    required this.ageUsufruitier,
    required this.valeurBien,
    this.nbEnfants = 1,
    this.nbParents = 1,
  });
}

/// Resultat du calcul de demembrement.
class DemembrementResult {
  /// Valeur de l'usufruit (Art. 669 CGI).
  final double valeurUsufruit;

  /// Valeur de la nue-propriete (= pleine propriete - usufruit).
  final double valeurNuePropriete;

  /// Ratio applique par le bareme (0..1).
  final double ratioUsufruit;

  /// Abattement total disponible (100 000 EUR x parents x enfants).
  final double abattementTotal;

  /// Assiette taxable apres abattements.
  final double assietteTaxable;

  /// Droits de donation estimes (bareme ligne directe).
  final double droitsDonation;

  /// Droits qui seraient dus en cas de transmission en pleine propriete.
  final double droitsPleinePropriete;

  /// Economie realisee grace au demembrement.
  final double economie;

  final List<String> explications;

  const DemembrementResult({
    required this.valeurUsufruit,
    required this.valeurNuePropriete,
    required this.ratioUsufruit,
    required this.abattementTotal,
    required this.assietteTaxable,
    required this.droitsDonation,
    required this.droitsPleinePropriete,
    required this.economie,
    required this.explications,
  });
}
