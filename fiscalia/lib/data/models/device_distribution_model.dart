import 'package:hive/hive.dart';

@HiveType(typeId: 14)
class DeviceDistributionModel {
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final String deviceName;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime dateCreated;

  @HiveField(5)
  final DateTime? dateModified;

  DeviceDistributionModel({
    required this.deviceId,
    required this.deviceName,
    required this.category,
    required this.amount,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get percentage {
    return 0;
  }

  DeviceDistributionModel copyWith({
    String? deviceId,
    String? deviceName,
    String? category,
    double? amount,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return DeviceDistributionModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'category': category,
      'amount': amount,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory DeviceDistributionModel.fromJson(Map<String, dynamic> json) {
    return DeviceDistributionModel(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}

@HiveType(typeId: 15)
class DeviceDistributionSummary {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double totalAmount;

  @HiveField(2)
  final double percentage;

  @HiveField(3)
  final int deviceCount;

  @HiveField(4)
  final DateTime lastUpdated;

  DeviceDistributionSummary({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.deviceCount,
    required this.lastUpdated,
  });

  DeviceDistributionSummary copyWith({
    String? category,
    double? totalAmount,
    double? percentage,
    int? deviceCount,
    DateTime? lastUpdated,
  }) {
    return DeviceDistributionSummary(
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      percentage: percentage ?? this.percentage,
      deviceCount: deviceCount ?? this.deviceCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalAmount': totalAmount,
      'percentage': percentage,
      'deviceCount': deviceCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DeviceDistributionSummary.fromJson(Map<String, dynamic> json) {
    return DeviceDistributionSummary(
      category: json['category'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      deviceCount: json['deviceCount'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
