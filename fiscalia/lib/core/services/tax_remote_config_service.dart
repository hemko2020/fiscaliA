import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../constants/tax_brackets.dart';
import 'advanced_tax_config.dart';

/// Configuration fiscale complete pouvant etre mise a jour a distance
/// (Story 10.3 : mise a jour des baremes sans release applicative).
class TaxConfig {
  final List<TaxBracket> brackets;
  final double familyQuotientCeiling;
  final double parentIsoleQuotientCeiling;
  final double nicheCeilingGeneral;
  final double nicheCeilingOverseas;
  final double decoteSingleThreshold;
  final double decoteCoupleThreshold;
  final double perAnnualCeiling;
  final double homeEmploymentCeiling;
  final double childCareCeilingPerChild;
  final double donation75Ceiling;
  final double propertyDeficitCeiling;
  final double decoteMultiplier;
  final double homeEmploymentExtraPerChild;
  final double homeEmploymentMaxFirstYear;
  final double homeEmploymentMaxWithMajorations;
  final int taxYear;

  const TaxConfig({
    required this.brackets,
    required this.familyQuotientCeiling,
    required this.parentIsoleQuotientCeiling,
    required this.nicheCeilingGeneral,
    required this.nicheCeilingOverseas,
    required this.decoteSingleThreshold,
    required this.decoteCoupleThreshold,
    required this.perAnnualCeiling,
    required this.homeEmploymentCeiling,
    required this.childCareCeilingPerChild,
    required this.donation75Ceiling,
    required this.propertyDeficitCeiling,
    required this.decoteMultiplier,
    required this.homeEmploymentExtraPerChild,
    required this.homeEmploymentMaxFirstYear,
    required this.homeEmploymentMaxWithMajorations,
    required this.taxYear,
  });

  /// Configuration embarquee (fallback) : valeurs 2026 compilees dans l'app.
  const TaxConfig.embedded()
    : brackets = TaxBrackets2026.ir2026,
      familyQuotientCeiling = TaxBrackets2026.familyQuotientCeiling,
      parentIsoleQuotientCeiling = TaxBrackets2026.parentIsoleQuotientCeiling,
      nicheCeilingGeneral = TaxBrackets2026.nicheCeilingGeneral,
      nicheCeilingOverseas = TaxBrackets2026.nicheCeilingOverseas,
      decoteSingleThreshold = TaxBrackets2026.decoteSingleThreshold,
      decoteCoupleThreshold = TaxBrackets2026.decoteCoupleThreshold,
      perAnnualCeiling = TaxBrackets2026.perAnnualCeiling,
      homeEmploymentCeiling = TaxBrackets2026.homeEmploymentCeiling,
      childCareCeilingPerChild = TaxBrackets2026.childCareCeilingPerChild,
      donation75Ceiling = TaxBrackets2026.donation75Ceiling,
      propertyDeficitCeiling = TaxBrackets2026.propertyDeficitCeiling,
      decoteMultiplier = TaxBrackets2026.decoteMultiplier,
      homeEmploymentExtraPerChild = TaxBrackets2026.homeEmploymentExtraPerChild,
      homeEmploymentMaxFirstYear = TaxBrackets2026.homeEmploymentMaxFirstYear,
      homeEmploymentMaxWithMajorations =
          TaxBrackets2026.homeEmploymentMaxWithMajorations,
      taxYear = 2026;

  factory TaxConfig.fromJson(Map<String, dynamic> json) {
    final rawBrackets = json['brackets'] as List<dynamic>?;
    if (rawBrackets == null || rawBrackets.isEmpty) {
      throw const FormatException('brackets manquants ou vides');
    }
    final brackets = rawBrackets.map((b) {
      final map = b as Map<String, dynamic>;
      final max = (map['maxIncome'] as num).toDouble();
      return TaxBracket(
        minIncome: (map['minIncome'] as num).toDouble(),
        // 0 signifie "pas de borne haute" dans le JSON Remote Config
        maxIncome: max <= 0 ? double.infinity : max,
        rate: (map['rate'] as num).toDouble(),
      );
    }).toList();

    double readDouble(String key, double fallback) =>
        (json[key] as num?)?.toDouble() ?? fallback;
    final embedded = TaxConfig.embedded();

    return TaxConfig(
      brackets: brackets,
      familyQuotientCeiling: readDouble(
        'familyQuotientCeiling',
        embedded.familyQuotientCeiling,
      ),
      parentIsoleQuotientCeiling: readDouble(
        'parentIsoleQuotientCeiling',
        embedded.parentIsoleQuotientCeiling,
      ),
      nicheCeilingGeneral: readDouble(
        'nicheCeilingGeneral',
        embedded.nicheCeilingGeneral,
      ),
      nicheCeilingOverseas: readDouble(
        'nicheCeilingOverseas',
        embedded.nicheCeilingOverseas,
      ),
      decoteSingleThreshold: readDouble(
        'decoteSingleThreshold',
        embedded.decoteSingleThreshold,
      ),
      decoteCoupleThreshold: readDouble(
        'decoteCoupleThreshold',
        embedded.decoteCoupleThreshold,
      ),
      perAnnualCeiling: readDouble(
        'perAnnualCeiling',
        embedded.perAnnualCeiling,
      ),
      homeEmploymentCeiling: readDouble(
        'homeEmploymentCeiling',
        embedded.homeEmploymentCeiling,
      ),
      childCareCeilingPerChild: readDouble(
        'childCareCeilingPerChild',
        embedded.childCareCeilingPerChild,
      ),
      donation75Ceiling: readDouble(
        'donation75Ceiling',
        embedded.donation75Ceiling,
      ),
      propertyDeficitCeiling: readDouble(
        'propertyDeficitCeiling',
        embedded.propertyDeficitCeiling,
      ),
      decoteMultiplier: readDouble(
        'decoteMultiplier',
        embedded.decoteMultiplier,
      ),
      homeEmploymentExtraPerChild: readDouble(
        'homeEmploymentExtraPerChild',
        embedded.homeEmploymentExtraPerChild,
      ),
      homeEmploymentMaxFirstYear: readDouble(
        'homeEmploymentMaxFirstYear',
        embedded.homeEmploymentMaxFirstYear,
      ),
      homeEmploymentMaxWithMajorations: readDouble(
        'homeEmploymentMaxWithMajorations',
        embedded.homeEmploymentMaxWithMajorations,
      ),
      taxYear: (json['taxYear'] as num?)?.toInt() ?? embedded.taxYear,
    );
  }

