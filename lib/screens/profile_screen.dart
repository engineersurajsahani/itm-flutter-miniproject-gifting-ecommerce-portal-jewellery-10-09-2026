import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/luxury_button.dart';
import '../widgets/luxury_divider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    context.read<AuthProvider>().logout();
    context.read<ShopProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final consumer = auth.currentConsumer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MY PROFILE",
          style: LuxuryTheme.displayBrand(size: 14, color: LuxuryTheme.creamText),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: LuxuryTheme.gold,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          if (consumer != null) ...[
            IconButton(
              tooltip: "Refresh",
              icon: const Icon(Icons.refresh_rounded, color: LuxuryTheme.gold),
              onPressed: () => context.read<ShopProvider>().refreshOrders(email: consumer.email),
            ),
            IconButton(
              tooltip: "Logout",
              icon: const Icon(Icons.logout_rounded, color: LuxuryTheme.gold),
              onPressed: () => _handleLogout(context),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: consumer == null ? _buildGuestPrompt(context) : _buildSignedInView(context, consumer),
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: LuxuryTheme.gold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Sign In to Your Vault",
              style: LuxuryTheme.headlineElegant(size: 22, color: LuxuryTheme.forestGreen),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign in to track your orders, view delivery status, and manage your account. Anything already in your cart will stay right where you left it.",
              style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const LuxuryDivider(width: 80),
            const SizedBox(height: 32),
            SizedBox(
              width: 280,
              child: LuxuryButton(
                text: "Login",
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 280,
              child: LuxuryButton(
                text: "Register",
                isSecondary: true,
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedInView(BuildContext context, ConsumerAccount consumer) {
    final initial = consumer.fullName.isNotEmpty ? consumer.fullName[0].toUpperCase() : "?";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LuxuryTheme.whitePremium,
            border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
            boxShadow: LuxuryTheme.luxuryShadow(blur: 8),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: LuxuryTheme.forestGreen, shape: BoxShape.circle),
                child: Text(
                  initial,
                  style: LuxuryTheme.displayBrand(size: 20, color: LuxuryTheme.gold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consumer.fullName,
                      style: LuxuryTheme.headlineElegant(size: 17, color: LuxuryTheme.forestGreen),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consumer.email,
                      style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.grayMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Text(
            "ORDER HISTORY",
            style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold),
          ),
        ),
        const Expanded(child: OrderHistoryScreen()),
      ],
    );
  }
}
