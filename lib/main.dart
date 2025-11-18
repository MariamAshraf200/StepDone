import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_bootstrapper.dart';
import 'feature/Notification/data/local_notification_service.dart';
import 'injection_imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: SystemUiOverlay.values,
  );
  await AndroidAlarmManager.initialize();
  await LocalNotificationService.init();

  await init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeModeCubit>(create: (_) => ThemeModeCubit()),
        BlocProvider<PaletteCubit>(create: (_) => PaletteCubit()),
        BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
      ],
      child: const AppBootstrapper(),
    ),
  );
}
