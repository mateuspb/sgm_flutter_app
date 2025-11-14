// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService()..loadTokens(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SGM App',
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
            ),
            home: auth.isAuthenticated ? const HomePage() : const LoginPage(),
          );
        },
      ),
    );
  }
}
