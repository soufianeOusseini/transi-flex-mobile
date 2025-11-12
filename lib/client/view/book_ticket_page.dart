import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:transi_flex_mobile/client/cubit/ticket/ticket_cubit.dart';
import 'package:transi_flex_mobile/client/enums/ticket_status.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';
import 'package:transi_flex_mobile/client/model/trip_result.dart';
import 'package:transi_flex_mobile/client/model/deposit_response.dart';
import 'package:transi_flex_mobile/authentification/model/user.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/custom_app_bar.dart';

class BookTicketPage extends StatefulWidget {
  final TripResult trip;
  final User currentUser;

  const BookTicketPage({
    Key? key,
    required this.trip,
    required this.currentUser,
  }) : super(key: key);

  @override
  _BookTicketPageState createState() => _BookTicketPageState();
}

class _BookTicketPageState extends State<BookTicketPage> {
  String? _selectedType;
  String? _selectedPayment;
  String? _selectedMobileNetwork;
  int? _selectedSeat;
  List<int> _occupiedSeats = [];
  bool _isLoadingSeats = true;
  int? _createdTicketId;
  bool _isDownloadingPdf = false;

  final List<String> _paymentMethods = ['ESPECES', 'MOBILE'];
  final List<String> _mobileNetworks = ['TMONEY', 'FLOOZ'];

  @override
  void initState() {
    super.initState();
    _loadOccupiedSeats();
  }

  void _loadOccupiedSeats() {
    final dateString = widget.trip.dateDepart.toIso8601String().split('T')[0];
    context.read<TicketCubit>().getOccupiedSeats(widget.trip.scheduleId!);
  }

  List<int> _getAvailableSeats() {
    final busCapacity = widget.trip.bus?.capacity ?? 50;
    return List.generate(busCapacity, (i) => i + 1)
        .where((seat) => !_occupiedSeats.contains(seat))
        .toList();
  }

