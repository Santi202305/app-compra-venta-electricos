import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../data/products.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/shared_preferences_storage_service.dart';
import '../services/storage_service.dart';
import '../services/token_storage_service.dart';
import 'cart_state.dart';

/// Estado global de la app. Gestiona usuarios con autenticación JWT, catálogo de productos mediante
/// ProductRepository, persistencia local con StorageService y TokenStorageService, estado del carrito y pedidos.
class AppState extends ChangeNotifier {
  final ProductRepository productRepository;
  final StorageService storageService;
  final TokenStorageService tokenStorage;
  final ApiClient apiClient;
  final CartState cart;
  List<Product> products;
  bool isLoadingProducts = false;
  String? productsError;

  final List<AppUser> _users = [
    const AppUser(
      name: 'Administrador General',
      email: 'admin@electroindustrial.com',
      password: 'Admin2026*',
      role: 'admin',
      isAdmin: true,
    ),
    const AppUser(
      name: 'Usuario Demo',
      email: 'demo@electroindustrial.com',
      password: 'Demo2026*',
      role: 'customer',
      isAdmin: false,
    ),
    const AppUser(
      name: 'Wilson Ortiz',
      email: 'cliente@correo.com',
      password: 'cliente123',
      role: 'customer',
      isAdmin: false,
    ),
    const AppUser(
      name: 'Administrador del negocio',
      email: 'admin@negocio.com',
      password: 'admin123',
      role: 'admin',
      isAdmin: true,
    ),
  ];
  final List<Order> _orders = [];
  AppUser? _currentUser;
  String? _authToken;
  int _nextOrderId = 1001;
  int _nextProductId = 100;

  AppState({
    ProductRepository? productRepository,
    CartState? cart,
    StorageService? storageService,
    TokenStorageService? tokenStorage,
    ApiClient? apiClient,
    List<Product>? initialProducts,
  })  : productRepository = productRepository ?? LocalProductRepository(),
        cart = cart ?? CartState(),
        storageService = storageService ?? const SharedPreferencesStorageService(),
        tokenStorage = tokenStorage ?? SecureTokenStorageService(),
        apiClient = apiClient ?? defaultApiClient,
        products = initialProducts ?? buildSampleProducts() {
    this.cart.addListener(_onCartChanged);
    this.apiClient.onUnauthorized = _onUnauthorized;
  }

  void _onCartChanged() {
    storageService.saveCart(cart.items);
  }

  void _onUnauthorized() {
    debugPrint('Interceptor 401 detectado: Limpiando sesión expirada');
    logout();
  }

