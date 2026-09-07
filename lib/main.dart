import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'state/cart_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Estado de carrito compartido entre pantallas. Cuando se conecte al
  // backend, esto se puede reemplazar por un provider/repositorio sin
  // tocar las pantallas que ya dependen de CartState.
  final CartState _cartState = CartState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compra y Venta de Materiales Eléctricos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: LoginScreen(cartState: _cartState),
    );
  }
}
