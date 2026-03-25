import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/foyer_fiscal_model.dart';
import 'data/models/simulation_model.dart';
import 'data/models/dispositif_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(SituationFamilialeAdapter());
  Hive.registerAdapter(FoyerFiscalModelAdapter());
  Hive.registerAdapter(RevenuModelAdapter());
  Hive.registerAdapter(SimulationModelAdapter());
  Hive.registerAdapter(ReductionModelAdapter());
  Hive.registerAdapter(CreditModelAdapter());
  Hive.registerAdapter(CategorieDispositifAdapter());
  Hive.registerAdapter(TypeDispositifAdapter());
  Hive.registerAdapter(DispositifModelAdapter());

  await Hive.openBox<FoyerFiscalModel>('foyerFiscal');
  await Hive.openBox<SimulationModel>('simulations');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: FiscalIAApp()));
}
