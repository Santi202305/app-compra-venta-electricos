import '../models/app_user.dart';
import '../models/order.dart';
import '../state/cart_state.dart';

/// Contrato abstracto para la persistencia local de la aplicación.
/// Permite desacoplar el motor de almacenamiento (SharedPreferences, Hive, SQLite o memoria de pruebas).
abstract class StorageService {
  /// Guarda el estado del carrito en almacenamiento local.
  Future<void> saveCart(List<CartEntry> items);

  /// Recupera los ítems guardados del carrito (retorna pares de SKU o id con cantidad).
  Future<List<Map<String, dynamic>>> loadCart();

  /// Guarda la lista histórica de pedidos en almacenamiento local.
  Future<void> saveOrders(List<Order> orders);

  /// Recupera los pedidos almacenados.
  Future<List<Order>> loadOrders();

  /// Guarda el usuario activo en sesión local.
  Future<void> saveUser(AppUser? user);

  /// Recupera el usuario con sesión activa previa.
  Future<AppUser?> loadUser();

  /// Limpia los datos almacenados localmente.
  Future<void> clearAll();
}