  int? _getNextAvailableSeat() {
    final available = _getAvailableSeats();
    return available.isNotEmpty ? available.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: const CustomAppBar(
        title: 'Réserver un ticket',
        showBackButton: true,
      ),
      body: BlocListener<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state.status == TicketBuyStatus.payment_success) {
            _showPaymentDialog(state.depositResponse!);
          } else if (state.status == TicketBuyStatus.transaction_success) {
            _createTicketAfterPayment();
          } else if (state.status == TicketBuyStatus.success) {
            // Récupérer l'ID du ticket créé
            if (state.tickets != null && state.tickets!.isNotEmpty) {
              _createdTicketId = state.tickets!.last.id;
            }
            _showSuccessDialog();
          } else if (state.status == TicketBuyStatus.pdf_downloaded) {
            _savePdfToDevice(state.pdfBytes!);
          } else if (state.status == TicketBuyStatus.seats_loaded) {
            setState(() {
              _occupiedSeats = state.occupiedSeats ?? [];
              _isLoadingSeats = false;
              if (_selectedSeat == null) {
                _selectedSeat = _getNextAvailableSeat();
              }
            });
          } else if (state.status == TicketBuyStatus.error) {
            setState(() {
              _isDownloadingPdf = false;
            });
            _showErrorSnackBar(state.errorMessage ?? 'Erreur inconnue');
          }
        },
        child: _isLoadingSeats
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildTripDetails(),
              _buildTransactionTypeSection(),
              if (_selectedType != null) _buildSeatSelectionSection(),
              if (_selectedType == 'ACHAT') _buildPaymentSection(),
              if (_selectedType != null) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingM),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails du trajet', style: AppStyles.h3),
          const SizedBox(height: AppStyles.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.trip.trajet.villeDepart} → ${widget.trip.trajet.villeArrive}',
                      style: AppStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.trip.dateDepart.toLocal().toString().split(' ')[0]} à ${widget.trip.heureDepart.format(context)}',
                      style: AppStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.trip.prix.toStringAsFixed(0)} CFA',
                    style: AppStyles.h3.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    '${widget.trip.placesDisponibles} places',
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type de transaction', style: AppStyles.h3),
          const SizedBox(height: AppStyles.spacingM),
          _buildRadioTile(
            'ACHAT',
            'Achat immédiat',
            'Paiement maintenant',
            Icons.shopping_cart,
          ),
          const SizedBox(height: AppStyles.spacingS),
          _buildRadioTile(
            'RESERVATION',
            'Réservation',
            'Payer dans 24 heures',
            Icons.bookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String value, String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
          _selectedPayment = null;
          _selectedMobileNetwork = null;
          if (_selectedSeat == null) {
            _selectedSeat = _getNextAvailableSeat();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        decoration: BoxDecoration(
          color: _selectedType == value ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: _selectedType == value ? AppColors.primary : AppColors.grey300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedType,
              onChanged: (val) {
                setState(() {
                  _selectedType = val;
                  _selectedPayment = null;
                  _selectedMobileNetwork = null;
                  if (_selectedSeat == null) {
                    _selectedSeat = _getNextAvailableSeat();
                  }
                });
              },
            ),
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelectionSection() {
    final availableSeats = _getAvailableSeats();
    final busCapacity = widget.trip.bus?.capacity ?? 50;

    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingM),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sélection du siège', style: AppStyles.h3),
            ],
          ),
          Row(
            children: [
              _buildSeatLegend(AppColors.success, 'Disponible'),
              const SizedBox(width: 8),
              _buildSeatLegend(AppColors.statusCancelled, 'Occupé'),
              const SizedBox(width: 8),
              _buildSeatLegend(AppColors.primary, 'Sélectionné'),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: busCapacity,
            itemBuilder: (context, index) {
              final seatNumber = index + 1;
              final isOccupied = _occupiedSeats.contains(seatNumber);
              final isSelected = _selectedSeat == seatNumber;

              return InkWell(
                onTap: isOccupied
                    ? null
                    : () {
                  setState(() {
                    _selectedSeat = seatNumber;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? AppColors.statusCancelled
                        : isSelected
                        ? AppColors.primary
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$seatNumber',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppStyles.spacingM),
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSeatInfo('Disponibles', availableSeats.length, AppColors.success),
                _buildSeatInfo('Occupés', _occupiedSeats.length, AppColors.statusCancelled),
                _buildSeatInfo('Total', busCapacity, AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppStyles.bodySmall),
      ],
    );
  }

  Widget _buildSeatInfo(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppStyles.h3.copyWith(color: color, fontSize: 20),
        ),
        Text(label, style: AppStyles.bodySmall),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingM),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mode de paiement', style: AppStyles.h3),
          const SizedBox(height: AppStyles.spacingM),
          DropdownButtonFormField<String>(
            value: _selectedPayment,
            decoration: AppStyles.inputDecoration('Sélectionner'),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(_getPaymentMethodLabel(method)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPayment = value;
                _selectedMobileNetwork = null;
              });
            },
          ),
          if (_selectedPayment == 'MOBILE') ...[
            const SizedBox(height: AppStyles.spacingM),
            Text('Réseau mobile', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppStyles.spacingS),
            DropdownButtonFormField<String>(
              value: _selectedMobileNetwork,
              decoration: AppStyles.inputDecoration('Choisir le réseau'),
              items: _mobileNetworks.map((network) {
                return DropdownMenuItem(
                  value: network,
                  child: Row(
                    children: [
                      Icon(
                        network == 'TMONEY' ? Icons.phone_android : Icons.smartphone,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(network),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedMobileNetwork = value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingM),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey400,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: ElevatedButton(
              onPressed: _canSubmit() ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == 'ACHAT'
                    ? AppColors.statusConfirmed
                    : AppColors.statusPending,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_selectedType == 'ACHAT' ? 'Acheter' : 'Réserver'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    if (_selectedType == null || _selectedSeat == null) return false;
    if (_selectedType == 'ACHAT') {
      if (_selectedPayment == null) return false;
      if (_selectedPayment == 'MOBILE' && _selectedMobileNetwork == null) return false;
    }
    return true;
  }

  void _handleSubmit() {
    if (_selectedType == 'ACHAT' && _selectedPayment == 'MOBILE') {
      // Lancer le paiement mobile
      context.read<TicketCubit>().makeDeposit(
        phone: widget.currentUser.phone,
        amount: widget.trip.prix.toInt(),
        network: _selectedMobileNetwork!,
      );
    } else {
      // Créer directement le ticket (espèces ou réservation)
      _createTicket();
    }
  }

  void _createTicket() {
    final heureFormatee = Ticket.formatTimeOfDay(widget.trip.heureDepart);
    final ticket = Ticket(
      prix: widget.trip.prix,
      trajetId: widget.trip.trajet.id?.toInt(),
      date: widget.trip.dateDepart.toIso8601String(),
      heureDepart: heureFormatee,
      userId: widget.currentUser.id,
      clientNom: widget.currentUser.firstName ?? '',
      clientPrenom: widget.currentUser.lastName ?? '',
      clientContact: widget.currentUser.phone ?? '',
      typeTransaction: _selectedType,
      status: _selectedType == 'ACHAT' ? TicketStatus.PAYE : TicketStatus.RESERVE,
      seatNumber: _selectedSeat,
    );

    context.read<TicketCubit>().createTicket(ticket);
  }

  void _showPaymentDialog(DepositResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.phone_android, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Paiement mobile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Composez ce code sur votre téléphone:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Center(
                child: Text(
                  response.txReference ?? '',
                  style: AppStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Référence: ${response.txReference}',
              style: AppStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPaymentStatus(response.txReference!);
            },
            child: const Text('J\'ai payé'),
          ),
        ],
      ),
    );
  }

  void _checkPaymentStatus(String txReference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Vérification du paiement...'),
              ],
            ),
          ),
        ),
      ),
    );

    context.read<TicketCubit>().checkTransactionStatus(
      txReference: txReference,
    );
  }

  void _createTicketAfterPayment() {
    Navigator.pop(context); // Fermer le dialog de vérification
    _createTicket();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_selectedType == 'ACHAT' ? 'Achat réussi!' : 'Réservation créée!'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedType == 'ACHAT'
                  ? 'Votre ticket a été acheté avec succès.'
                  : 'Votre réservation a été créée. N\'oubliez pas de payer dans les 24 heures.',
            ),
            if (_selectedType == 'ACHAT') ...[
              const SizedBox(height: 16),
              const Text('Voulez-vous télécharger votre reçu?'),
            ],
          ],
        ),
        actions: [
          if (_selectedType == 'ACHAT')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Plus tard'),
            ),
          ElevatedButton(
            onPressed: _isDownloadingPdf
                ? null
                : () {
              Navigator.pop(context);
              if (_selectedType == 'ACHAT') {
                // Télécharger le PDF
                _downloadTicketPdf();
              } else {
                Navigator.pop(context);
              }
            },
            child: _isDownloadingPdf
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(_selectedType == 'ACHAT' ? 'Télécharger' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _downloadTicketPdf() {
    if (_createdTicketId != null) {
      setState(() {
        _isDownloadingPdf = true;
      });
      context.read<TicketCubit>().downloadTicketPdf(_createdTicketId!);
    } else {
      _showErrorSnackBar('Impossible de télécharger le reçu');
      Navigator.pop(context);
    }
  }

  Future<void> _savePdfToDevice(Uint8List pdfBytes) async {
    try {
      // Demander les permissions selon la version d'Android
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        PermissionStatus status;

        if (sdkInt >= 33) {
          // Android 13+ (API 33+) - Pas besoin de permission pour Downloads
          status = PermissionStatus.granted;
        } else {
          // Android 12 et inférieur
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted && sdkInt < 33) {
          setState(() {
            _isDownloadingPdf = false;
          });
          _showErrorSnackBar('Permission de stockage refusée. Veuillez autoriser l\'accès au stockage dans les paramètres.');
          Navigator.pop(context);
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
          _isDownloadingPdf = false;
        });
        _showErrorSnackBar('Impossible d\'accéder au stockage');
        Navigator.pop(context);
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
        _isDownloadingPdf = false;
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

      Navigator.pop(context);
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du PDF: $e');
      setState(() {
        _isDownloadingPdf = false;
      });
      _showErrorSnackBar('Erreur lors de la sauvegarde du PDF: ${e.toString()}');
      Navigator.pop(context);
    }
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

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'ESPECES':
        return 'Espèces';
      case 'MOBILE':
        return 'Paiement mobile';
      default:
        return method;
    }
  }
}