import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/monitoring_service.dart';
import 'core/services/tax_remote_config_service.dart';
import 'presentation/providers/ads_provider.dart';
import 'presentation/providers/monitoring_providers.dart';
import 'presentation/providers/subscription_provider.dart';
import 'data/models/foyer_fiscal_model.dart';
import 'data/models/simulation_model.dart';
import 'data/models/home_employment_credit_model.dart';
import 'data/models/child_care_credit_model.dart';
import 'data/models/donation_credit_model.dart';
import 'data/models/niche_ceiling_tracker_model.dart';
import 'data/models/school_fees_credit_model.dart';
import 'data/models/union_dues_credit_model.dart';
import 'data/models/alimony_deduction_model.dart';
import 'data/models/device_distribution_model.dart';
import 'data/models/fiscal_calendar_model.dart';
import 'data/models/notification_settings_model.dart';
import 'data/models/per_tracker_model.dart';
import 'data/models/tax_document_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase : Remote Config (baremes fiscaux), Crashlytics, Analytics.
  // L'initialisation est tolerante : sans configuration Firebase valide,
  // l'app fonctionne avec les baremes embarques et sans monitoring.
  final monitoring = MonitoringService();
  TaxRemoteConfigService taxConfigService = TaxRemoteConfigService();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await monitoring.initialiser();
    taxConfigService = TaxRemoteConfigService(
      client: FirebaseRemoteConfigClient(FirebaseRemoteConfig.instance),
    );
    await taxConfigService.initialiser();
    // Recuperation des derniers baremes ; echec silencieux (fallback embarque).
    await taxConfigService.actualiser();
  } catch (e) {
    debugPrint('Firebase non disponible, mode degrade active ($e)');
  }

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(FiscalCalendarModelAdapter());
  Hive.registerAdapter(FiscalEventTypeAdapter());
  Hive.registerAdapter(NotificationSettingsModelAdapter());
  Hive.registerAdapter(PerTrackerModelAdapter());
  Hive.registerAdapter(TaxDocumentModelAdapter());

  await Hive.openBox<FoyerFiscalModel>('foyerFiscal');
  await Hive.openBox<SimulationModel>('simulations');
  await Hive.openBox<HomeEmploymentCreditModel>('homeEmploymentCredits');
  await Hive.openBox<ChildCareCreditModel>('childCareCredits');
  await Hive.openBox<DonationCreditModel>('donationCredits');
  await Hive.openBox<NicheCeilingTrackerModel>('nicheCeilingTracker');
  await Hive.openBox<SchoolFeesCreditModel>('schoolFeesCredits');
  await Hive.openBox<UnionDuesCreditModel>('unionDuesCredits');
  await Hive.openBox<AlimonyDeductionModel>('alimonyDeductions');
  await Hive.openBox<FiscalCalendarModel>('fiscalCalendar');
  await Hive.openBox<DeviceDistributionModel>('deviceDistribution');
  await Hive.openBox<NotificationSettingsModel>('notificationSettings');
  await Hive.openBox<PerTrackerModel>('perTracker');
  await Hive.openBox<TaxDocumentModel>('taxDocuments');
  await Hive.openBox('settings');

  final container = ProviderContainer(
    overrides: [
      monitoringServiceProvider.overrideWithValue(monitoring),
      taxRemoteConfigServiceProvider.overrideWithValue(taxConfigService),
    ],
  );

  // Initialisation de la monetisation (AdMob + RevenueCat). Chaque service
  // degrade gracieusement si non configure ou indisponible.
  await container.read(adMobServiceProvider).initialiser();
  await container.read(subscriptionProvider.notifier).initialiser();

  runApp(
    UncontrolledProviderScope(container: container, child: const FiscalIAApp()),
  );
}
