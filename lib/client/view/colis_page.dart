import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transi_flex_mobile/client/cubit/colis/colis_cubit.dart';
import 'package:transi_flex_mobile/client/enums/colis_status.dart';
import 'package:transi_flex_mobile/client/model/agency.dart';
import 'package:transi_flex_mobile/client/model/colis.dart';
import 'package:transi_flex_mobile/client/model/colis_items.dart';
import '../../authentification/cubit/auth_cubit.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/custom_app_bar.dart';
import '../cubit/mobile_app/mobile_app_cubit.dart';

class ColisPage extends StatefulWidget {
  const ColisPage({Key? key}) : super(key: key);

  @override
  _ColisPageState createState() => _ColisPageState();
}

class _ColisPageState extends State<ColisPage> {
  @override
  void initState() {
    super.initState();
    context.read<ColisCubit>().getColisByUser();
    context.read<MobileAppCubit>().getMobileAppState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColisCubit, ColisState>(
  builder: (context, state) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: const CustomAppBar(
        title: 'Mes Colis',
        showBackButton: true,
      ),
      body: BlocBuilder<ColisCubit, ColisState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  },
);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mes Colis',
            style: AppStyles.h2.copyWith(fontSize: 24),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddColisDialog(context),  // ✅ Passer le context
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Envoyer'),
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

