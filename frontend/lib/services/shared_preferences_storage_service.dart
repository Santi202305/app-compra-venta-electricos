import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/order.dart';
import '../state/cart_state.dart';
import 'storage_service.dart';

/// Implementación de StorageService usando SharedPreferences con serialización JSON defensiva.
class SharedPreferencesStorageService implements StorageService {
  static const String _cartKey = 'electro_cart_v1';
  static const String _ordersKey = 'electro_orders_v1';
  static const String _userKey = 'electro_user_v1';

  const SharedPreferencesStorageService();

  @override
  Future<void> saveCart(List<CartEntry> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((e) => {
            'id': e.product.id,
            'sku': e.product.sku,
            'qty': e.qty,
          }).toList();
      await prefs.setString(_cartKey, jsonEncode(list));
    } catch (e, stack) {
      debugPrint('Error al guardar carrito en almacenamiento: $e\n$stack');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartKey);
      if (raw == null || raw.trim().isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e, stack) {
      debugPrint('Error al cargar carrito desde almacenamiento: $e\n$stack');
      return [];
    }
  }

  @override
  Future<void> saveOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(list));
    } catch (e, stack) {
      debugPrint('Error al guardar pedidos en almacenamiento: $e\n$stack');
    }
  }

  @override
  Future<List<Order>> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ordersKey);
      if (raw == null || raw.trim().isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e, stack) {
      debugPrint('Error al cargar pedidos desde almacenamiento: $e\n$stack');
      return [];
    }
  }

  @override
  Future<void> saveUser(AppUser? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user == null) {
        await prefs.remove(_userKey);
      } else {
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
      }
    } catch (e, stack) {
      debugPrint('Error al guardar sesión de usuario: $e\n$stack');
    }
  }

  @override
  Future<AppUser?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw == null || raw.trim().isEmpty) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromJson(decoded);
    } catch (e, stack) {
      debugPrint('Error al cargar sesión de usuario: $e\n$stack');
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      await prefs.remove(_ordersKey);
      await prefs.remove(_userKey);
    } catch (e, stack) {
      debugPrint('Error al limpiar almacenamiento local: $e\n$stack');
    }
  }
}
