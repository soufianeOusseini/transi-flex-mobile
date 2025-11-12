import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  bool _isDownloading = false;
  int? _downloadingTicketId;

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
      body: BlocListener<TicketCubit, TicketState>(
        listener: (context, state) {
          // Gérer le téléchargement du PDF
          if (state.status == TicketBuyStatus.pdf_downloaded) {
            _savePdfToDevice(state.pdfBytes!);
          } else if (state.status == TicketBuyStatus.transaction_success) {
            // Après le paiement réussi d'une réservation
            _showDownloadReceiptDialog();
          } else if (state.status == TicketBuyStatus.error) {
            setState(() {
              _isDownloading = false;
              _downloadingTicketId = null;
            });
            _showErrorSnackBar(state.errorMessage ?? 'Erreur inconnue');
          }
        },
        child: BlocBuilder<TicketCubit, TicketState>(
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
    final isDownloadingThis = _isDownloading && _downloadingTicketId == ticket.id;

    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête: Trajet et Statut
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

                // Prix en dessous du statut
                Text(
                  '${ticket.prix?.toInt()} CFA',
                  style: AppStyles.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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

                // Boutons en bas
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDetails(ticket),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Détails'),
                        style: AppStyles.outlineButton.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppStyles.spacingS),
                    if (ticket.status == TicketStatus.RESERVE)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmReservation(ticket),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Payer'),
                          style: AppStyles.primaryButton.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.statusConfirmed,
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      )
                    else if (ticket.status == TicketStatus.PAYE) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isDownloadingThis
                              ? null
                              : () => _downloadTicketPdf(ticket.id!),
                          icon: isDownloadingThis
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                              : const Icon(Icons.print, size: 16),
                          label: Text(isDownloadingThis ? 'Chargement...' : 'Imprimer'),
                          style: AppStyles.primaryButton.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.primary,
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppStyles.spacingS),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _cancelTicket(ticket),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Annuler'),
                          style: AppStyles.primaryButton.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.statusCancelled,
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  void _confirmReservation(Ticket ticket) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPaymentBottomSheet(ticket),
    );

    if (result != null) {
      final paymentMethod = result['method']!;
      final network = result['network'];

      if (paymentMethod == 'MOBILE' && network != null) {
        // Lancer le paiement mobile
        context.read<TicketCubit>().makeDeposit(
          phone: ticket.clientContact ?? '',
          amount: ticket.prix!.toInt(),
          network: network,
        );
      } else {
        // Confirmer directement (espèces)
        context.read<TicketCubit>().confirmReservation(ticket.id!, paymentMethod);
      }
    }
  }

  Widget _buildPaymentBottomSheet(Ticket ticket) {
    String? selectedPayment;
    String? selectedNetwork;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppStyles.spacingL,
            right: AppStyles.spacingL,
            top: AppStyles.spacingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confirmer le paiement', style: AppStyles.h3),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),
              Container(
                padding: const EdgeInsets.all(AppStyles.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Trajet', ticket.trajet?.nom ?? 'N/A'),
                    _buildDetailRow('Montant', '${ticket.prix?.toInt()} CFA'),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.spacingM),
              Text('Mode de paiement', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppStyles.spacingS),
              DropdownButtonFormField<String>(
                value: selectedPayment,
                decoration: AppStyles.inputDecoration('Sélectionner'),
                items: ['ESPECES', 'MOBILE'].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method == 'ESPECES' ? 'Espèces' : 'Paiement mobile'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPayment = value;
                    selectedNetwork = null;
                  });
                },
              ),
              if (selectedPayment == 'MOBILE') ...[
                const SizedBox(height: AppStyles.spacingM),
                Text('Réseau mobile', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppStyles.spacingS),
                DropdownButtonFormField<String>(
                  value: selectedNetwork,
                  decoration: AppStyles.inputDecoration('Choisir'),
                  items: ['TMONEY', 'FLOOZ'].map((network) {
                    return DropdownMenuItem(
                      value: network,
                      child: Text(network),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedNetwork = value);
                  },
                ),
              ],
              const SizedBox(height: AppStyles.spacingL),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey400,
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (selectedPayment != null &&
                          (selectedPayment != 'MOBILE' || selectedNetwork != null))
                          ? () {
                        Navigator.pop(context, {
                          'method': selectedPayment!,
                          if (selectedNetwork != null) 'network': selectedNetwork!,
                        });
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusConfirmed,
                      ),
                      child: const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),
            ],
          ),
        );
      },
    );
  }

  void _showDownloadReceiptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Paiement réussi!'),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Votre réservation a été confirmée avec succès.'),
            SizedBox(height: 16),
            Text('Voulez-vous télécharger votre reçu?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TicketCubit>().getTicketsByUser();
            },
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Récupérer le dernier ticket payé
              final state = context.read<TicketCubit>().state;
              if (state.tickets != null && state.tickets!.isNotEmpty) {
                final lastTicket = state.tickets!.last;
                if (lastTicket.id != null) {
                  _downloadTicketPdf(lastTicket.id!);
                }
              }
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  void _downloadTicketPdf(int ticketId) {
    setState(() {
      _isDownloading = true;
      _downloadingTicketId = ticketId;
    });
    context.read<TicketCubit>().downloadTicketPdf(ticketId);
  }

  Future<void> _savePdfToDevice(Uint8List pdfBytes) async {
    try {
      // Demander les permissions selon la version d'Android
      if (Platform.isAndroid) {
        final androidInfo = await getAndroidVersion();
        PermissionStatus status;

        if (androidInfo >= 33) {
          // Android 13+ (API 33+) - Pas besoin de permission pour Downloads
          status = PermissionStatus.granted;
        } else {
          // Android 12 et inférieur
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted && androidInfo < 33) {
          setState(() {
            _isDownloading = false;
            _downloadingTicketId = null;
          });
          _showErrorSnackBar('Permission de stockage refusée');
          return;
        }
      }

      // Obtenir le répertoire de téléchargement
      Directory? directory;
      if (Platform.isAndroid) {
        // Utiliser le dossier Downloads public
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback vers le répertoire externe de l'app
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        setState(() {
          _isDownloading = false;
          _downloadingTicketId = null;
        });
        _showErrorSnackBar('Impossible d\'accéder au stockage');
        return;
      }

      // Créer le nom du fichier
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ticket_recu_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // Écrire le fichier
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      setState(() {
        _isDownloading = false;
        _downloadingTicketId = null;
      });

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reçu téléchargé: $fileName'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Ouvrir',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFile.open(filePath);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du PDF: $e');
      setState(() {
        _isDownloading = false;
        _downloadingTicketId = null;
      });
      _showErrorSnackBar('Erreur lors de la sauvegarde du PDF: ${e.toString()}');
    }
  }

  // Fonction pour obtenir la version Android
  Future<int> getAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
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
            child: const Text('Non'),
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
              'Oui, annuler',
              style: TextStyle(color: AppColors.statusCancelled),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.statusCancelled,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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