import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transi_flex_mobile/authentification/model/user.dart';
import 'package:transi_flex_mobile/authentification/repository/auth_repository.dart';
import 'package:transi_flex_mobile/authentification/service/user_service.dart';
import 'package:transi_flex_mobile/client/cubit/colis/colis_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/ticket/ticket_cubit.dart';
import 'package:transi_flex_mobile/client/cubit/trip/trip_search_cubit.dart';
import 'package:transi_flex_mobile/client/enums/ticket_status.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';
import 'package:transi_flex_mobile/client/repository/colis_repository.dart';
import 'package:transi_flex_mobile/client/repository/ticket_repository.dart';
import 'package:transi_flex_mobile/client/repository/trip_repository.dart';
import 'package:transi_flex_mobile/client/view/colis_page.dart';
import 'package:transi_flex_mobile/client/view/reservations_page.dart';
import 'package:transi_flex_mobile/client/view/search_page.dart';
import 'package:transi_flex_mobile/shared/profile_page.dart';

import '../../authentification/cubit/auth_cubit.dart';
import '../../authentification/model/user_role.dart';
import '../../injection.dart';
import '../../shared/action_button.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/bottom_nav_bar.dart';
import '../../shared/custom_app_bar.dart';
import '../../shared/custum_drawer.dart';
import '../../shared/travel_card.dart';
import '../cubit/mobile_app/mobile_app_cubit.dart';
import '../repository/mobile_app_repository.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({Key? key}) : super(key: key);

  @override
  _ClientHomeViewState createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  int _currentIndex = 0;
  List<Ticket>? _userTickets;

  @override
  void initState() {
    super.initState();
    // Charger les tickets de l'utilisateur
    context.read<TicketCubit>().getTicketsByUser();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onMenuTap(String route) {
    if (route == '/logout') {
      context.read<AuthCubit>().logout();
      return;
    }
    print('Navigation vers: $route');
  }

  /// Récupérer le prochain voyage (non effectué, date future)
  Ticket? _getNextTrip(List<Ticket>? tickets) {
    if (tickets == null || tickets.isEmpty) return null;

    final now = DateTime.now();

    // Filtrer les tickets avec statut PAYE ou RESERVE et date dans le futur
    final futureTickets = tickets.where((ticket) {
      if (ticket.date == null) return false;
      try {
        final tripDate = DateTime.parse(ticket.date!);
        return tripDate.isAfter(now) &&
            (ticket.status == TicketStatus.PAYE ||
                ticket.status == TicketStatus.RESERVE);
      } catch (e) {
        return false;
      }
    }).toList();

    if (futureTickets.isEmpty) return null;

    // Trier par date et heure, retourner le plus proche
    futureTickets.sort((a, b) {
      final dateA = DateTime.parse(a.date ?? '');
      final dateB = DateTime.parse(b.date ?? '');
      return dateA.compareTo(dateB);
    });

    return futureTickets.first;
  }

  /// Récupérer les voyages récents (PAYE, RESERVE, pas le prochain voyage)
  List<Ticket> _getRecentTrips(List<Ticket>? tickets) {
    if (tickets == null || tickets.isEmpty) return [];

    final nextTrip = _getNextTrip(tickets);
    final now = DateTime.now();

    // Filtrer les tickets PAYE ou RESERVE, exclure le prochain voyage
    final validTickets = tickets.where((ticket) {
      if (ticket.date == null || ticket.id == nextTrip?.id) return false;
      try {
        final tripDate = DateTime.parse(ticket.date!);
        return tripDate.isBefore(now.add(const Duration(days: 7))) &&
            (ticket.status == TicketStatus.PAYE ||
                ticket.status == TicketStatus.RESERVE);
      } catch (e) {
        return false;
      }
    }).toList();

    // Trier par date décroissante (plus récents d'abord)
    validTickets.sort((a, b) {
      final dateA = DateTime.parse(a.date ?? '');
      final dateB = DateTime.parse(b.date ?? '');
      return dateB.compareTo(dateA);
    });

    // Retourner max 3
    return validTickets.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketCubit, TicketState>(
      listener: (context, state) {
        if (state.status == TicketBuyStatus.success && state.tickets != null) {
          setState(() {
            _userTickets = state.tickets;
          });
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: CustomAppBar(
              title: 'Transi-Flex',
              notificationCount: 5,
              onNotificationTap: () {
                print('Notifications tappées');
              },
              onProfileTap: () {
                _buildProfileContent();
              },
            ),
            body: _buildBody(),
            bottomNavigationBar: CustomBottomNavigationBar(
              userRole: UserRole.CLIENT,
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      case 2:
        return _buildTripsContent();
      case 3:
        return _buidColisContent();
      case 4:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prochain voyage
          _buildNextTripSection(),

          const SizedBox(height: AppStyles.spacingL),

          // Actions rapides
          _buildQuickActions(),

          const SizedBox(height: AppStyles.spacingL),

          // Voyages récents
          _buildRecentTrips(),
        ],
      ),
    );
  }

  Widget _buildNextTripSection() {
    final nextTrip = _getNextTrip(_userTickets);

    if (nextTrip == null) {
      return Container(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        decoration: AppStyles.cardDecoration,
        child: Center(
          child: Text(
            'Aucun voyage à venir',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final tripDate = DateTime.parse(nextTrip.date ?? '');
    final formattedDate = '${tripDate.day}/${tripDate.month}/${tripDate.year}';

    return TravelCard(
      title: 'Prochain Voyage',
      route: nextTrip.trajet!.nom ?? "",
      price: nextTrip.prix!.toInt(),
      currency: 'CFA',
      date: formattedDate,
      time: "${formatHeure(nextTrip.heureDepart!)} h",
      seatInfo: "Demain à ${formatHeure(nextTrip.heureDepart!)} h",
      status: TravelStatus.confirmed,
      onDetailsTap: () {
        _showDetails(nextTrip);
      },
      onModifyTap: () {
        print('Modifier le prochain voyage');
      },
    );
  }



  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppStyles.h3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.search,
                title: 'Rechercher',
                subtitle: 'Nouveau trajet',
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: ActionButton(
                icon: Icons.local_shipping,
                title: 'Envoyer Colis',
                subtitle: 'Expédition rapide',
                onTap: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                },
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTrips() {
    final recentTrips = _getRecentTrips(_userTickets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Voyages Récents',
              style: AppStyles.h3.copyWith(fontSize: 18),
            ),
            if (recentTrips.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: Text(
                  'Voir tout',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingS),
        if (recentTrips.isEmpty)
          Center(
            child: Text(
              'Aucun voyage récent',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          )
        else
          ...recentTrips.map((trip) {
            final tripDate = DateTime.parse(trip.date ?? '');
            return Padding(
              padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
              child: GestureDetector(
                onTap: () {
                  print('Détails voyage: ${trip.numero}');
                },
                child: Container(
                  padding: const EdgeInsets.all(AppStyles.spacingM),
                  decoration: AppStyles.cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trip.clientNom} ${trip.clientPrenom}',
                              style: AppStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tripDate.day}/${tripDate.month}/${tripDate.year} • ${trip.heureDepart}',
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(trip.status?.name)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trip.status?.name ?? 'N/A',
                          style: AppStyles.caption.copyWith(
                            color: _getStatusColor(trip.status?.name),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAYE':
        return AppColors.statusConfirmed;
      case 'RESERVE':
        return AppColors.statusPending;
      case 'UTILISÉ':
        return AppColors.statusCompleted;
      case 'ANNULÉ':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildSearchContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (_) =>
                      TripSearchCubit(repository: sl<TripSearchRepository>()),
                  child: const SearchPage(),
                )),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    });

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildTripsContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (_) =>
                      TicketCubit(repository: sl<TicketRepository>()),
                  child: const ReservationsPage(),
                )),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
          // Recharger les tickets
          context.read<TicketCubit>().getTicketsByUser();
        });
      });
    });

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buidColisContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
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
              child: ColisPage(),
            ),
        )
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    });

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildProfileContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dynamic currentUser;
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        currentUser = authState.user;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => AuthCubit(
              authRepository: sl<AuthRepository>(),
            ),
            child: ProfilePage(user: currentUser),
          ),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    });

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  void _showDetails(Ticket ticket) {
    final tripDate = DateTime.parse(ticket.date ?? '');
    final formattedDate = '${tripDate.day}/${tripDate.month}/${tripDate.year}';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppStyles.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du ticket',
              style: AppStyles.h3,
            ),
            const SizedBox(height: AppStyles.spacingM),
            _buildDetailRow('Numéro', ticket.numero ?? 'N/A'),
            _buildDetailRow('Nom', ticket.user?.lastName ?? 'N/A'),
            _buildDetailRow('Prénom', ticket.user?.firstName ?? 'N/A'),
            _buildDetailRow('Contact', ticket.clientContact ?? 'N/A'),
            _buildDetailRow('Date', formattedDate),
            _buildDetailRow('Heure', ticket.heureDepart ?? 'N/A'),
            _buildDetailRow('Prix', '${ticket.prix?.toInt()} CFA'),
            _buildDetailRow('Type', ticket.typeTransaction ?? 'N/A'),
            _buildDetailRow('Statut', ticket.status?.name ?? 'N/A'),
            if (ticket.dateLimitePaiement != null)
              _buildDetailRow(
                  'Limite paiement', ticket.dateLimitePaiement ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String formatHeure(String heure) {
    if (heure.isEmpty) return '';

    final parts = heure.split(':');
    final h = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '00';
    final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';

    return '$h:$m';
  }

}
