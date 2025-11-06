import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transi_flex_mobile/client/cubit/ticket/ticket_cubit.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';
import 'package:transi_flex_mobile/client/repository/trip_repository.dart';
import 'package:transi_flex_mobile/injection.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/custom_app_bar.dart';
import '../enums/ticket_status.dart';
import 'search_page.dart';
import 'package:transi_flex_mobile/client/cubit/trip/trip_search_cubit.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TicketCubit>().getTicketsByUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Ticket> _getActiveTickets(List<Ticket>? tickets) {
    if (tickets == null) return [];

    final now = DateTime.now();

    return tickets.where((ticket) {
      if (ticket.date == null) return false;
      try {
        final tripDate = DateTime.parse(ticket.date!);
        return tripDate.isAfter(now) &&
            (ticket.status == TicketStatus.PAYE ||
                ticket.status == TicketStatus.RESERVE);
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.date ?? '');
        final dateB = DateTime.parse(b.date ?? '');
        return dateA.compareTo(dateB);
      });
  }

  List<Ticket> _getPastTickets(List<Ticket>? tickets) {
    if (tickets == null) return [];

    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(days: 1));

    return tickets.where((ticket) {
      if (ticket.date == null) return false;
      try {
        final tripDate = DateTime.parse(ticket.date!);
        return tripDate.isBefore(oneDayAgo) &&
            (ticket.status == TicketStatus.PAYE ||
                ticket.status == TicketStatus.RESERVE ||
                ticket.status == TicketStatus.UTILISE);
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.date ?? '');
        final dateB = DateTime.parse(b.date ?? '');
        return dateB.compareTo(dateA);
      });
  }

  List<Ticket> _getCancelledTickets(List<Ticket>? tickets) {
    if (tickets == null) return [];

    return tickets.where((ticket) {
      return ticket.status == TicketStatus.ANNULE ||
          ticket.status == TicketStatus.EXPIRE;
    }).toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.date ?? '');
        final dateB = DateTime.parse(b.date ?? '');
        return dateB.compareTo(dateA);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: const CustomAppBar(
        title: 'Mes Réservations',
        showBackButton: true,
      ),
      body: BlocBuilder<TicketCubit, TicketState>(
        builder: (context, state) {
          if (state.status == TicketBuyStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state.status == TicketBuyStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.statusCancelled,
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  Text(
                    'Erreur',
                    style: AppStyles.h3.copyWith(
                      color: AppColors.statusCancelled,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingS),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.spacingM),
                    child: Text(
                      state.errorMessage ?? 'Une erreur est survenue',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TicketCubit>().getTicketsByUser();
                    },
                    style: AppStyles.primaryButton,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: _buildTabBarView(state.tickets),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mes Réservations',
            style: AppStyles.h2.copyWith(fontSize: 24),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocProvider(
                          create: (_) => TripSearchCubit(
                              repository: sl<TripSearchRepository>()),
                          child: const SearchPage(),
                        )),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nouvelle'),
            style: AppStyles.primaryButton.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.black),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppStyles.bodyMedium,
        tabs: const [
          Tab(text: 'Actives'),
          Tab(text: 'Passées'),
          Tab(text: 'Annulées'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(List<Ticket>? allTickets) {
    final activeTickets = _getActiveTickets(allTickets);
    final pastTickets = _getPastTickets(allTickets);
    final cancelledTickets = _getCancelledTickets(allTickets);

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReservationsList(activeTickets),
        _buildReservationsList(pastTickets),
        _buildReservationsList(cancelledTickets),
      ],
    );
  }

  Widget _buildReservationsList(List<Ticket> reservations) {
    if (reservations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      itemCount: reservations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppStyles.spacingM),
      itemBuilder: (context, index) {
        return _buildReservationCard(reservations[index]);
      },
    );
  }

  Widget _buildReservationCard(Ticket ticket) {
    final tripDate = DateTime.parse(ticket.date ?? '');
    final formattedDate = '${tripDate.day}/${tripDate.month}/${tripDate.year}';
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${ticket.trajet?.nom}",
                        style: AppStyles.h3.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.status == TicketStatus.PAYE
                            ? AppColors.statusConfirmed
                            : ticket.status == TicketStatus.RESERVE
                                ? AppColors.statusPending
                                : ticket.status == TicketStatus.ANNULE
                                    ? AppColors.statusCompleted
                                    : ticket.status == TicketStatus.EXPIRE
                                        ? AppColors.statusCancelled
                                        : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ticket.status == TicketStatus.PAYE
                              ? AppColors.statusConfirmed
                              : ticket.status == TicketStatus.RESERVE
                                  ? AppColors.statusPending
                                  : ticket.status == TicketStatus.ANNULE
                                      ? AppColors.statusCompleted
                                      : ticket.status == TicketStatus.EXPIRE
                                          ? AppColors.statusCancelled
                                          : Colors.blue,
                        ),
                      ),
                      child: Text(
                        "${ticket.status?.name}",
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppStyles.spacingS),

                // Date et heure
                Text(
                  '${formattedDate} à ${ticket.heureDepart}',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppStyles.spacingM),

                // Prix et boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ticket.prix?.toInt()} CFA',
                      style: AppStyles.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showDetails(ticket),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Détails'),
                          style: AppStyles.outlineButton.copyWith(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppStyles.spacingS),
                        if (ticket.status == TicketStatus.RESERVE)
                          ElevatedButton.icon(
                            onPressed: () => _confirmReservation(ticket),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Payer'),
                            style: AppStyles.primaryButton.copyWith(
                              backgroundColor: MaterialStateProperty.all(
                                AppColors.statusConfirmed,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          )
                        else if (ticket.status == TicketStatus.PAYE)
                          ElevatedButton.icon(
                            onPressed: () => _cancelTicket(ticket),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Annuler'),
                            style: AppStyles.primaryButton.copyWith(
                              backgroundColor: MaterialStateProperty.all(
                                AppColors.statusCancelled,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_online,
              color: AppColors.grey500,
              size: 40,
            ),
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            'Aucune réservation',
            style: AppStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            'Vous n\'avez pas encore de réservations dans cette catégorie',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.spacingL),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BlocProvider(
                          create: (_) => TripSearchCubit(
                              repository: sl<TripSearchRepository>()),
                          child: const SearchPage(),
                        )),
              );
            },
            style: AppStyles.primaryButton,
            child: const Text('Faire une réservation'),
          ),
        ],
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

  void _confirmReservation(Ticket ticket) {
    final ticketCubit = context.read<TicketCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: const Text(
            'Voulez-vous confirmer cette réservation et procéder au paiement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ticket.id != null) {
                ticketCubit
                    .confirmReservation(ticket.id!, 'CASH');
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Réservation confirmée'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: AppColors.statusConfirmed),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelTicket(Ticket ticket) {
    final ticketCubit = context.read<TicketCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le ticket'),
        content: Text(
            'Êtes-vous sûr de vouloir annuler le ticket #${ticket.numero}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ticket.id != null) {
                ticketCubit.cancelTicket(ticket.id!);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket annulé'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.statusCancelled),
            ),
          ),
        ],
      ),
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
      case 'EXPIRE':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }
}
