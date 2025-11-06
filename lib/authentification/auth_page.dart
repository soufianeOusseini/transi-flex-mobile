import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/auth_cubit.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isPasswordVisible = false;
  String? registrationMessage; // Message après inscription réussie

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      registrationMessage = null; // Effacer le message lors du changement
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        print("login");
        context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Inscription sans mot de passe
        context.read<AuthCubit>().register(
          email: _emailController.text.trim(),
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: _telephoneController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            if (state.isFromRegistration) {
              // Inscription réussie -> Basculer vers connexion avec message
              setState(() {
                isLogin = true;
                registrationMessage =
                'Inscription réussie ! Un mot de passe a été envoyé à votre adresse email.';

                // Réinitialiser les champs d'inscription
                _nomController.clear();
                _prenomController.clear();
                _telephoneController.clear();
                _passwordController.clear();
                // Garder l'email pour faciliter la connexion
              });

              _animationController.reset();
              _animationController.forward();

              // Réinitialiser l'état du cubit
              context.read<AuthCubit>().resetToUnauthenticated();
            } else {
              // Connexion réussie -> Navigation vers la page principale
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 0, left: 24.0, right: 24.0, bottom: 8),
              child: Column(
                children: [
                  _buildHeader(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildForm(),
                  ),
                  const SizedBox(height: 30),
                  _buildToggleButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isLogin ? 'Connexion' : 'Créer un compte',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Message de succès après inscription
            if (isLogin && registrationMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        registrationMessage!,
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Champs inscription uniquement
            if (!isLogin) ...[
              // Champ Nom
              _buildTextField(
                controller: _nomController,
                label: 'Nom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  if (value.length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ Prénom
              _buildTextField(
                controller: _prenomController,
                label: 'Prénom',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  if (value.length < 2) {
                    return 'Le prénom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ Téléphone
              _buildTextField(
                controller: _telephoneController,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  if (value.length < 8) {
                    return 'Numéro de téléphone invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],

            // Champ email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Champ mot de passe (uniquement pour la connexion)
            if (isLogin) ...[
              _buildTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
            ],

            // Info pour l'inscription
            if (!isLogin) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Un mot de passe sera généré et envoyé à votre email',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isLogin ? 'Se connecter' : 'Créer le compte',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: onTogglePassword,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildToggleButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin
                  ? "Vous n'avez pas de compte ? "
                  : "Vous avez déjà un compte ? ",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            TextButton(
              onPressed: isLoading ? null : _toggleAuthMode,
              child: Text(
                isLogin ? 'Créer un compte' : 'Se connecter',
                style: TextStyle(
                  color: isLoading ? Colors.grey : Colors.blue.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}