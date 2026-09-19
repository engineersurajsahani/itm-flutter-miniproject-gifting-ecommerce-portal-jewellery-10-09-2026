import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import 'admin_dashboard_screen.dart';
import 'main_root_screen.dart';

// Decides which root screen to show based on whatever session Firebase
// restores on launch (or after a page reload on web) — admins land on the
// dashboard, signed-in consumers get their cart/orders re-synced, guests
// just see the boutique. Without this, every fresh load defaulted straight
// to the consumer catalog regardless of who was actually signed in.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _syncStarted = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return Scaffold(
        backgroundColor: LuxuryTheme.forestGreen,
        body: const Center(
          child: CircularProgressIndicator(color: LuxuryTheme.gold),
        ),
      );
    }

    if (auth.isAdmin) {
      return const AdminDashboardScreen();
    }

    final consumer = auth.currentConsumer;
    if (consumer != null && !_syncStarted) {
      _syncStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<ShopProvider>().onUserAuthenticated(consumer.email);
      });
    }

    return const MainRootScreen();
  }
}
