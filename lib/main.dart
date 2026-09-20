import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:slotr_app/core/di/injection.dart';
import 'package:slotr_app/core/error/config_error_page.dart';
import 'package:slotr_app/core/error/exceptions.dart';
import 'package:slotr_app/core/logging/app_logger.dart';
import 'package:slotr_app/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:slotr_app/l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slotr_app/core/bloc/app_settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await AppLogger.init();


  FlutterError.onError = (FlutterErrorDetails details) {
    log.e(
      'Flutter error: ${details.summary}',
      details.exception,
      details.stack,
    );
  };


  try {
    await dotenv.load(fileName: ".env");

    final baseUrl = dotenv.env['BASE_URL'];
    final wsUrl = dotenv.env['WS_URL'];
    if (baseUrl == null || baseUrl.trim().isEmpty || wsUrl == null || wsUrl.trim().isEmpty) {
      throw ConfigurationException(
        'Il file .env è presente ma incompleto. Le variabili BASE_URL e WS_URL sono obbligatorie.',
      );
    }

    log.d('.env configuration loaded successfully');


    await setupInjection();


    await getIt<AppSettingsCubit>().loadSettings();

    log.i('Launching SlotrApp...');
    runApp(const SlotrApp());
  } catch (e, st) {
    log.e('Errore critico di configurazione: impossibile caricare il file .env', e, st);
    runApp(ConfigErrorApp(
      errorMessage: e is ConfigurationException ? e.message : e.toString(),
      onRetry: () => main(),
    ));
  }
}

class SlotrApp extends StatelessWidget {
  const SlotrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppSettingsCubit>(),
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Slotr',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
