import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transi_flex_mobile/client/cubit/trip/trip_search_cubit.dart';
import 'package:transi_flex_mobile/client/enums/ticket_status.dart';
import 'package:transi_flex_mobile/client/model/trip_result.dart';
import 'package:transi_flex_mobile/client/repository/ticket_repository.dart';
import 'package:transi_flex_mobile/client/view/reserve_ticket_dialog.dart';
import '../../authentification/model/user.dart';
import '../../authentification/service/user_service.dart';
import '../../injection.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/custom_app_bar.dart';
import '../cubit/ticket/ticket_cubit.dart';
import '../model/ticket.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<String> _filteredDepartureCities = [];
  List<String> _filteredArrivalCities = [];

  @override
  void initState() {
    super.initState();
    context.read<TripSearchCubit>().loadDepartureCities();
    _timeController.text = '08:00';
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: const CustomAppBar(
        title: 'Rechercher un Trajet',
        showBackButton: true,
      ),
      body: BlocBuilder<TripSearchCubit, TripSearchState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchForm(context, state),
                if (state.status == TripSearchStatus.success &&
                    state.tripResults.isNotEmpty)
                  _buildResultsList(state.tripResults),
                if (state.status == TripSearchStatus.loading)
                  _buildLoadingState(),
                if (state.status == TripSearchStatus.error)
                  _buildErrorState(state.errorMessage),
                if (state.status == TripSearchStatus.success &&
                    state.tripResults.isEmpty)
                  _buildEmptyResultsState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context, TripSearchState state) {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingM),
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rechercher un Trajet',
            style: AppStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppStyles.spacingL),

          // Départ et Arrivée
          Row(
            children: [
              Expanded(
                child: _buildTextFieldWithSuggestions(
                  label: 'Départ',
                  controller: _departureController,
                  hint: 'Ville de départ',
                  suggestions: state.departureCities,
                  onSuggestionSelected: (city) {
                    _departureController.text = city;
                    context.read<TripSearchCubit>().loadArrivalCities(city);
                    _arrivalController.clear();
                    _filteredArrivalCities = [];
                  },
                ),
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: _buildTextFieldWithSuggestions(
                  label: 'Arrivée',
                  controller: _arrivalController,
                  hint: 'Ville d\'arrivée',
                  suggestions: state.arrivalCities,
                  onSuggestionSelected: (city) {
                    _arrivalController.text = city;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppStyles.spacingM),

          // Date, Heure et Passagers
          Row(
            children: [
              Expanded(
                child: _buildDateField(),
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: _buildTimeField(),
              ),
              const SizedBox(width: AppStyles.spacingM),
              Expanded(
                child: _buildPassengersField(),
              ),
            ],
          ),

          const SizedBox(height: AppStyles.spacingL),

          // Bouton Rechercher
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performSearch,
              style: AppStyles.primaryButton.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.black),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, color: AppColors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Rechercher',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithSuggestions({
    required String label,
    required TextEditingController controller,
    required String hint,
    required List<String> suggestions,
    required Function(String) onSuggestionSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.bodyMedium),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return suggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          onSelected: (String selection) {
            onSuggestionSelected(selection);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,) {
            controller.text = textEditingController.text;
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) {
                controller.text = value;
              },
              decoration: AppStyles.inputDecoration(hint),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                child: Container(
                  width: 200,
                  color: AppColors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppStyles.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          decoration: AppStyles.inputDecoration('jj/mm/aaaa').copyWith(
            suffixIcon:
            const Icon(Icons.calendar_today, color: AppColors.grey600),
          ),
          readOnly: true,
          onTap: () => _selectDate(),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heure', style: AppStyles.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeController,
          decoration: AppStyles.inputDecoration('HH:mm').copyWith(
            suffixIcon: const Icon(Icons.access_time, color: AppColors.grey600),
          ),
          readOnly: true,
          onTap: () => _selectTime(),
        ),
      ],
    );
  }

  Widget _buildPassengersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Passagers', style: AppStyles.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passengersController,
          decoration: AppStyles.inputDecoration('Nombre'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildResultsList(List<TripResult> results) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trajets Disponibles (${results.length})',
                style: AppStyles.h3.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: AppStyles.spacingM),
            itemBuilder: (context, index) {
              return _buildTripResultCard(results[index]);
            },
          ),
          const SizedBox(height: AppStyles.spacingM),
        ],
      ),
    );
  }

  Widget _buildTripResultCard(TripResult trip) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête: Compagnie et Agence
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.agency.company?.name ?? '',
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Agence: ${trip.agency.name}',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${trip.prix.toStringAsFixed(0)} CFA',
                          style: AppStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${trip.placesDisponibles} places',
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppStyles.spacingM),

                // Trajet et horaires
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trip.trajet.villeDepart} → ${trip.trajet.villeArrive}',
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trip.heureDepart.format(context)} • ${trip.trajet.km?.toStringAsFixed(1)} km',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppStyles.spacingM),
              ],
            ),
          ),

          // Bouton Réserver
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _reserveTrip(trip),
              style: AppStyles.primaryButton.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.black),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyles.radiusL),
                      bottomRight: Radius.circular(AppStyles.radiusL),
                    ),
                  ),
                ),
              ),
              child: Text(
                'Réserver',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingL),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingL),
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        color: AppColors.statusCancelled.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(
          color: AppColors.statusCancelled.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erreur',
            style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.statusCancelled,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Une erreur est survenue lors de la recherche',
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.statusCancelled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsState() {
    return Container(
      margin: const EdgeInsets.all(AppStyles.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            'Aucun trajet disponible',
            style: AppStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _timeController.text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _performSearch() {
    if (_departureController.text.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner une ville de départ');
      return;
    }
    if (_arrivalController.text.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner une ville d\'arrivée');
      return;
    }
    if (_selectedDate == null) {
      _showErrorSnackBar('Veuillez sélectionner une date');
      return;
    }
    if (_selectedTime == null) {
      _showErrorSnackBar('Veuillez sélectionner une heure');
      return;
    }
    if (_passengersController.text.isEmpty) {
      _showErrorSnackBar('Veuillez entrer le nombre de passagers');
      return;
    }

    final passengers = int.tryParse(_passengersController.text);
    if (passengers == null || passengers <= 0) {
      _showErrorSnackBar('Nombre de passagers invalide');
      return;
    }

    context.read<TripSearchCubit>().searchTrips(
      villeDepart: _departureController.text,
      villeArrive: _arrivalController.text,
      dateDepart: _selectedDate!,
      heureDepart: _selectedTime!,
      nombrePassagers: passengers,
    );
  }

  void _reserveTrip(TripResult trip) {
    _showReserveTicketDialog(trip);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.statusCancelled,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // MÉTHODE MODIFIÉE - Solution au problème
  Future<void> _showReserveTicketDialog(TripResult trip) async {
    final userService = sl<UserService>();
    final currentUser = await userService.getCurrentUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Créer le TicketCubit une seule fois
    final ticketCubit = TicketCubit(repository: sl<TicketRepository>());

    showDialog(
      context: context,
      builder: (dialogContext) =>
          BlocProvider.value(
            value: ticketCubit,
            child: ReserveTicketDialog(
              trip: trip,
              currentUser: currentUser,
              onReserve: (typeTransaction) {
                // Passer ticketCubit directement
                _createTicket(ticketCubit, trip, currentUser, typeTransaction);
              },
            ),
          ),
    );
  }

  // MÉTHODE MODIFIÉE - Accepter TicketCubit en paramètre
  void _createTicket(TicketCubit ticketCubit, TripResult trip, User user, String typeTransaction) {
    final heureFormatee = Ticket.formatTimeOfDay(trip.heureDepart);

    // Formater la date: YYYY-MM-DD (juste la partie date)
    final dateFormatee = trip.dateDepart.toIso8601String().split('T')[0];

    final ticket = Ticket(
      prix: trip.prix,
      trajetId: trip.trajet.id?.toInt(),
      date: trip.dateDepart.toIso8601String(),
      heureDepart: heureFormatee,
      userId: user.id,
      clientNom: user.firstName ?? '',
      clientPrenom: user.lastName ?? '',
      clientContact: user.phone ?? '',
      typeTransaction: typeTransaction,
      status: typeTransaction == 'ACHAT' ? TicketStatus.PAYE : TicketStatus.RESERVE,
    );

    // Utiliser le ticketCubit passé en paramètre
    ticketCubit.createTicket(ticket);

    // Fermer le dialogue
    Navigator.pop(context);

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            typeTransaction == 'ACHAT'
                ? 'Ticket acheté avec succès'
                : 'Ticket réservé avec succès'
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}