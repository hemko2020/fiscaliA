import '../models/education_models.dart';

class EducationRepository {
  static const List<EducationalSheetModel> sheets = [
    EducationalSheetModel(
      id: 'per',
      title: 'Plan d\'Épargne Retraite (PER)',
      shortDescription:
          'Déduisez vos versements volontaires de vos revenus imposables pour préparer votre retraite.',
      whatIsIt:
          'Le PER (Plan d\'Épargne Retraite) est un produit d\'épargne à long terme. Il vous permet d\'accumuler un capital pour la retraite, sous forme de rente ou de capital, tout en bénéficiant d\'avantages fiscaux immédiats.',
      howItWorks:
          'Les versements volontaires que vous effectuez sur un PER au cours d\'une année sont déductibles de vos revenus imposables de cette même année. L\'économie d\'impôt dépend de votre Tranche Marginale d\'Imposition (TMI).',
      ceilings:
          'Le plafond de déduction est généralement de 10% de vos revenus professionnels de l\'année précédente (N-1), avec un maximum d\'environ 37 094 € en 2026. Si vous ne l\'utilisez pas, il est reportable sur 3 ans.',
      benefits:
          '- Baisse immédiate de votre impôt sur le revenu.\n- Préparation de votre retraite.\n- Possibilité de débloquer les fonds de manière anticipée pour l\'achat de la résidence principale.',
      examples:
          'Si vous êtes imposé à une TMI de 30% et que vous versez 5 000 € sur votre PER, vous économisez immédiatement 1 500 € d\'impôts (5000 * 30%).',
      technicalDetails:
          'Attention : L\'avantage fiscal à l\'entrée a une contrepartie à la sortie. Au moment de la retraite, le capital retiré sera soumis au barème de l\'impôt sur le revenu, et les plus-values au PFU (30%). Le PER est particulièrement intéressant si votre TMI à la retraite sera inférieure à votre TMI pendant votre vie active.',
      relatedTerms: ['TMI', 'Plafond', 'Déduction'],
    ),
    EducationalSheetModel(
      id: 'lmnp',
      title: 'Location Meublée Non Professionnelle (LMNP)',
      shortDescription:
          'Louez un bien meublé et générez des revenus locatifs peu ou pas imposés grâce à l\'amortissement.',
      whatIsIt:
          'Le statut LMNP permet à un particulier de louer un ou plusieurs logements meublés tout en bénéficiant d\'une fiscalité très avantageuse (régime BIC).',
      howItWorks:
          'Contrairement à la location vide (revenus fonciers), les loyers meublés sont déclarés en Bénéfices Industriels et Commerciaux (BIC). Au régime réel, vous pouvez déduire l\'ensemble de vos charges et surtout amortir la valeur de votre bien immobilier et de vos meubles.',
      ceilings:
          'Pour conserver le statut non professionnel, vos recettes locatives doivent être inférieures à 23 000 € TTC par an OU représenter moins de 50% des revenus globaux de votre foyer fiscal.',
      benefits:
          '- Possibilité de réduire l\'imposition de vos loyers à 0 € pendant de nombreuses années.\n- Constitution d\'un patrimoine immobilier.',
      examples:
          'Vous achetez un appartement 150 000 € et générez 6 000 € de loyers par an. En déduisant les intérêts d\'emprunt, les charges (2 000 €) et l\'amortissement comptable du bien (par exemple 4 000 €/an), votre bénéfice imposable devient nul. Vous ne payez pas d\'impôt sur ces loyers.',
      technicalDetails:
          'L\'amortissement est une charge fictive qui représente la perte de valeur du bien dans le temps (généralement calculée sur 25 à 30 ans). Il est impératif de faire appel à un expert-comptable pour réaliser les liasses fiscales LMNP au régime réel.',
      relatedTerms: ['Amortissement', 'BIC', 'Déficit Foncier'],
    ),
    EducationalSheetModel(
      id: 'emploi_domicile',
      title: 'Emploi à Domicile & Garde d\'enfants',
      shortDescription:
          'Bénéficiez d\'un crédit d\'impôt de 50% sur vos dépenses d\'aide à domicile ou de garde.',
      whatIsIt:
          'Un avantage fiscal accordé si vous employez un salarié à votre domicile (ménage, jardinage, soutien scolaire) ou si vous faites garder vos enfants à l\'extérieur (crèche, assistante maternelle).',
      howItWorks:
          'L\'État vous rembourse 50% des dépenses engagées (salaires + cotisations sociales) sous forme de crédit d\'impôt. Si le crédit dépasse l\'impôt que vous devez payer, l\'administration fiscale vous rembourse la différence par virement.',
      ceilings:
          'Emploi à domicile : Plafond de dépenses de 12 000 € par an (+1 500 € par enfant, max 15 000 €). Garde d\'enfant (moins de 6 ans) : Plafond de 3 500 € de dépenses par enfant.',
      benefits:
          '- Réduction de 50% du coût réel de ces services.\n- Aide au maintien à domicile ou à la garde d\'enfants.',
      examples:
          'Vous payez 4 000 € par an pour une femme de ménage. Vous bénéficiez d\'un crédit d\'impôt de 2 000 €. Si votre impôt sur le revenu est de 500 €, l\'État l\'annule et vous verse un chèque de 1 500 €.',
      technicalDetails:
          'Ces avantages sont soumis au plafonnement global des niches fiscales de 10 000 € par an et par foyer fiscal. Le système de l\'Avance Immédiate permet désormais de ne payer que le reste à charge directement (50%) sans attendre l\'année suivante.',
      relatedTerms: ['Crédit d\'impôt', 'Niche Fiscale', 'Foyer Fiscal'],
    ),
  ];

