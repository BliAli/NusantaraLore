import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/database/hive_service.dart';
import 'core/security/encryption_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await HiveService.init();
  await EncryptionService.initAesKey();

  runApp(
    const ProviderScope(
      child: NusantaraLoreApp(),
    ),
  );
}
