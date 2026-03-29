import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_distribution_model.dart';

final deviceDistributionServiceProvider = Provider(
  (ref) => DeviceDistributionService(),
);

final deviceDistributionProvider = StateProvider<List<DeviceDistributionModel>>(
  (ref) => [],
);

final deviceDistributionSummaryProvider =
    StateProvider<List<DeviceDistributionSummary>>((ref) => []);

class DeviceDistributionService {
  List<DeviceDistributionSummary> calculateDistributionSummary(
    List<DeviceDistributionModel> devices,
  ) {
    if (devices.isEmpty) {
      return [];
    }

    final totalAmount = devices.fold<double>(
      0,
      (sum, device) => sum + device.amount,
    );

    final categoryMap = <String, List<DeviceDistributionModel>>{};

    for (final device in devices) {
      if (!categoryMap.containsKey(device.category)) {
        categoryMap[device.category] = [];
      }
      categoryMap[device.category]!.add(device);
    }

    final summaries = <DeviceDistributionSummary>[];

    for (final entry in categoryMap.entries) {
      final categoryTotal = entry.value.fold<double>(
        0,
        (sum, device) => sum + device.amount,
      );
      final percentage = totalAmount > 0
          ? ((categoryTotal / totalAmount) * 100).toDouble()
          : 0.0;

      summaries.add(
        DeviceDistributionSummary(
          category: entry.key,
          totalAmount: categoryTotal,
          percentage: percentage,
          deviceCount: entry.value.length,
          lastUpdated: DateTime.now(),
        ),
      );
    }

    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }

  Map<String, dynamic> calculateFullDistributionDetails(
    List<DeviceDistributionModel> devices,
  ) {
    final summaries = calculateDistributionSummary(devices);
    final totalAmount = devices.fold<double>(
      0,
      (sum, device) => sum + device.amount,
    );

    final topDevice = devices.isNotEmpty
        ? devices.reduce(
            (DeviceDistributionModel a, DeviceDistributionModel b) =>
                a.amount > b.amount ? a : b,
          )
        : null;

    final bottomDevice = devices.isNotEmpty
        ? devices.reduce(
            (DeviceDistributionModel a, DeviceDistributionModel b) =>
                a.amount < b.amount ? a : b,
          )
        : null;

    return {
      'totalAmount': totalAmount,
      'deviceCount': devices.length,
      'categoryCount': summaries.length,
      'summaries': summaries,
      'topDevice': topDevice,
      'bottomDevice': bottomDevice,
      'averageAmount': devices.isNotEmpty ? totalAmount / devices.length : 0,
    };
  }

  List<Map<String, dynamic>> getDeviceTimeSeries(
    List<DeviceDistributionModel> devices,
  ) {
    if (devices.isEmpty) {
      return [];
    }

    final sortedDevices = List<DeviceDistributionModel>.from(devices);
    sortedDevices.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));

    final timeSeries = <Map<String, dynamic>>[];

    for (int i = 0; i < sortedDevices.length; i++) {
      final device = sortedDevices[i];
      final cumulativeTotal = sortedDevices
          .take(i + 1)
          .fold<double>(0, (sum, d) => sum + d.amount);

      timeSeries.add({
        'date': device.dateCreated,
        'deviceName': device.deviceName,
        'amount': device.amount,
        'cumulativeTotal': cumulativeTotal,
        'category': device.category,
      });
    }

    return timeSeries;
  }

  String getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'credit':
        return 'Crédits d\'impôt';
      case 'reduction':
        return 'Réductions fiscales';
      case 'deduction':
        return 'Déductions';
      case 'niche':
        return 'Niches fiscales';
      default:
        return category;
    }
  }

  String getDistributionInsight(List<DeviceDistributionSummary> summaries) {
    if (summaries.isEmpty) {
      return 'Aucun dispositif disponible';
    }

    final topCategory = summaries.first;
    final percentage = topCategory.percentage.toStringAsFixed(1);

    return 'Votre catégorie principale est ${getCategoryDisplayName(topCategory.category)} avec $percentage% de vos dispositifs.';
  }

  bool validateDeviceAmount(double amount) {
    return amount >= 0 && amount <= 100000;
  }

  String? validateDeviceAmountMessage(double amount) {
    if (amount < 0) {
      return 'Le montant ne peut pas être négatif';
    }
    if (amount > 100000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }
}
