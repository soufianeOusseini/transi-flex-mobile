import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../authentification/cubit/auth_cubit.dart';
import '../shared/app_colors.dart';
import '../shared/app_styles.dart';
import 'custom_app_bar.dart';
import 'menu.dart';

class ProfilePage extends StatefulWidget {
  final dynamic user;

  const ProfilePage({Key? key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Utiliser les données passées en paramètre ou des données par défaut
    if (widget.user != null) {
      _nameController.text = '${widget.user.firstName} ${widget.user.lastName ?? ''}';
      _emailController.text = widget.user.email ?? '';
      _phoneController.text = widget.user.phone ?? '';
      // Charger les autres données depuis la base de données si nécessaire
    }

    // Données par défaut pour la démo (toujours appliquées pour les champs manquants)
    // if (_nameController.text.isEmpty) _nameController.text = 'Jean Dupont';
    // if (_emailController.text.isEmpty) _emailController.text = 'jean.dupont@email.com';
    // _phoneController.text = '+228 90 12 34 56';
    // _addressController.text = '123 Rue de la Paix, Lomé';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: const CustomAppBar(
        title: 'Mon Profil',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppStyles.spacingL),
            _buildProfileForm(),
            // const SizedBox(height: AppStyles.spacingL),
            // _buildPreferences(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 64,
              ),
            ),
          ),

          const SizedBox(height: AppStyles.spacingM),

          // Nom et statut
          Text(
            "${widget.user.firstName} ${widget.user.lastName}",
            style: AppStyles.h2.copyWith(fontSize: 20),
          ),

        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingL),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nom complet', _nameController),
          const SizedBox(height: AppStyles.spacingM),
          _buildTextField('Email', _emailController),
          const SizedBox(height: AppStyles.spacingM),
          _buildTextField('Téléphone', _phoneController),
          const SizedBox(height: AppStyles.spacingM),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                context.read<AuthCubit>().logout();
                Navigator.pushNamed(context, "/auth");
              },
              style: AppStyles.primaryButton.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.error),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              child: Text(
                'Déconnexion',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppStyles.spacingL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: AppStyles.primaryButton.copyWith(
                backgroundColor: MaterialStateProperty.all(AppColors.success),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              child: Text(
                'Sauvegarder',
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: AppStyles.inputDecoration('').copyWith(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil sauvegardé avec succès',
          style: AppStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Menu menu, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.read<AuthCubit>().logout();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppStyles.spacingM,
          horizontal: AppStyles.spacingS,
        ),
        child: Row(
          children: [
            Icon(
              menu.icon,
              color: isLogout ? AppColors.error : AppColors.grey700,
              size: 22,
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Text(
                menu.title,
                style: AppStyles.bodyMedium.copyWith(
                  color: isLogout ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (menu.badge != null && menu.badge! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  menu.badge.toString(),
                  style: AppStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}