import 'package:flutter/foundation.dart';

import '../data/products.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'cart_state.dart';

/// Estado global de la app. Hace el papel del backend mientras no
/// exista: guarda usuarios, catálogo con stock y pedidos en memoria.
import '../repositories/product_repository.dart';
import '../services/shared_preferences_storage_service.dart';
import '../services/storage_service.dart';

/// Estado global de la app. Gestiona usuarios, catálogo de productos mediante
/// ProductRepository, persistencia local con StorageService, estado del carrito y pedidos.
class AppState extends ChangeNotifier {
  final ProductRepository productRepository;
  final StorageService storageService;
  final CartState cart;
  List<Product> products;
  bool isLoadingProducts = false;
  String? productsError;

  AppState({
    ProductRepository? productRepository,
    CartState? cart,
    StorageService? storageService,
    List<Product>? initialProducts,
  })  : productRepository = productRepository ?? LocalProductRepository(),
        cart = cart ?? CartState(),
        storageService = storageService ?? const SharedPreferencesStorageService(),
        products = initialProducts ?? buildSampleProducts() {
    this.cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    storageService.saveCart(cart.items);
  }

  /// Inicializa la persistencia local restaurando usuario, pedidos y carrito contra inventario.
  Future<void> initPersistence() async {
    try {
      // 1. Restaurar usuario
      final savedUser = await storageService.loadUser();
      if (savedUser != null) {
        _currentUser = savedUser;
      }

      // 2. Restaurar pedidos
      final savedOrders = await storageService.loadOrders();
      if (savedOrders.isNotEmpty) {
        _orders.clear();
        _orders.addAll(savedOrders);
        final maxId = _orders.fold(1000, (m, o) => o.id > m ? o.id : m);
        _nextOrderId = maxId + 1;
      }

      // 3. Restaurar carrito contra catálogo
      final savedCart = await storageService.loadCart();
      for (final item in savedCart) {
        final sku = item['sku'] as String?;
        final id = item['id'] as int?;
        final qty = item['qty'] as int? ?? 1;

        Product? p;
        if (sku != null) {
          p = products.where((prod) => prod.sku == sku).firstOrNull;
        }
        p ??= products.where((prod) => prod.id == id).firstOrNull;

        if (p != null) {
          cart.addProduct(p, qty);
        }
      }
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Error al inicializar persistencia local: $e\n$stack');
    }
  }

  /// Carga asíncrona de productos desde el repositorio con manejo de error y reintento.
  Future<void> loadProducts() async {
    isLoadingProducts = true;
    productsError = null;
    notifyListeners();

    try {
      final fetched = await productRepository.getAll();
      products = List<Product>.from(fetched);
      isLoadingProducts = false;
      productsError = null;
    } catch (e, stack) {
      isLoadingProducts = false;
      productsError = 'Error al cargar el inventario: $e';
      debugPrint('Error en loadProducts: $e\n$stack');
    }
    notifyListeners();
  }

  final List<AppUser> _users = [
    const AppUser(
      name: 'Administrador del negocio',
      email: 'admin@negocio.com',
      password: 'admin123',
      isAdmin: true,
    ),
    const AppUser(
      name: 'Wilson Ortiz',
      email: 'cliente@correo.com',
      password: 'cliente123',
    ),
  ];
  final List<Order> _orders = [];
  AppUser? _currentUser;
  int _nextOrderId = 1001;
  int _nextProductId = 100;

