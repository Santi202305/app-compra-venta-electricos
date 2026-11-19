import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/breakpoints.dart';
import '../widgets/product_card.dart';
import 'about_screen.dart';
import 'admin_screen.dart';
import 'cart_screen.dart';
import 'chat_bot_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';
import 'session_info_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState app;
  const HomeScreen({super.key, required this.app});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductCategory _selected = ProductCategory.todos;
  String _query = '';
  bool _onlyAvailable = false;
  int _navIndex = 0;

  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.app.products.where((p) {
      if (_selected != ProductCategory.todos && p.category != _selected) {
        return false;
      }
      if (_onlyAvailable && p.stock <= 0) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          p.shortDescription.toLowerCase().contains(q) ||
          p.longDescription.toLowerCase().contains(q) ||
          p.specsText.toLowerCase().contains(q) ||
          p.applications.any((app) => app.toLowerCase().contains(q));
    }).toList();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _onMenu(String value) {
    switch (value) {
      case 'orders':
        _push(OrdersScreen(app: widget.app));
        break;
      case 'about':
        _push(const AboutScreen());
        break;
      case 'admin':
        _push(AdminScreen(app: widget.app));
        break;
      case 'session':
        _push(SessionInfoScreen(app: widget.app));
        break;
      case 'logout':
        widget.app.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen(app: widget.app)),
          (route) => false,
        );
        break;
    }
  }

  void _onNavDestinationSelected(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        // Catálogo principal
        break;
      case 1:
        _push(CartScreen(app: widget.app));
        break;
      case 2:
        _push(OrdersScreen(app: widget.app));
        break;
      case 3:
        _push(ChatBotScreen(app: widget.app));
        break;
      case 4:
        _push(const AboutScreen());
        break;
      case 5:
        if (widget.app.isAdmin) {
          _push(AdminScreen(app: widget.app));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final user = app.currentUser;
    final sizeClass = context.screenSizeClass;
    final isDesktopOrTablet = sizeClass != ScreenSizeClass.compact;

    final catalogBody = AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final products = _filtered;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
            child: Scrollbar(
              child: CustomScrollView(
                slivers: [
                  // Hero Banner Informativo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E3A5F)),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.warm.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 13, color: AppColors.warm),
                                        SizedBox(width: 4),
                                        Text(
                                          'CERTIFICACIÓN RETIE',
                                          style: TextStyle(
                                            color: AppColors.warm,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Materiales Eléctricos e Industriales',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Inventario en tiempo real con cotización y asistente 24/7.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (sizeClass != ScreenSizeClass.compact) ...[
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _push(ChatBotScreen(app: app)),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.smart_toy, color: Colors.white, size: 26),
                                      SizedBox(height: 4),
                                      Text(
                                        'Asistente IA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Buscador
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Buscar por producto, calibre, SKU, norma...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.mist),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mist),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => setState(() => _query = ''),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Carrusel de Categorías
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount: ProductCategory.values.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = ProductCategory.values[i];
                          final isSelected = _selected == cat;
                          return ChoiceChip(
                            avatar: Icon(
                              cat.icon,
                              size: 15,
                              color: isSelected ? Colors.white : cat.iconColor,
                            ),
                            label: Text(cat.label),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.ink,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onSelected: (_) => setState(() => _selected = cat),
                          );
                        },
                      ),
                    ),
                  ),

                  // Switch de solo disponibles
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _onlyAvailable,
                              activeTrackColor: AppColors.accent,
                              onChanged: (v) => setState(() => _onlyAvailable = v),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Solo disponibles en bodega',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mist,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contador de resultados
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${products.length} productos encontrados',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mist,
                            ),
                          ),
                          if (_selected != ProductCategory.todos || _onlyAvailable || _query.isNotEmpty)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selected = ProductCategory.todos;
                                  _onlyAvailable = false;
                                  _query = '';
                                });
                              },
                              child: const Text(
                                'Restablecer filtros',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Grid Responsivo de Productos con MaxCrossAxisExtent
                  if (app.isLoadingProducts)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Cargando catálogo técnico...',
                              style: TextStyle(fontSize: 13, color: AppColors.mist),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (app.productsError != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: AppColors.danger),
                              const SizedBox(height: 12),
                              Text(
                                app.productsError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () => app.loadProducts(),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off, size: 54, color: AppColors.mist),
                            const SizedBox(height: 12),
                            const Text(
                              'No encontramos productos con esos filtros.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selected = ProductCategory.todos;
                                      _onlyAvailable = false;
                                      _query = '';
                                    });
                                  },
                                  child: const Text('Ver todo el catálogo'),
                                ),
                              ],
                            ),
                          ),
                        )
                  else
                    SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => _push(ProductDetailScreen(
                                    product: product,
                                    app: app,
                                  )),
                                  onQuickAdd: () {
                                    final ok = app.cart.addProduct(product, 1);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              ok ? Icons.check_circle : Icons.warning_amber_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                ok
                                                    ? '${product.name} agregado al carrito'
                                                    : 'No hay más stock de ${product.name}',
                                              ),
                                            ),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: products.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user == null ? 'Catálogo General' : 'Hola, ${user.firstName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          color: app.isAdmin ? AppColors.warm : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        app.isAdmin
                            ? 'Administrador · Modo Gestión'
                            : (app.isLoggedIn ? 'Cliente Autenticado' : 'Invitado'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mist,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Botón del Asistente Virtual
          IconButton(
            tooltip: 'Asistente virtual IA',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF0284C7), size: 20),
            ),
            onPressed: () => _push(ChatBotScreen(app: app)),
          ),

          // Botón del Carrito con Badge Dinámico
          AnimatedBuilder(
            animation: app.cart,
            builder: (context, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  tooltip: 'Carrito',
                  icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                  onPressed: () => _push(CartScreen(app: app)),
                ),
                if (app.cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${app.cart.totalItems}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Menú Opciones
          PopupMenuButton<String>(
            onSelected: _onMenu,
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Mis pedidos'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                    SizedBox(width: 10),
                    Text('Acerca de la app'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'session',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: AppColors.accent),
                    SizedBox(width: 10),
                    Text('Información de sesión (JWT)'),
                  ],
                ),
              ),
              if (app.isAdmin)
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, size: 18, color: AppColors.warm),
                      SizedBox(width: 10),
                      Text('Panel administrativo', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      app.isLoggedIn ? Icons.logout : Icons.login,
                      size: 18,
                      color: app.isLoggedIn ? AppColors.danger : AppColors.accent,
                    ),
                    const SizedBox(width: 10),
                    Text(app.isLoggedIn ? 'Cerrar sesión' : 'Iniciar sesión'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isDesktopOrTablet
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _navIndex,
                  onDestinationSelected: _onNavDestinationSelected,
                  extended: sizeClass == ScreenSizeClass.expanded,
                  minWidth: 72,
                  minExtendedWidth: 200,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.accent, size: 24),
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: Text('Catálogo'),
                    ),
                    NavigationRailDestination(
                      icon: AnimatedBuilder(
                        animation: app.cart,
                        builder: (context, _) => Badge(
                          isLabelVisible: app.cart.totalItems > 0,
                          label: Text('${app.cart.totalItems}'),
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                      ),
                      selectedIcon: const Icon(Icons.shopping_cart),
                      label: const Text('Carrito'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Pedidos'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.smart_toy_outlined),
                      selectedIcon: Icon(Icons.smart_toy),
                      label: Text('Asistente IA'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: Text('Acerca de'),
                    ),
                    if (app.isAdmin)
                      const NavigationRailDestination(
                        icon: Icon(Icons.dashboard_customize_outlined),
                        selectedIcon: Icon(Icons.dashboard_customize),
                        label: Text('Admin'),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                Expanded(child: catalogBody),
              ],
            )
          : catalogBody,
      bottomNavigationBar: !isDesktopOrTablet
          ? NavigationBar(
              selectedIndex: _navIndex.clamp(0, 4),
              onDestinationSelected: _onNavDestinationSelected,
              height: 64,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Catálogo',
                ),
                NavigationDestination(
                  icon: AnimatedBuilder(
                    animation: app.cart,
                    builder: (context, _) => Badge(
                      isLabelVisible: app.cart.totalItems > 0,
                      label: Text('${app.cart.totalItems}'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
                  selectedIcon: const Icon(Icons.shopping_cart),
                  label: 'Carrito',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pedidos',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.smart_toy_outlined),
                  selectedIcon: Icon(Icons.smart_toy),
                  label: 'Asistente',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: 'Acerca de',
                ),
              ],
            )
          : null,
    );
  }
}
