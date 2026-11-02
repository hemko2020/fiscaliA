import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/app.dart';
import 'package:fiscalia/core/services/monitoring_service.dart';
import 'package:fiscalia/core/services/tax_remote_config_service.dart';
import 'package:fiscalia/presentation/providers/monitoring_providers.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        monitoringServiceProvider.overrideWithValue(MonitoringService()),
        taxRemoteConfigServiceProvider
            .overrideWithValue(TaxRemoteConfigService()),
      ],
      child: const FiscalIAApp(),
    ));
    expect(find.text('FiscalIA'), findsOneWidget);
  });
}