  Map<String, dynamic> toJson() => {
    'taxYear': taxYear,
    'brackets': brackets
        .map(
          (b) => {
            'minIncome': b.minIncome,
            'maxIncome': b.maxIncome.isInfinite ? 0 : b.maxIncome,
            'rate': b.rate,
          },
        )
        .toList(),
    'familyQuotientCeiling': familyQuotientCeiling,
    'parentIsoleQuotientCeiling': parentIsoleQuotientCeiling,
    'nicheCeilingGeneral': nicheCeilingGeneral,
    'nicheCeilingOverseas': nicheCeilingOverseas,
    'decoteSingleThreshold': decoteSingleThreshold,
    'decoteCoupleThreshold': decoteCoupleThreshold,
    'perAnnualCeiling': perAnnualCeiling,
    'homeEmploymentCeiling': homeEmploymentCeiling,
    'childCareCeilingPerChild': childCareCeilingPerChild,
    'donation75Ceiling': donation75Ceiling,
    'propertyDeficitCeiling': propertyDeficitCeiling,
    'decoteMultiplier': decoteMultiplier,
    'homeEmploymentExtraPerChild': homeEmploymentExtraPerChild,
    'homeEmploymentMaxFirstYear': homeEmploymentMaxFirstYear,
    'homeEmploymentMaxWithMajorations': homeEmploymentMaxWithMajorations,
  };
}

/// Abstraction du client Remote Config pour rendre le service testable
/// sans Firebase.
abstract class RemoteConfigClient {
  Future<void> setConfigSettings({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  });
  Future<void> setDefaults(Map<String, dynamic> defaults);
  Future<bool> fetchAndActivate();
  String getString(String key);
}

class FirebaseRemoteConfigClient implements RemoteConfigClient {
  final FirebaseRemoteConfig _instance;
  FirebaseRemoteConfigClient(this._instance);

  @override
  Future<void> setConfigSettings({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  }) => _instance.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: minimumFetchInterval,
    ),
  );

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) =>
      _instance.setDefaults(defaults);

  @override
  Future<bool> fetchAndActivate() => _instance.fetchAndActivate();

  @override
  String getString(String key) => _instance.getString(key);
}

/// Service de configuration fiscale distante (Story 10.3).
///
/// - Les valeurs par defaut sont les baremes embarques 2026.
/// - `fetchAndActivate` recupere la cle `tax_config_json` depuis Firebase
///   Remote Config ; en cas d'echec ou de JSON invalide, on conserve le
///   fallback embarque (jamais de crash ni de valeurs incoherentes).
class TaxRemoteConfigService {
  static const String configKey = 'tax_config_json';

  /// Cle Remote Config pour les parametres des dispositifs avances (Epic 8).
  static const String advancedConfigKey = 'advanced_tax_config_json';

  final RemoteConfigClient? _client;
  TaxConfig _current = TaxConfig.embedded();
  AdvancedTaxConfig _advancedCurrent = const AdvancedTaxConfig.embedded();

  /// [client] peut etre null (mode hors-ligne / tests) : le service
  /// retourne alors toujours la configuration embarquee.
  TaxRemoteConfigService({RemoteConfigClient? client}) : _client = client;

  TaxConfig get current => _current;

  /// Configuration des dispositifs avances (Epic 8) : distante si
  /// disponible, embarquee sinon.
  AdvancedTaxConfig get advancedCurrent => _advancedCurrent;

  /// Initialise le client avec les valeurs par defaut embarquees.
  /// A appeler au demarrage de l'app, avant tout calcul fiscal.
  Future<void> initialiser() async {
    final client = _client;
    if (client == null) return;
    await client.setConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    );
    await client.setDefaults({
      configKey: jsonEncode(_current.toJson()),
      advancedConfigKey: jsonEncode(_advancedCurrent.toJson()),
    });
  }

  /// Recupere la configuration distante et l'active.
  /// Retourne true si une mise a jour distante a ete appliquee.
  /// Chaque cle est traitee independamment : l'echec de l'une ne
  /// remet pas l'autre au fallback.
  Future<bool> actualiser() async {
    final client = _client;
    if (client == null) return false;
    bool misAJour = false;
    try {
      await client.fetchAndActivate();
    } catch (_) {
      _current = const TaxConfig.embedded();
      _advancedCurrent = const AdvancedTaxConfig.embedded();
      return false;
    }

    final raw = client.getString(configKey);
    if (raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _current = TaxConfig.fromJson(decoded);
          misAJour = true;
        }
      } catch (_) {
        _current = const TaxConfig.embedded();
      }
    }

    final rawAdvanced = client.getString(advancedConfigKey);
    if (rawAdvanced.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawAdvanced);
        if (decoded is Map<String, dynamic>) {
          _advancedCurrent = AdvancedTaxConfig.fromJson(decoded);
          misAJour = true;
        }
      } catch (_) {
        _advancedCurrent = const AdvancedTaxConfig.embedded();
      }
    }

    return misAJour;
  }
}
