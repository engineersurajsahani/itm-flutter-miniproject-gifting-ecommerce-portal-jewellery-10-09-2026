import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/luxury_theme.dart';
import 'providers/shop_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AureliaMaisonApp(),
    ),
  );
}

class AureliaMaisonApp extends StatelessWidget {
  const AureliaMaisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watched so toggling dark mode rebuilds the whole tree with the new
    // LuxuryTheme palette — most screens read LuxuryTheme.* directly rather
    // than Theme.of(context), so this top-level rebuild is what propagates
    // the change everywhere.
    context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Aurelia • Fine Gifting Jewellery',
      debugShowCheckedModeBanner: false,
      theme: LuxuryTheme.themeData,
      home: const SplashScreen(),
    );
  }
}

