import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/device_distribution_model.dart';
import 'package:fiscalia/presentation/providers/device_distribution_provider.dart';

void main() {
  group('DeviceDistributionModel', () {
    test('should create model with correct values', () {
      final model = DeviceDistributionModel(
        deviceId: 'test-1',
        deviceName: 'Test Device',
        category: 'credit',
        amount: 1000.0,
      );

      expect(model.deviceId, 'test-1');
      expect(model.deviceName, 'Test Device');
      expect(model.category, 'credit');
      expect(model.amount, 1000.0);
    });

    test('should serialize to JSON correctly', () {
      final model = DeviceDistributionModel(
        deviceId: 'test-1',
        deviceName: 'Test Device',
        category: 'credit',
        amount: 1000.0,
      );

      final json = model.toJson();

      expect(json['deviceId'], 'test-1');
      expect(json['deviceName'], 'Test Device');
      expect(json['category'], 'credit');
      expect(json['amount'], 1000.0);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'deviceId': 'test-1',
        'deviceName': 'Test Device',
        'category': 'credit',
        'amount': 1000.0,
      };

      final model = DeviceDistributionModel.fromJson(json);

      expect(model.deviceId, 'test-1');
      expect(model.deviceName, 'Test Device');
      expect(model.category, 'credit');
      expect(model.amount, 1000);
    });

    test('should copy with new values correctly', () {
      final model = DeviceDistributionModel(
        deviceId: 'test-1',
        deviceName: 'Test Device',
        category: 'credit',
        amount: 1000,
      );

      final updated = model.copyWith(
        amount: 2000.0,
        category: 'reduction',
      );

      expect(updated.deviceId, 'test-1');
      expect(updated.amount, 2000.0);
      expect(updated.category, 'reduction');
    });
  });

  group('DeviceDistributionSummary', () {
    test('should create summary with correct values', () {
      final summary = DeviceDistributionSummary(
        category: 'credit',
        totalAmount: 5000.0,
        percentage: 50.0,
        deviceCount: 5,
        lastUpdated: DateTime.now(),
      );

      expect(summary.category, 'credit');
      expect(summary.totalAmount, 5000.0);
      expect(summary.percentage, 50.0);
      expect(summary.deviceCount, 5.0);
    });

    test('should serialize to JSON correctly', () {
      final summary = DeviceDistributionSummary(
        category: 'credit',
        totalAmount: 5000.0,
        percentage: 50.0,
        deviceCount: 5,
        lastUpdated: DateTime.now(),
      );

      final json = summary.toJson();

      expect(json['category'], 'credit');
      expect(json['totalAmount'], 5000.0);
      expect(json['percentage'], 50.0);
      expect(json['deviceCount'], 5);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'category': 'credit',
        'totalAmount': 5000.0,
        'percentage': 50.0,
        'deviceCount': 5,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      final summary = DeviceDistributionSummary.fromJson(json);

      expect(summary.category, 'credit');
      expect(summary.totalAmount, 5000);
      expect(summary.percentage, 50.0);
      expect(summary.deviceCount, 5);
    });
  });

  group('DeviceDistributionService', () {
    late DeviceDistributionService service;

    setUp(() {
      service = DeviceDistributionService();
    });

    test('should calculate distribution summary correctly', () {
      final devices = [
        DeviceDistributionModel(
          deviceId: '1',
          deviceName: 'Device 1',
          category: 'credit',
          amount: 3000.0,
        ),
        DeviceDistributionModel(
          deviceId: '2',
          deviceName: 'Device 2',
          category: 'reduction',
          amount: 2000.0,
        ),
        DeviceDistributionModel(
          deviceId: '3',
          deviceName: 'Device 3',
          category: 'credit',
          amount: 1000.0,
        ),
      ];

      final summaries = service.calculateDistributionSummary(devices);

      expect(summaries.length, 2);
      expect(summaries[0].category, 'credit');
      expect(summaries[0].totalAmount, 4000);
      expect(summaries[1].category, 'reduction');
      expect(summaries[1].totalAmount, 2000);
    });

    test('should return empty list for empty devices', () {
      final summaries = service.calculateDistributionSummary([]);

      expect(summaries, isEmpty);
    });

    test('should calculate full distribution details correctly', () {
      final devices = [
        DeviceDistributionModel(
          deviceId: '1',
          deviceName: 'Device 1',
          category: 'credit',
          amount: 3000.0,
        ),
        DeviceDistributionModel(
          deviceId: '2',
          deviceName: 'Device 2',
          category: 'reduction',
          amount: 2000.0,
        ),
      ];

      final details = service.calculateFullDistributionDetails(devices);

      expect(details['totalAmount'], 5000);
      expect(details['deviceCount'], 2);
      expect(details['categoryCount'], 2);
      expect(details['averageAmount'], 2500);
    });

    test('should identify top and bottom devices correctly', () {
      final devices = [
        DeviceDistributionModel(
          deviceId: '1',
          deviceName: 'Device 1',
          category: 'credit',
          amount: 3000,
        ),
        DeviceDistributionModel(
          deviceId: '2',
          deviceName: 'Device 2',
          category: 'reduction',
          amount: 2000,
        ),
        DeviceDistributionModel(
          deviceId: '3',
          deviceName: 'Device 3',
          category: 'credit',
          amount: 1000,
        ),
      ];

      final details = service.calculateFullDistributionDetails(devices);

      expect((details['topDevice'] as DeviceDistributionModel).amount, 3000);
      expect((details['bottomDevice'] as DeviceDistributionModel).amount, 1000);
    });

    test('should generate time series correctly', () {
      final devices = [
        DeviceDistributionModel(
          deviceId: '1',
          deviceName: 'Device 1',
          category: 'credit',
          amount: 1000,
          dateCreated: DateTime(2024, 1, 1),
        ),
        DeviceDistributionModel(
          deviceId: '2',
          deviceName: 'Device 2',
          category: 'reduction',
          amount: 2000,
          dateCreated: DateTime(2024, 1, 2),
        ),
      ];

      final timeSeries = service.getDeviceTimeSeries(devices);

      expect(timeSeries.length, 2);
      expect(timeSeries[0]['cumulativeTotal'], 1000);
      expect(timeSeries[1]['cumulativeTotal'], 3000);
    });

    test('should return empty time series for empty devices', () {
      final timeSeries = service.getDeviceTimeSeries([]);

      expect(timeSeries, isEmpty);
    });

    test('should get correct category display name', () {
      expect(service.getCategoryDisplayName('credit'), 'Crédits d\'impôt');
      expect(service.getCategoryDisplayName('reduction'), 'Réductions fiscales');
      expect(service.getCategoryDisplayName('deduction'), 'Déductions');
      expect(service.getCategoryDisplayName('niche'), 'Niches fiscales');
    });

    test('should get distribution insight correctly', () {
      final summaries = [
        DeviceDistributionSummary(
          category: 'credit',
          totalAmount: 5000.0,
          percentage: 60.0,
          deviceCount: 5,
          lastUpdated: DateTime.now(),
        ),
      ];

      final insight = service.getDistributionInsight(summaries);

      expect(insight, contains('Crédits d\'impôt'));
      expect(insight, contains('60.0%'));
    });

    test('should return empty insight for empty summaries', () {
      final insight = service.getDistributionInsight([]);

      expect(insight, 'Aucun dispositif disponible');
    });

    test('should validate device amount correctly', () {
      expect(service.validateDeviceAmount(1000), true);
      expect(service.validateDeviceAmount(0), true);
      expect(service.validateDeviceAmount(-100), false);
      expect(service.validateDeviceAmount(150000), false);
    });

    test('should return validation message for invalid amount', () {
      expect(service.validateDeviceAmountMessage(-100), isNotNull);
      expect(service.validateDeviceAmountMessage(150000), isNotNull);
      expect(service.validateDeviceAmountMessage(1000), isNull);
    });
  });
}