  // ---------------------------------------------------------------
  // Autenticación y registro
  // ---------------------------------------------------------------

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Acceso rápido como administrador para presentaciones y pruebas.
  void loginAsAdmin() {
    _currentUser = _users.firstWhere((u) => u.isAdmin);
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Acceso rápido como cliente estándar para presentaciones y pruebas.
  void loginAsCustomer() {
    _currentUser = _users.firstWhere((u) => !u.isAdmin);
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Permite el ingreso con CUALQUIER nombre o correo sin exigir
  /// contraseñas específicas. Si no existe, lo crea al vuelo.
  void loginFlexible({required String identifier, bool asAdmin = false}) {
    final clean = identifier.trim();
    if (clean.isEmpty) {
      if (asAdmin) {
        loginAsAdmin();
      } else {
        loginAsCustomer();
      }
      return;
    }

    final isEmail = clean.contains('@');
    final email = isEmail ? clean.toLowerCase() : '${clean.replaceAll(' ', '.').toLowerCase()}@usuario.com';
    final name = isEmail ? clean.split('@').first : clean;

    final existing = _users.where((u) => u.email == email).firstOrNull;
    if (existing != null) {
      _currentUser = existing;
    } else {
      final newUser = AppUser(
        name: name.isEmpty ? 'Usuario' : '${name[0].toUpperCase()}${name.substring(1)}',
        email: email,
        password: '',
        isAdmin: asAdmin || email.contains('admin'),
      );
      _users.add(newUser);
      _currentUser = newUser;
    }
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Devuelve un mensaje de error, o null si el ingreso fue exitoso.
  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email == e && user.password == password) {
        _currentUser = user;
        storageService.saveUser(_currentUser);
        notifyListeners();
        return null;
      }
    }
    return 'Correo o contraseña incorrectos.';
  }

  /// Devuelve un mensaje de error, o null si la cuenta se creó bien.
  String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final n = name.trim();
    final e = email.trim().toLowerCase();
    if (n.isEmpty) return 'Escribe tu nombre.';
    if (!e.contains('@') || !e.contains('.')) {
      return 'Escribe un correo válido.';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (_users.any((u) => u.email == e)) {
      return 'Ya existe una cuenta con ese correo.';
    }
    final user = AppUser(name: n, email: e, password: password);
    _users.add(user);
    _currentUser = user;
    storageService.saveUser(_currentUser);
    notifyListeners();
    return null;
  }

  /// Cierra la sesión (también sirve para entrar como invitado).
  void logout() {
    _currentUser = null;
    storageService.saveUser(null);
    cart.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Pedidos
  // ---------------------------------------------------------------

  /// Todos los pedidos, del más reciente al más antiguo (panel admin).
  List<Order> get allOrders => _orders.reversed.toList();

  /// Pedidos del usuario con sesión iniciada.
  List<Order> get myOrders {
    final email = _currentUser?.email;
    if (email == null) return [];
    return _orders.reversed.where((o) => o.userEmail == email).toList();
  }

  /// Crea el pedido con lo que hay en el carrito, descuenta el stock y
  /// vacía el carrito. Devuelve null si no hay productos o si algún
  /// producto ya no tiene stock suficiente.
  Order? placeOrder({required String paymentLabel, required String address}) {
    if (cart.items.isEmpty) return null;
    for (final entry in cart.items) {
      if (entry.qty > entry.product.stock) return null;
    }
    final lines = cart.items
        .map((e) => OrderLine(
              productName: e.product.name,
              sku: e.product.sku,
              unitPrice: e.product.price,
              qty: e.qty,
            ))
        .toList();
    final order = Order(
      id: _nextOrderId++,
      date: DateTime.now(),
      userEmail: _currentUser?.email ?? 'invitado',
      lines: lines,
      subtotal: cart.subtotal,
      shipping: cart.shipping,
      paymentLabel: paymentLabel,
      address: address,
    );
    for (final entry in cart.items) {
      entry.product.stock -= entry.qty;
    }
    _orders.add(order);
    storageService.saveOrders(_orders);
    cart.clear();
    notifyListeners();
    return order;
  }

  // ---------------------------------------------------------------
  // Panel administrativo
  // ---------------------------------------------------------------

  void updateProduct(Product product, {required int stock, required int price}) {
    product.stock = stock < 0 ? 0 : stock;
    if (price > 0) product.price = price;
    notifyListeners();
  }

  void addProduct({
    required String name,
    required String sku,
    required ProductCategory category,
    required int price,
    required int stock,
    String specs = '',
    String shortDescription = '',
    String longDescription = '',
  }) {
    products.add(Product(
      id: _nextProductId++,
      category: category,
      name: name,
      sku: sku,
      price: price,
      stock: stock,
      shortDescription: shortDescription.isNotEmpty ? shortDescription : name,
      longDescription: longDescription,
      specs: specs.isNotEmpty ? {'Especificación': specs} : const {},
    ));
    notifyListeners();
  }

  void setOrderStatus(Order order, OrderStatus status) {
    order.status = status;
    storageService.saveOrders(_orders);
    notifyListeners();
  }
}
