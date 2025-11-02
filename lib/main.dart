import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/task_notification_initializer.dart';
import 'injection_imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize dependencies
  await init();

  // ✅ Setup system UI
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: SystemUiOverlay.values,
  );

  // ✅ Run app
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

  // Start notification initializer after the app is running (non-blocking).
  Future.microtask(() => TaskNotificationInitializer.run());
}