  static const List<FaqItemModel> faqItems = [
    FaqItemModel(
      id: 'faq1',
      question: 'Qu\'est-ce que le prélèvement à la source (PAS) ?',
      answer:
          'C\'est un mode de recouvrement de l\'impôt consistant à faire prélever son montant par un tiers payeur (l\'employeur, Pôle emploi, caisse de retraite...) au moment du versement des revenus. Votre impôt s\'adapte ainsi en temps réel à vos revenus.',
      tags: ['Impôt', 'Général', 'Revenu'],
    ),
    FaqItemModel(
      id: 'faq2',
      question: 'Quelle est la différence entre réduction et crédit d\'impôt ?',
      answer:
          'Une réduction d\'impôt vient diminuer le montant de votre impôt. Si elle est supérieure à l\'impôt dû, le surplus est perdu. Un crédit d\'impôt fonctionne pareil, mais si son montant dépasse votre impôt (ou si vous n\'êtes pas imposable), l\'État vous rembourse la différence.',
      tags: ['Crédit d\'impôt', 'Réduction', 'Vocabulaire'],
    ),
    FaqItemModel(
      id: 'faq3',
      question: 'Où trouver mon plafond de niches fiscales ?',
      answer:
          'Le plafond global des niches fiscales est fixé à 10 000 € par an (18 000 € incluant certains investissements outre-mer et Sofica). Le détail de ce que vous avez déjà consommé peut être estimé dans la section "Niches Fiscales" de notre application.',
      tags: ['Niche Fiscale', 'Plafond'],
    ),
    FaqItemModel(
      id: 'faq4',
      question: 'Quand dois-je déclarer mes impôts ?',
      answer:
          'La campagne de déclaration commence mi-avril. La date limite varie selon votre département de résidence (fin mai pour les départements 01 à 19, début juin pour 20 à 54, et mi-juin pour 55 à 976). Consultez le Calendrier Fiscal dans l\'application pour voir votre date précise.',
      tags: ['Calendrier', 'Déclaration'],
    ),
    FaqItemModel(
      id: 'faq5',
      question: 'Le PER est-il toujours intéressant ?',
      answer:
          'Le PER est surtout intéressant si vous êtes actuellement dans une Tranche Marginale d\'Imposition (TMI) élevée (30%, 41% ou 45%) et que vous anticipez une TMI plus faible à la retraite (ex: 11%). Si votre TMI est de 11% aujourd\'hui, le gain fiscal est limité.',
      tags: ['PER', 'Retraite', 'Optimisation'],
    ),
  ];

  static const List<GlossaryTermModel> glossaryTerms = [
    GlossaryTermModel(
      term: 'Abattement',
      definition:
          'Déduction forfaitaire appliquée sur une somme avant qu\'elle ne soit soumise à l\'impôt. Exemple : l\'abattement de 10% sur les salaires pour frais professionnels.',
      crossReferences: ['Déduction'],
    ),
    GlossaryTermModel(
      term: 'BIC (Bénéfices Industriels et Commerciaux)',
      definition:
          'Catégorie de revenus concernant les bénéfices réalisés par des personnes physiques exerçant une profession commerciale, industrielle ou artisanale, ainsi que les locations meublées (LMNP).',
      crossReferences: ['LMNP'],
    ),
    GlossaryTermModel(
      term: 'Crédit d\'impôt',
      definition:
          'Somme soustraite du montant de l\'impôt. Si ce crédit est supérieur à l\'impôt dû, l\'administration fiscale rembourse la différence.',
      crossReferences: ['Réduction d\'impôt'],
    ),
    GlossaryTermModel(
      term: 'Décote',
      definition:
          'Mécanisme permettant d\'atténuer ou d\'annuler l\'impôt sur le revenu des contribuables dont les revenus sont modestes, afin d\'éviter un franchissement de seuil brutal.',
      crossReferences: ['TMI'],
    ),
    GlossaryTermModel(
      term: 'Déduction',
      definition:
          'Somme retranchée de votre revenu imposable (ex: versements PER, pensions alimentaires), ce qui diminue mécaniquement la base sur laquelle est calculé l\'impôt.',
      crossReferences: ['PER', 'Revenu imposable'],
    ),
    GlossaryTermModel(
      term: 'Niche Fiscale',
      definition:
          'Avantage fiscal accordé par la loi pour inciter les contribuables à investir dans certains secteurs ou à effectuer certaines dépenses (emploi à domicile, dons, Pinel). Elle est plafonnée à 10 000 € par an.',
      crossReferences: ['Crédit d\'impôt'],
    ),
    GlossaryTermModel(
      term: 'Quotient Familial',
      definition:
          'Système consistant à diviser le revenu imposable du foyer par son nombre de parts (lié à la situation familiale et au nombre d\'enfants). Cela permet d\'atténuer la progressivité de l\'impôt pour les familles.',
      crossReferences: ['Foyer Fiscal'],
    ),
    GlossaryTermModel(
      term: 'Réduction d\'impôt',
      definition:
          'Somme venant en déduction de l\'impôt calculé. Contrairement au crédit d\'impôt, si la réduction est supérieure à l\'impôt, le surplus ne donne pas lieu à restitution.',
      crossReferences: ['Crédit d\'impôt'],
    ),
    GlossaryTermModel(
      term: 'TMI (Tranche Marginale d\'Imposition)',
      definition:
          'Taux d\'imposition (0%, 11%, 30%, 41% ou 45%) appliqué à la dernière tranche de vos revenus. C\'est le taux qui s\'applique à tout euro supplémentaire gagné ou déduit.',
      crossReferences: ['Déduction'],
    ),
  ];
}
