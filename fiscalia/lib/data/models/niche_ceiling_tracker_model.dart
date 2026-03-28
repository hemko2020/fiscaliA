import 'package:hive/hive.dart';

part 'niche_ceiling_tracker_model.g.dart';

@HiveType(typeId: 9)
class NicheCeilingTrackerModel {
  @HiveField(0)
  final double totalCeiling;

  @HiveField(1)
  final double usedCeiling;

  @HiveField(2)
  final List<NicheCreditEntry> creditEntries;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final DateTime? dateModified;

  NicheCeilingTrackerModel({
    this.totalCeiling = 10000,
    this.usedCeiling = 0,
    List<NicheCreditEntry>? creditEntries,
    DateTime? dateCreated,
    this.dateModified,
  }) : creditEntries = creditEntries ?? [],
       dateCreated = dateCreated ?? DateTime.now();

  double get remainingCeiling => totalCeiling - usedCeiling;

  double get utilizationRate => usedCeiling / totalCeiling;

  bool get isOverCeiling => usedCeiling > totalCeiling;

  bool get isNearCeiling => utilizationRate >= 0.8;

  NicheCeilingTrackerModel addCredit({
    required String creditType,
    required double amount,
    String? description,
  }) {
    final newEntry = NicheCreditEntry(
      creditType: creditType,
      amount: amount,
      description: description,
      dateAdded: DateTime.now(),
    );

    return NicheCeilingTrackerModel(
      totalCeiling: totalCeiling,
      usedCeiling: usedCeiling + amount,
      creditEntries: [...creditEntries, newEntry],
      dateCreated: dateCreated,
      dateModified: DateTime.now(),
    );
  }

  NicheCeilingTrackerModel removeCredit(String entryId) {
    final entryToRemove = creditEntries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw Exception('Entry not found'),
    );

    return NicheCeilingTrackerModel(
      totalCeiling: totalCeiling,
      usedCeiling: usedCeiling - entryToRemove.amount,
      creditEntries: creditEntries
          .where((entry) => entry.id != entryId)
          .toList(),
      dateCreated: dateCreated,
      dateModified: DateTime.now(),
    );
  }

  NicheCeilingTrackerModel clearAll() {
    return NicheCeilingTrackerModel(
      totalCeiling: totalCeiling,
      usedCeiling: 0,
      creditEntries: [],
      dateCreated: dateCreated,
      dateModified: DateTime.now(),
    );
  }

  Map<String, double> getCreditBreakdown() {
    final breakdown = <String, double>{};
    for (final entry in creditEntries) {
      breakdown[entry.creditType] =
          (breakdown[entry.creditType] ?? 0) + entry.amount;
    }
    return breakdown;
  }

  NicheCeilingTrackerModel copyWith({
    double? totalCeiling,
    double? usedCeiling,
    List<NicheCreditEntry>? creditEntries,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return NicheCeilingTrackerModel(
      totalCeiling: totalCeiling ?? this.totalCeiling,
      usedCeiling: usedCeiling ?? this.usedCeiling,
      creditEntries: creditEntries ?? this.creditEntries,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCeiling': totalCeiling,
      'usedCeiling': usedCeiling,
      'creditEntries': creditEntries.map((e) => e.toJson()).toList(),
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory NicheCeilingTrackerModel.fromJson(Map<String, dynamic> json) {
    return NicheCeilingTrackerModel(
      totalCeiling: (json['totalCeiling'] as num?)?.toDouble() ?? 10000,
      usedCeiling: (json['usedCeiling'] as num?)?.toDouble() ?? 0,
      creditEntries:
          (json['creditEntries'] as List?)
              ?.map((e) => NicheCreditEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}

@HiveType(typeId: 10)
class NicheCreditEntry {
  static int _idCounter = 0;

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String creditType;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final DateTime dateAdded;

  NicheCreditEntry({
    required this.creditType,
    required this.amount,
    this.description,
    DateTime? dateAdded,
  }) : id = '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
       dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditType': creditType,
      'amount': amount,
      'description': description,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory NicheCreditEntry.fromJson(Map<String, dynamic> json) {
    final entry = NicheCreditEntry(
      creditType: json['creditType'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'] as String)
          : DateTime.now(),
    );
    return entry;
  }
}
