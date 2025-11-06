import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:transi_flex_mobile/authentification/auth_page.dart';
import 'package:transi_flex_mobile/client/cubit/mobile_app/mobile_app_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/trip/trip_search_cubit.dart';

import 'authentification/cubit/auth_cubit.dart';
import 'client/cubit/colis/colis_cubit.dart';
import 'client/cubit/ticket/ticket_cubit.dart';
import 'client/repository/mobile_app_repository.dart';
import 'client/view/client_home_view.dart';
import 'injection.dart';
import 'shared/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  // Initialiser les dépendances
  await init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transi-Flex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF0D6EFD, {
          50: AppColors.primary.withOpacity(0.1),
          100: AppColors.primary.withOpacity(0.2),
          200: AppColors.primary.withOpacity(0.3),
          300: AppColors.primary.withOpacity(0.4),
          400: AppColors.primary.withOpacity(0.5),
          500: AppColors.primary,
          600: AppColors.primaryDark,
          700: AppColors.primaryDark,
          800: AppColors.primaryDark,
          900: AppColors.primaryDark,
        }),
        scaffoldBackgroundColor: AppColors.grey50,
        cardColor: AppColors.cardBackground,
        dividerColor: AppColors.divider,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AppColors.textPrimary),
          headlineMedium: TextStyle(color: AppColors.textPrimary),
          headlineSmall: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => MobileAppCubit(repository: sl<MobileAppRepository>()),
          ),
          BlocProvider(
            create: (context) => sl<TripSearchCubit>(),
          ),
          BlocProvider(
            create: (context) => sl<ColisCubit>(),
          ),
          BlocProvider(
            create: (context) => sl<TicketCubit>(),
          ),
        ],
        child: AuthWrapper(),
      ),
      routes: {
        '/auth': (context) => BlocProvider(
          create: (context) => sl<AuthCubit>(),
          child: const AuthPage(),
        ),
        '/home': (context) => BlocProvider(
    create: (context) => sl<AuthCubit>(),
    child: const HomePage()),
      },
    );
  }
}

// Wrapper pour gérer l'état d'authentification global
class AuthWrapper extends StatelessWidget {
  final GetStorage _getStorage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppColors.grey50,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          context.read<MobileAppCubit>().getMobileAppState();
          context.read<TicketCubit>().getTicketsByUser();
          return const HomePage();
        } else {
          return BlocProvider.value(
            value: context.read<AuthCubit>(),
            child: const AuthPage(),
          );
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {

          return const ClientHomeView();

          }

        return const Scaffold(
          backgroundColor: AppColors.grey50,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      },
    );
  }
}