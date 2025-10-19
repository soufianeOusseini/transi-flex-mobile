import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transi_flex_mobile/app_config.dart';
import 'package:transi_flex_mobile/authentification/datasource/user_datasource.dart';
import 'package:transi_flex_mobile/authentification/repository/auth_repository.dart';
import 'package:transi_flex_mobile/authentification/service/auth_service.dart';
import 'package:transi_flex_mobile/authentification/service/user_service.dart';
import 'package:transi_flex_mobile/client/cubit/colis/colis_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/mobile_app/mobile_app_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/ticket/ticket_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/trip/trip_search_cubit.dart';
import 'package:transi_flex_mobile/client/datasource/colis_data_source.dart';
import 'package:transi_flex_mobile/client/datasource/mobile_app_data_source.dart';
import 'package:transi_flex_mobile/client/datasource/ticket_data_source.dart';
import 'package:transi_flex_mobile/client/datasource/trip_data_source.dart';
import 'package:transi_flex_mobile/client/repository/colis_repository.dart';
import 'package:transi_flex_mobile/client/repository/mobile_app_repository.dart';
import 'package:transi_flex_mobile/client/repository/ticket_repository.dart';
import 'package:transi_flex_mobile/client/repository/trip_repository.dart';

import 'authentification/cubit/auth_cubit.dart';
import 'authentification/datasource/auth_local_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== EXTERNAL (en premier) ==========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // ========== AUTH SERVICE (avant tout le reste) ==========
  sl.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(sharedPreferences: sl()),
  );

  // ========== CUBITS ==========
  sl.registerFactory(() => AuthCubit(authRepository: sl()));
  sl.registerFactory(() => MobileAppCubit(repository: sl()));
  sl.registerFactory<TripSearchCubit>(() => TripSearchCubit(repository: sl()));
  sl.registerFactory<ColisCubit>(() => ColisCubit(repository: sl(), userService: sl()));
  sl.registerFactory<TicketCubit>(() => TicketCubit(repository: sl()));
  // ========== REPOSITORIES ==========
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<TripSearchRepository>(
        () => TripSearchRepository(tripSearchDataSource: sl()),
  );

  sl.registerLazySingleton<MobileAppRepository>(
        () => MobileAppRepository(mobileAppDataSource: sl()),
  );

  sl.registerLazySingleton<ColisRepository>(
        () => ColisRepository(colisDataSource: sl()),
  );

  sl.registerLazySingleton<UserService>(
        () => UserServiceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<TicketRepository>(
        () => TicketRepository(ticketDataSource: sl()),
  );
  // ========== DATA SOURCES ==========
  sl.registerLazySingleton<MobileAppDataSource>(
        () => MobileAppDataSourceImpl(
      client: sl(),
      authService: sl(),
    ),
  );

  // ✅ CORRECTION: Injecter AuthService dans AuthRemoteDataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      client: sl(),
      authService: sl(), // ✅ AJOUTÉ
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<TripSearchDataSource>(
        () => TripSearchDataSourceImpl(
      client: sl<Dio>(),
      authService: sl<AuthService>(),
    ),
  );


  sl.registerLazySingleton<ColisDataSource>(
        () => ColisDataSourceImpl(
      client: sl<Dio>(),
      authService: sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton<TicketDataSource>(
        () => TicketDataSourceImpl(
      client: sl<Dio>(),
      authService: sl<AuthService>(),
    ),
  );
  // ========== DIO AVEC INTERCEPTEUR ==========
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ✅ ENDPOINTS QUI NE NÉCESSITENT PAS D'AUTHENTIFICATION
    final publicEndpoints = [
      '/authentication/register',
      '/authentication/login',
      '/authentication/refresh-token', // si applicable
    ];

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Vérifier si l'endpoint est public
          bool isPublic = publicEndpoints.any((path) =>
              options.path.contains(path)
          );

          if (!isPublic) {
            // Ajouter le token SEULEMENT pour les endpoints protégés
            final authService = sl<AuthService>();
            final token = await authService.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('🔐 Token ajouté: ${token.substring(0, 20)}...');
            } else {
              print('⚠️ Aucun token disponible');
            }
          } else {
            print('🔓 Endpoint public, pas de token');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          print('❌ Erreur API: ${error.response?.statusCode} - ${error.message}');

          if (error.response?.statusCode == 401) {
            print('🚫 Token expiré ou invalide');

            final authService = sl<AuthService>();
            await authService.removeTokens();
          }

          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('✅ Réponse: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );

    return dio;
  });
}