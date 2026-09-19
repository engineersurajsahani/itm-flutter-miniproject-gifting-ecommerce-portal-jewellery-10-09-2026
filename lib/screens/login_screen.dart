import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../services/api_service.dart';
import '../widgets/luxury_button.dart';
import '../widgets/luxury_divider.dart';
import 'admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    try {
      await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (auth.isAdmin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
        return;
      }

      // Consumer login: sync (and merge) their cart/orders before returning
      // to whatever screen prompted the sign-in (Cart checkout, Profile, ...).
      await context.read<ShopProvider>().onUserAuthenticated(auth.currentConsumer!.email);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFF8B1E2B)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSubmitting = true);
    final auth = context.read<AuthProvider>();

    try {
      await auth.signInWithGoogle();
      if (!mounted) return;

      if (auth.isAdmin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false,
        );
        return;
      }

      await context.read<ShopProvider>().onUserAuthenticated(auth.currentConsumer!.email);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFF8B1E2B)),
      );
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.forestGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "AURELIA",
                    style: LuxuryTheme.displayBrand(size: 34, color: LuxuryTheme.gold),
                  ),
                  Text(
                    "MAISON DE HAUTE JOAILLERIE",
                    style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 32),
                  const LuxuryDivider(width: 60),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.creamText,
                      border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: LuxuryTheme.luxuryShadow(blur: 20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "SIGN IN TO YOUR VAULT",
                            textAlign: TextAlign.center,
                            style: LuxuryTheme.displayBrand(size: 12, color: LuxuryTheme.forestGreen),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _emailController,
                            label: "Email Address",
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Email is required";
                              if (!val.contains("@")) return "Enter a valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: LuxuryTheme.grayMuted,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Password is required";
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          _isSubmitting
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: CircularProgressIndicator(color: LuxuryTheme.gold),
                                  ),
                                )
                              : LuxuryButton(
                                  text: "Login",
                                  width: double.infinity,
                                  onPressed: _handleLogin,
                                ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: LuxuryTheme.warmSand)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "OR",
                                  style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                                ),
                              ),
                              Expanded(child: Divider(color: LuxuryTheme.warmSand)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _isGoogleSubmitting
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: CircularProgressIndicator(color: LuxuryTheme.forestGreen),
                                  ),
                                )
                              : LuxuryButton(
                                  text: "Continue with Google",
                                  width: double.infinity,
                                  isSecondary: true,
                                  icon: Icons.g_mobiledata_rounded,
                                  onPressed: _handleGoogleSignIn,
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "New to Aurelia? ",
                        style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.creamText.withValues(alpha: 0.8)),
                        children: [
                          TextSpan(
                            text: "Register here",
                            style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.gold, bold: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: LuxuryTheme.forestGreen,
      style: LuxuryTheme.bodySans(size: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: LuxuryTheme.bodySans(size: 13, color: LuxuryTheme.grayMuted),
        prefixIcon: Icon(icon, color: LuxuryTheme.gold, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: LuxuryTheme.whitePremium,
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: LuxuryTheme.warmSand),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: LuxuryTheme.gold, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF8B1E2B)),
        ),
      ),
    );
  }
}
