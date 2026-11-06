import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Un document de la base de connaissance fiscale (article CGI,
/// instruction BOFiP ou decision de jurisprudence).
class DocumentFiscal {
  final String id;
  final String source;
  final String reference;
  final String titre;
  final String texte;
  final List<String> motsCles;

  const DocumentFiscal({
    required this.id,
    required this.source,
    required this.reference,
    required this.titre,
    required this.texte,
    required this.motsCles,
  });

  factory DocumentFiscal.fromJson(String source, Map<String, dynamic> json) =>
      DocumentFiscal(
        id: json['id'] as String,
        source: source,
        reference: json['reference'] as String,
        titre: json['titre'] as String,
        texte: json['texte'] as String,
        motsCles: (json['mots_cles'] as List<dynamic>).cast<String>(),
      );
}

/// Resultat de recherche avec score de pertinence.
class ResultatRecherche {
  final DocumentFiscal document;
  final double score;
  const ResultatRecherche(this.document, this.score);
}

/// Base de connaissance fiscale locale avec recherche par pertinence
/// (RAG embarque, 100% hors-ligne, conforme a l'architecture "no data
/// transmission" du projet).
///
/// Usage typique : [charger] au demarrage, puis [rechercher] pour
/// retrouver les textes applicables a une question, et [formatContexte]
/// pour injecter les extraits dans le prompt d'un agent IA.
class FiscalKnowledgeService {
  static const List<String> fichiers = [
    'assets/knowledge/cgi_articles.json',
    'assets/knowledge/bofip_instructions.json',
    'assets/knowledge/jurisprudence.json',
  ];

  static const Set<String> _motsVides = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'de',
    'du',
    'et',
    'ou',
    'a',
    'au',
    'aux',
    'en',
    'dans',
    'sur',
    'pour',
    'par',
    'avec',
    'sans',
    'est',
    'sont',
    'que',
    'qui',
    'quoi',
    'dont',
    'ce',
    'cet',
    'cette',
    'il',
    'elle',
    'on',
    'nous',
    'vous',
    'je',
    'tu',
    'se',
    'sa',
    'son',
    'ses',
    'leur',
    'leurs',
    'mon',
    'ma',
    'mes',
    'ton',
    'ta',
    'tes',
    'd',
    'l',
    's',
    'qu',
    'ne',
    'pas',
    'plus',
    'peut',
    'etre',
    'avoir',
    'fait',
    'si',
    'y',
    'tout',
    'tous',
    'toute',
    'entre',
    'sous',
    'chez',
  };

  final List<DocumentFiscal> _documents = [];
  bool _charge = false;

  bool get estCharge => _charge;
  int get nombreDocuments => _documents.length;
  List<DocumentFiscal> get documents => List.unmodifiable(_documents);

  /// Charge les fichiers JSON depuis les assets de l'application.
  Future<void> charger() async {
    for (final fichier in fichiers) {
      final contenu = await rootBundle.loadString(fichier);
      chargerDepuisJson(contenu);
    }
    _charge = true;
  }

  /// Charge un fichier JSON (texte brut) dans l'index. Methode publique
  /// pour permettre l'injection de contenu en tests.
  void chargerDepuisJson(String contenuJson) {
    final decoded = jsonDecode(contenuJson) as Map<String, dynamic>;
    final source = decoded['source'] as String? ?? 'inconnue';
    final docs =
        (decoded['documents'] as List<dynamic>?)
            ?.map(
              (d) => DocumentFiscal.fromJson(source, d as Map<String, dynamic>),
            )
            .toList() ??
        [];
    _documents.addAll(docs);
    _charge = true;
  }

  /// Normalise un texte : minuscules, sans accents, sans ponctuation.
  static String normaliser(String texte) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ç': 'c',
      'ñ': 'n',
      'œ': 'oe',
      'æ': 'ae',
    };
    var t = texte.toLowerCase();
    accents.forEach((k, v) => t = t.replaceAll(k, v));
    return t.replaceAll(RegExp(r"[^a-z0-9% ]"), ' ');
  }

  static List<String> _tokens(String texte) => normaliser(texte)
      .split(RegExp(r'\s+'))
      .where((t) => t.length > 2 && !_motsVides.contains(t))
      .toList();

  /// Recherche les documents les plus pertinents pour une question en
  /// langage naturel. Score = correspondances mots-cles (poids 3) +
  /// titre/reference (poids 2) + texte (poids 1).
  List<ResultatRecherche> rechercher(String requete, {int maxResultats = 5}) {
    final termes = _tokens(requete);
    if (termes.isEmpty) return [];

    final resultats = <ResultatRecherche>[];
    for (final doc in _documents) {
      final motsClesNorm = doc.motsCles.map(normaliser).join(' ');
      final titreNorm = '${normaliser(doc.titre)} ${normaliser(doc.reference)}';
      final texteNorm = normaliser(doc.texte);
      var score = 0.0;
      for (final terme in termes) {
        if (motsClesNorm.contains(terme)) score += 3;
        if (titreNorm.contains(terme)) score += 2;
        if (texteNorm.contains(terme)) score += 1;
      }
      if (score > 0) resultats.add(ResultatRecherche(doc, score));
    }

    resultats.sort((a, b) => b.score.compareTo(a.score));
    return resultats.take(maxResultats).toList();
  }

  /// Formate les documents les plus pertinents en bloc de contexte
  /// pret a injecter dans un prompt d'agent IA (Copilote Fiscal).
  String formatContexte(String requete, {int maxResultats = 3}) {
    final resultats = rechercher(requete, maxResultats: maxResultats);
    if (resultats.isEmpty) {
      return 'Aucun texte applicable trouve dans la base locale.';
    }
    final buffer = StringBuffer('Textes applicables (base locale) :\n');
    for (final r in resultats) {
      buffer.writeln(
        '- [${r.document.reference}] ${r.document.titre} : ${r.document.texte}',
      );
    }
    return buffer.toString();
  }
}
