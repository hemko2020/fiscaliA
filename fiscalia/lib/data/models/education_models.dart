class EducationalSheetModel {
  final String id;
  final String title;
  final String shortDescription;
  final String whatIsIt;
  final String howItWorks;
  final String ceilings;
  final String benefits;
  final String examples;
  final String technicalDetails;
  final List<String> relatedTerms;

  const EducationalSheetModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.whatIsIt,
    required this.howItWorks,
    required this.ceilings,
    required this.benefits,
    required this.examples,
    required this.technicalDetails,
    this.relatedTerms = const [],
  });
}

class FaqItemModel {
  final String id;
  final String question;
  final String answer;
  final List<String> tags;

  const FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.tags,
  });
}

class GlossaryTermModel {
  final String term;
  final String definition;
  final List<String> crossReferences;

  const GlossaryTermModel({
    required this.term,
    required this.definition,
    this.crossReferences = const [],
  });
}