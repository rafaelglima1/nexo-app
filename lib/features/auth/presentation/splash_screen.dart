import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as ap;
import 'login_screen.dart';
import '../../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<ap.AuthProvider>();
    final destination = authProvider.status == ap.AuthStatus.authenticated
        ? const HomeScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handshake_rounded, size: 80, color: Color(0xFF4A7C6F)),
            SizedBox(height: 16),
            Text(
              'NEXO',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7C6F),
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Conexões reais em um mundo superficial.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
