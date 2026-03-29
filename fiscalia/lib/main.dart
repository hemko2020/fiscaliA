import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/foyer_fiscal_model.dart';
import 'data/models/simulation_model.dart';
import 'data/models/home_employment_credit_model.dart';
import 'data/models/child_care_credit_model.dart';
import 'data/models/donation_credit_model.dart';
import 'data/models/niche_ceiling_tracker_model.dart';
import 'data/models/school_fees_credit_model.dart';
import 'data/models/union_dues_credit_model.dart';
import 'data/models/alimony_deduction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox<FoyerFiscalModel>('foyerFiscal');
  await Hive.openBox<SimulationModel>('simulations');
  await Hive.openBox<HomeEmploymentCreditModel>('homeEmploymentCredits');
  await Hive.openBox<ChildCareCreditModel>('childCareCredits');
  await Hive.openBox<DonationCreditModel>('donationCredits');
  await Hive.openBox<NicheCeilingTrackerModel>('nicheCeilingTracker');
  await Hive.openBox<SchoolFeesCreditModel>('schoolFeesCredits');
  await Hive.openBox<UnionDuesCreditModel>('unionDuesCredits');
  await Hive.openBox<AlimonyDeductionModel>('alimonyDeductions');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: FiscalIAApp()));
}