  Widget _buildContent(context, ColisState state) {
    if (state.status == ColisSendStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state.status == ColisSendStatus.error) {
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
              style: AppStyles.h3.copyWith(color: AppColors.statusCancelled),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
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
              onPressed: () => context.read<ColisCubit>().getColisByUser(),
              style: AppStyles.primaryButton,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.colis == null || state.colis!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 60,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              'Aucun colis',
              style: AppStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              'Vous n\'avez pas encore envoyé de colis',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.spacingL),
            ElevatedButton.icon(
              onPressed: () => _showAddColisDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Envoyer un colis'),
              style: AppStyles.primaryButton,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingM,
        vertical: AppStyles.spacingM,
      ),
      itemCount: state.colis!.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: AppStyles.spacingM),
      itemBuilder: (context, index) {
        return _buildColisCard(context, state.colis![index]);
      },
    );
  }

  Widget _buildColisCard(BuildContext context, Colis colis) {
    final formattedDate = '${colis.createdAt?.day}/${colis.createdAt?.month}/${colis.createdAt?.year}';
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Colis #${colis.numero}',
                  style: AppStyles.h3.copyWith(fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(colis?.status?.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(colis?.status?.name).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    colis?.status?.name ?? 'N/A',
                    style: AppStyles.bodySmall.copyWith(
                      color: _getStatusColor(colis?.status?.name),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              '${colis.lieuEnvoi} → ${colis.lieuReception}',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'De: ${colis.expediteur} → À: ${colis.destinateur}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Envoyé le: ${formattedDate ?? 'N/A'}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${colis.prix?.toStringAsFixed(0)} CFA',
                  style: AppStyles.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showColisDetails(context, colis),
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
                    colis.status != ColisStatus.LIVRE ?
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirm(context, colis),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      style: AppStyles.primaryButton.copyWith(
                        backgroundColor:
                        MaterialStateProperty.all(AppColors.statusCancelled),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ) : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'EN_TRANSIT':
        return AppColors.statusPending;
      case 'LIVRE':
        return AppColors.statusConfirmed;
      case 'ANNULE':
        return AppColors.statusCancelled;
      case 'EN_ATTENTE':
        return AppColors.statusPending;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddColisDialog(BuildContext context) {
    // Récupérer les données AVANT d'ouvrir le dialog
    final colisCubit = context.read<ColisCubit>();
    final authState = context.read<AuthCubit>().state;
    final mobileAppState = context.read<MobileAppCubit>().state;

    // Extraire les données
    String? currentUserName;
    if (authState is AuthAuthenticated) {
      currentUserName = '${authState.user.firstName} ${authState.user.lastName}';
    }

    List<Agency>? companies = mobileAppState.mobileApp?.agencies;

    showDialog(
      context: context,
      builder: (dialogContext) => AddColisFormDialog(
        colisCubit: colisCubit,
        currentUserName: currentUserName,
        companies: companies,
        onSave: (colis) {
          colisCubit.createColis(colis);
          Navigator.pop(dialogContext);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Colis créé avec succès'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
  void _showColisDetails(BuildContext context, Colis colis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppStyles.radiusL),
          topRight: Radius.circular(AppStyles.radiusL),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails du colis',
                  style: AppStyles.h3,
                ),
                const SizedBox(height: AppStyles.spacingM),
                _buildDetailRow('Numéro', colis.numero ?? 'N/A'),
                _buildDetailRow('Expéditeur', colis.expediteur ?? 'N/A'),
                _buildDetailRow('Destinataire', colis.destinateur ?? 'N/A'),
                _buildDetailRow('Lieu d\'envoi', colis.lieuEnvoi ?? 'N/A'),
                _buildDetailRow('Lieu de réception', colis.lieuReception ?? 'N/A'),
                _buildDetailRow('Prix', '${colis.prix} CFA'),
                _buildDetailRow('Statut', colis?.status?.name ?? 'N/A'),
                _buildDetailRow('Date d\'envoi', colis.heureEnvoi ?? 'N/A'),
                if (colis.colisItems != null && colis.colisItems!.isNotEmpty) ...[
                  const SizedBox(height: AppStyles.spacingM),
                  Text(
                    'Articles du colis',
                    style: AppStyles.h3.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppStyles.spacingS),
                  ...colis.colisItems!.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(AppStyles.spacingS),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description ?? 'N/A',
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantité: ${item.nombre} • Nature: ${item.nature}',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Colis colis) {
    final colisCubit = context.read<ColisCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le colis #${colis.numero}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (colis.id != null) {
                colisCubit.deleteColis(colis.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Colis supprimé'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.statusCancelled),
            ),
          ),
        ],
      ),
    );
  }
}

class AddColisFormDialog extends StatefulWidget {
  final Function(Colis) onSave;
  final ColisCubit colisCubit;
  final String? currentUserName;
  final List<Agency>? companies;

  const AddColisFormDialog({
    Key? key,
    required this.onSave,
    required this.colisCubit,
    required this.currentUserName,
    required this.companies,
  }) : super(key: key);

  @override
  _AddColisFormDialogState createState() => _AddColisFormDialogState();
}

class _AddColisFormDialogState extends State<AddColisFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _destinateurController = TextEditingController();
  final _prixController = TextEditingController();
  final _lieuReceptionController = TextEditingController();

  String? _selectedAgenceDepart;
  String? _selectedAgenceArrivee;
  List<Map<String, dynamic>> _colisItems = [];
  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();
    _addColisItem();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Envoyer un Colis',
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
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppStyles.spacingM),
                    // Destinataire
                    TextFormField(
                      controller: _destinateurController,
                      decoration: AppStyles.inputDecoration('Destinataire'),
                      validator: (v) =>
                      v?.isEmpty ?? true ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: AppStyles.spacingM),

                    // Prix
                    TextFormField(
                      controller: _prixController,
                      decoration: AppStyles.inputDecoration('Prix'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                      v?.isEmpty ?? true ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: AppStyles.spacingM),

                    // Agence de départ
                    DropdownButtonFormField<String>(
                      value: _selectedAgenceDepart,
                      decoration: AppStyles.inputDecoration('Agence de départ'),
                      items: widget.companies?.map((company) {
                        return DropdownMenuItem(
                          value: company.name,
                          child: Text(company.name ?? ''),
                        );
                      }).toList() ?? [],
                      onChanged: (v) =>
                          setState(() => _selectedAgenceDepart = v),
                      validator: (v) => v == null ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: AppStyles.spacingM),

                    // Agence d'arrivée
                    DropdownButtonFormField<String>(
                      value: _selectedAgenceArrivee,
                      decoration:
                      AppStyles.inputDecoration('Agence d\'arrivée'),
                      items: widget.companies?.map((company) {
                        return DropdownMenuItem(
                          value: company.name,
                          child: Text(company.name ?? ''),
                        );
                      }).toList() ?? [],
                      onChanged: (v) =>
                          setState(() => _selectedAgenceArrivee = v),
                      validator: (v) => v == null ? 'Obligatoire' : null,
                    ),
                    const SizedBox(height: AppStyles.spacingM),

                    // Section Articles du colis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Articles du colis',
                          style: AppStyles.h3.copyWith(fontSize: 16),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addColisItem,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Ajouter'),
                          style: AppStyles.primaryButton.copyWith(
                            backgroundColor:
                            MaterialStateProperty.all(AppColors.primary),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingM),

                    // Liste des articles
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppStyles.spacingS),
                            decoration: const BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppStyles.radiusM),
                                topRight: Radius.circular(AppStyles.radiusM),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Description',
                                    style: AppStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Nombre',
                                    style: AppStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Nature',
                                    style: AppStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          ..._colisItems.asMap().entries.map((entry) {
                            int idx = entry.key;
                            Map<String, dynamic> item = entry.value;
                            return _buildColisItemRow(idx, item);
                          }),
                          if (_colisItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(AppStyles.spacingM),
                              child: Text(
                                'Aucun article ajouté',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_formSubmitted && _colisItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Au moins un article requis',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.statusCancelled,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppStyles.spacingL),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _resetForm,
                            style: AppStyles.primaryButton.copyWith(
                              backgroundColor:
                              MaterialStateProperty.all(AppColors.info),
                            ),
                            child: const Text('Effacer'),
                          ),
                        ),
                        const SizedBox(width: AppStyles.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _colisItems.isNotEmpty
                                ? _submitForm
                                : null,
                            style: AppStyles.primaryButton.copyWith(
                              backgroundColor:
                              MaterialStateProperty.all(AppColors.black),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColisItemRow(int index, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.spacingS),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: item['description'] ?? '',
              decoration: AppStyles.inputDecoration('Description'),
              onChanged: (v) => item['description'] = v,
              validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: TextFormField(
              initialValue: item['nombre']?.toString() ?? '',
              decoration: AppStyles.inputDecoration('Nombre'),
              keyboardType: TextInputType.number,
              onChanged: (v) => item['nombre'] = int.tryParse(v) ?? 0,
              validator: (v) {
                int? num = int.tryParse(v ?? '');
                return num == null || num <= 0 ? 'Min 1' : null;
              },
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: TextFormField(
              initialValue: item['nature'] ?? '',
              decoration: AppStyles.inputDecoration('Nature'),
              onChanged: (v) => item['nature'] = v,
              validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          IconButton(
            onPressed: () => _removeColisItem(index),
            icon: const Icon(Icons.delete, color: AppColors.statusCancelled),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _addColisItem() {
    setState(() {
      _colisItems.add({
        'description': '',
        'nombre': 1,
        'nature': '',
      });
    });
  }

  void _removeColisItem(int index) {
    if (_colisItems.length > 1) {
      setState(() {
        _colisItems.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Le colis doit avoir au moins un article'),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  void _resetForm() {
    _destinateurController.clear();
    _prixController.clear();
    _lieuReceptionController.clear();
    setState(() {
      _selectedAgenceDepart = null;
      _selectedAgenceArrivee = null;
      _colisItems.clear();
      _addColisItem();
      _formSubmitted = false;
    });
  }

  void _submitForm() {
    _formSubmitted = true;

    if (_formKey.currentState!.validate() && _colisItems.isNotEmpty) {
      final items = _colisItems
          .map((item) => ColisItems(
        description: item['description'],
        nombre: item['nombre'],
        nature: item['nature'],
      ))
          .toList();

      // Récupérer l'agence de départ sélectionnée
      final selectedAgency = widget.companies?.firstWhere(
            (agency) => agency.name == _selectedAgenceDepart,
      ) as Agency?;

      final colis = Colis(
        expediteur: widget.currentUserName,
        destinateur: _destinateurController.text,
        prix: double.tryParse(_prixController.text),
        lieuEnvoi: _selectedAgenceDepart,
        lieuReception: _selectedAgenceArrivee,
        status: ColisStatus.EN_ATTENTE,
        agency: selectedAgency,
        colisItems: items,
      );

      widget.onSave(colis);
    }
  }

  @override
  void dispose() {
    _destinateurController.dispose();
    _prixController.dispose();
    _lieuReceptionController.dispose();
    super.dispose();
  }
}