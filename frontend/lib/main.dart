import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppState();
  await app.initPersistence();
  runApp(MyApp(app: app));
}

class MyApp extends StatefulWidget {
  final AppState? app;
  const MyApp({super.key, this.app});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState _app;

  @override
  void initState() {
    super.initState();
    _app = widget.app ?? AppState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _app,
      builder: (context, _) {
        return MaterialApp(
          title: 'Electro Industrial — Materiales Eléctricos e Industriales',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          // Si hay sesión y token válidos, va directo a HomeScreen; si no, a LoginScreen
          home: _app.isLoggedIn ? HomeScreen(app: _app) : LoginScreen(app: _app),
        );
      },
    );
  }
}