  /// Inicializa la persistencia local restaurando token JWT seguro, usuario, pedidos y carrito.
  Future<void> initPersistence() async {
    try {
      // 1. Restaurar datos de usuario no confidenciales desde SharedPreferences
      final savedUser = await storageService.loadUser();
      if (savedUser != null) {
        _currentUser = savedUser;
      }

      // 2. Restaurar token JWT desde almacenamiento seguro (flutter_secure_storage)
      final savedToken = await tokenStorage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _authToken = savedToken;
        apiClient.setAuthToken(savedToken);
      } else if (savedUser != null) {
        _authToken = 'jwt_offline_${savedUser.email.hashCode}';
        apiClient.setAuthToken(_authToken);
      } else {
        _authToken = null;
        _currentUser = null;
        apiClient.setAuthToken(null);
      }

      // 3. Restaurar pedidos
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

  // ---------------------------------------------------------------
  // Autenticación y control de sesión JWT
  // ---------------------------------------------------------------

  AppUser? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null;
  bool get hasToken => _authToken != null && _authToken!.isNotEmpty;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Vista previa segura del token JWT (primeros caracteres sin exponer el secreto)
  String get tokenPreview {
    if (_authToken == null || _authToken!.isEmpty) return 'No existe token almacenado';
    if (_authToken!.length > 25) {
      return '${_authToken!.substring(0, 18)}...[Protegido]';
    }
    return _authToken!;
  }

  /// Inicia sesión validando credenciales contra el backend y obteniendo JWT.
  /// Si el backend no está disponible (modo offline/tests), usa fallback local.
  Future<String?> login(String email, String password) async {
    final e = email.trim();
    final p = password;
    if (e.isEmpty || p.isEmpty) {
      return 'Por favor ingresa correo y contraseña.';
    }

    try {
      final res = await apiClient.post('/auth/login', body: {
        'email': e,
        'password': p,
      });

      if (res is Map<String, dynamic> && res['token'] != null) {
        final token = res['token'] as String;
        final userData = res['data'] as Map<String, dynamic>;
        final user = AppUser.fromJson(userData);

        _authToken = token;
        _currentUser = user;
        apiClient.setAuthToken(token);

        await tokenStorage.saveToken(token);
        await storageService.saveUser(user);

        notifyListeners();
        return null;
      }
      return 'Respuesta inesperada del servidor de autenticación.';
    } on ApiException catch (err) {
      if (err.statusCode == 401) {
        return 'Credenciales incorrectas: correo o contraseña no válidos.';
      }
      if (err.code == 'NETWORK_ERROR') {
        // Fallback para ejecución offline o pruebas sin servidor corriendo
        final localResult = _localLogin(e, p);
        if (localResult == null) return null;
        return 'No se pudo conectar con el servidor backend. ($localResult)';
      }
      return err.message;
    } catch (err) {
      // Fallback offline ante cualquier excepción de red
      final localResult = _localLogin(e, p);
      if (localResult == null) return null;
      return 'Error de autenticación: $err';
    }
  }

  /// Validación local de respaldo (fallback) para pruebas unitarias y modo offline
  String? _localLogin(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email.toLowerCase() == e && user.password == password) {
        _currentUser = user;
        _authToken = 'jwt_offline_token_${user.email.hashCode}';
        apiClient.setAuthToken(_authToken);
        tokenStorage.saveToken(_authToken!);
        storageService.saveUser(_currentUser);
        notifyListeners();
        return null;
      }
    }
    return 'Correo o contraseña incorrectos.';
  }

  /// Acceso rápido como administrador para presentaciones y pruebas.
  void loginAsAdmin() {
    _currentUser = _users.firstWhere((u) => u.isAdmin);
    _authToken = 'jwt_offline_admin_token';
    apiClient.setAuthToken(_authToken);
    tokenStorage.saveToken(_authToken!);
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Acceso rápido como cliente estándar para presentaciones y pruebas.
  void loginAsCustomer() {
    _currentUser = _users.firstWhere((u) => !u.isAdmin);
    _authToken = 'jwt_offline_customer_token';
    apiClient.setAuthToken(_authToken);
    tokenStorage.saveToken(_authToken!);
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Permite el ingreso flexible para demostraciones.
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
        role: asAdmin ? 'admin' : 'customer',
        isAdmin: asAdmin || email.contains('admin'),
      );
      _users.add(newUser);
      _currentUser = newUser;
    }
    _authToken = 'jwt_flexible_token_${_currentUser!.email.hashCode}';
    apiClient.setAuthToken(_authToken);
    tokenStorage.saveToken(_authToken!);
    storageService.saveUser(_currentUser);
    notifyListeners();
  }

  /// Registro de nuevo usuario.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final n = name.trim();
    final e = email.trim().toLowerCase();
    if (n.isEmpty) return 'Escribe tu nombre.';
    if (!e.contains('@') || !e.contains('.')) {
      return 'Escribe un correo válido.';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    try {
      final res = await apiClient.post('/auth/register', body: {
        'name': n,
        'email': e,
        'password': password,
      });

      if (res is Map<String, dynamic> && res['token'] != null) {
        final token = res['token'] as String;
        final userData = res['data'] as Map<String, dynamic>;
        final user = AppUser.fromJson(userData);

        _authToken = token;
        _currentUser = user;
        apiClient.setAuthToken(token);

        await tokenStorage.saveToken(token);
        await storageService.saveUser(user);

        notifyListeners();
        return null;
      }
      return 'Respuesta inesperada al registrar usuario.';
    } on ApiException catch (err) {
      if (err.statusCode == 409) {
        return 'Ya existe una cuenta registrada con ese correo electrónico.';
      }
      if (err.code == 'NETWORK_ERROR') {
        // Fallback offline
        if (_users.any((u) => u.email == e)) {
          return 'Ya existe una cuenta con ese correo.';
        }
        final user = AppUser(name: n, email: e, password: password);
        _users.add(user);
        _currentUser = user;
        _authToken = 'jwt_offline_token_${user.email.hashCode}';
        tokenStorage.saveToken(_authToken!);
        storageService.saveUser(_currentUser);
        notifyListeners();
        return null;
      }
      return err.message;
    } catch (_) {
      if (_users.any((u) => u.email == e)) {
        return 'Ya existe una cuenta con ese correo.';
      }
      final user = AppUser(name: n, email: e, password: password);
      _users.add(user);
      _currentUser = user;
      _authToken = 'jwt_offline_token_${user.email.hashCode}';
      tokenStorage.saveToken(_authToken!);
      storageService.saveUser(_currentUser);
      notifyListeners();
      return null;
    }
  }

  /// Cierra la sesión eliminando el token de almacenamiento seguro y los datos locales de usuario.
  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    apiClient.setAuthToken(null);
    try {
      await tokenStorage.deleteToken();
      await storageService.saveUser(null);
    } catch (e) {
      debugPrint('Error al limpiar credenciales en logout: $e');
    }
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
