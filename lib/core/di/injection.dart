import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:slotr_app/core/error/exceptions.dart';
import 'package:slotr_app/core/logging/app_logger.dart';
import 'package:slotr_app/core/network/api_client.dart';
import 'package:slotr_app/core/websocket/websocket_service.dart';
import 'package:slotr_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:slotr_app/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:slotr_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:slotr_app/core/bloc/app_settings_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:slotr_app/core/storage/settings_storage_service.dart';


final getIt = GetIt.instance;

Future<void> setupInjection() async {

  if (!getIt.isRegistered<AppLogger>()) {
    final logger = await AppLogger.init();
    getIt.registerSingleton<AppLogger>(logger);
  }
  final logger = getIt<AppLogger>();
  logger.i('Setting up Dependency Injection. Log path: ${logger.logDirectoryPath ?? "Console only (Web)"}');

  if (!dotenv.isInitialized) {
    throw ConfigurationException('Configurazione non inizializzata. Assicurati che il file .env sia stato caricato correttamente.');
  }

  final baseUrl = dotenv.env['BASE_URL'];
  final wsUrl = dotenv.env['WS_URL'];

  if (baseUrl == null || baseUrl.trim().isEmpty || wsUrl == null || wsUrl.trim().isEmpty) {
    throw ConfigurationException('Parametri di configurazione mancanti nel file .env (BASE_URL e WS_URL sono obbligatori).');
  }


  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.d('HTTP [${options.method}] ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i('HTTP [${response.statusCode}] ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        final response = error.response;
        final req = error.requestOptions;

        if (response == null ||
            error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {

          logger.w(
            '⚠️ [CONNESSIONE FALLITA - SERVER NON RAGGIUNGIBILE]\n'
            '  Richiesta: [${req.method}] ${req.uri}\n'
            '  Host: ${req.baseUrl}\n'
            '  Tipo Errore: ${error.type.name}\n'
            '  Stato: Nessun codice HTTP ricevuto (backend offline o timeout)\n'
            '  Dettaglio: ${error.message ?? "Errore di rete"}',
          );
        } else {

          final statusCode = response.statusCode;
          final statusMsg = response.statusMessage ?? '';
          final data = response.data;
          final isClientError = statusCode != null && statusCode >= 400 && statusCode < 500;

          final logMsg =
              '${isClientError ? "⚠️" : "❌"} [RISPOSTA ERRORE DAL SERVER - HTTP $statusCode ${statusMsg.isNotEmpty ? statusMsg : ""}]\n'
              '  Richiesta: [${req.method}] ${req.uri}\n'
              '  Status Code: $statusCode\n'
              '  Dettagli/Body Server: $data';

          if (isClientError) {
            logger.w(logMsg);
          } else {
            logger.e(logMsg, error, error.stackTrace);
          }
        }
        return handler.next(error);
      },
    ),
  );
  getIt.registerLazySingleton(() => dio);
  getIt.registerLazySingleton(() => ApiClient(getIt()));


  getIt.registerLazySingleton(() => WebSocketService(wsUrl));


  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(apiClient: getIt()),
  );


  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => SettingsStorageService(getIt()));


  getIt.registerFactory(
    () => BookingBloc(repository: getIt(), wsService: getIt()),
  );
  getIt.registerLazySingleton(
    () => AppSettingsCubit(getIt()),
  );

  logger.d('Dependency injection configured successfully');
}
