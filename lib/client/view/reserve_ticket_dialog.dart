import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transi_flex_mobile/client/cubit/ticket/ticket_cubit.dart';

import '../../authentification/model/user.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../model/trip_result.dart';

class ReserveTicketDialog extends StatefulWidget {
  final TripResult trip;
  final User currentUser;
  final Function(String, String) onReserve;

  const ReserveTicketDialog({
    required this.trip,
    required this.currentUser,
    required this.onReserve,
  });

  @override
  _ReserveTicketDialogState createState() => _ReserveTicketDialogState();
}

class _ReserveTicketDialogState extends State<ReserveTicketDialog> {
  String? _selectedType;
  String? _selectedPayment;

  final List<String> _paymentMethods = [
    'ESPECES',
    'MOBILE',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketCubit, TicketState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(AppStyles.spacingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Réserver un ticket',
                        style: AppStyles.h3.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.spacingL),

                  // Détails du trajet
                  Container(
                    padding: const EdgeInsets.all(AppStyles.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.trip.trajet.villeDepart} → ${widget.trip
                              .trajet.villeArrive}',
                          style: AppStyles.h3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.trip.dateDepart.toLocal().toString().split(
                              ' ')[0]} à ${widget.trip.heureDepart.format(
                              context)}',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prix: ${widget.trip.prix.toStringAsFixed(0)} CFA',
                          style: AppStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppStyles.spacingL),

                  // Type de transaction
                  Text(
                    'Type de transaction',
                    style: AppStyles.h4.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppStyles.spacingM),

                  // Achat immédiat
                  Card(
                    child: RadioListTile<String>(
                      title: const Text('Achat immédiat'),
                      subtitle: const Text('Paiement maintenant'),
                      value: 'ACHAT',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedPayment = null;
                        });
                      },
                    ),
                  ),

                  // Réservation
                  Card(
                    child: RadioListTile<String>(
                      title: const Text('Réservation'),
                      subtitle: const Text('Payer dans 24 heures'),
                      value: 'RESERVATION',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedPayment = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: AppStyles.spacingL),

                  // Mode de paiement (si achat)
                  if (_selectedType == 'ACHAT') ...[
                    Text(
                      'Mode de paiement',
                      style: AppStyles.h4.copyWith(fontWeight: FontWeight.w600),
                    ),
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
                        setState(() => _selectedPayment = value);
                      },
                    ),
                    const SizedBox(height: AppStyles.spacingL),
                  ],

                  // Boutons
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
                          onPressed: _canSubmit() ? () {
                            widget.onReserve(_selectedType!, _selectedPayment!);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedType == 'ACHAT'
                                ? AppColors.statusConfirmed
                                : AppColors.statusPending,
                          ),
                          child: Text(
                            _selectedType == 'ACHAT'
                                ? 'Acheter'
                                : 'Réserver',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canSubmit() {
    if (_selectedType == null) return false;
    if (_selectedType == 'ACHAT' && _selectedPayment == null) return false;
    return true;
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