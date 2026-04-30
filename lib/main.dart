import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/hive_service.dart';
import 'core/security/encryption_service.dart';
import 'core/utils/notification_service.dart';
import 'features/explore/data/budaya_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await HiveService.init();
  await EncryptionService.initAesKey();
  await NotificationService.init();
  await NotificationService.requestPermission();
  await NotificationService.setupDailyReminders();
  await initializeDateFormatting('id_ID');

  await BudayaRepository().populateFromJson();

  runApp(
    const ProviderScope(
      child: NusantaraLoreApp(),
    ),
  );
}
