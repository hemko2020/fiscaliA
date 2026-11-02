/// Modele pour le calculateur Pacte Dutreil (Story 8.5).
///
/// Reference : Art. 787 B et 787 C CGI - abattement de 75% sur la valeur
/// des titres ou de l'entreprise individuelle transmis, sous conditions
/// d'engagement collectif (2 ans) et individuel de conservation (4 ans).
class PacteDutreilModel {
  /// Valeur de l'entreprise ou des titres transmis.
  final double valeurEntreprise;

  /// Nombre d'enfants beneficiaires.
  final int nbEnfants;

  /// Nombre de parents donateurs (1 ou 2).
  final int nbParents;

  /// Type de transmission : donation (abattements 100k) ou deces.
  final bool enDonation;

  const PacteDutreilModel({
    required this.valeurEntreprise,
    this.nbEnfants = 1,
    this.nbParents = 1,
    this.enDonation = true,
  });
}

/// Resultat de la comparaison avec/sans Pacte Dutreil.
class PacteDutreilResult {
  /// Droits sans le pacte (pleine valeur).
  final double droitsSansDutreil;

  /// Droits avec le pacte (abattement 75%).
  final double droitsAvecDutreil;

  /// Economie realisee.
  final double economie;

  /// Assiette taxable avec le pacte (25% de la valeur - abattements).
  final double assietteAvecDutreil;

  /// Conditions a respecter pour conserver l'avantage.
  final List<String> conditions;

  const PacteDutreilResult({
    required this.droitsSansDutreil,
    required this.droitsAvecDutreil,
    required this.economie,
    required this.assietteAvecDutreil,
    required this.conditions,
  });
}
