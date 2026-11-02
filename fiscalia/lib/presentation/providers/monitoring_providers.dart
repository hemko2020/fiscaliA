import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/advanced_tax_config.dart';
import '../../core/services/monitoring_service.dart';
import '../../core/services/tax_remote_config_service.dart';

/// Service de monitoring (Crashlytics + Analytics), initialise dans main().
final monitoringServiceProvider = Provider<MonitoringService>(
  (ref) => throw UnimplementedError(
      'monitoringServiceProvider doit etre override dans main()'),
);

/// Service de configuration fiscale distante, initialise dans main().
final taxRemoteConfigServiceProvider = Provider<TaxRemoteConfigService>(
  (ref) => throw UnimplementedError(
      'taxRemoteConfigServiceProvider doit etre override dans main()'),
);

/// Configuration fiscale courante (distante si disponible, embarquee sinon).
final taxConfigProvider = Provider<TaxConfig>(
  (ref) => ref.watch(taxRemoteConfigServiceProvider).current,
);

/// Configuration des dispositifs avances Epic 8 (distante si disponible).
final advancedTaxConfigProvider = Provider<AdvancedTaxConfig>(
  (ref) => ref.watch(taxRemoteConfigServiceProvider).advancedCurrent,
);
