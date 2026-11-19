import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/order_card.dart';
import '../widgets/stock_badge.dart';

/// Panel administrativo moderno del negocio: inventario (stock y
/// precios) y pedidos recibidos.
class AdminScreen extends StatelessWidget {
  final AppState app;
  const AdminScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    if (!app.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel Administrativo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_outlined, size: 54, color: AppColors.warm),
                const SizedBox(height: 14),
                const Text(
                  'Acceso Restringido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Inicia sesión con la cuenta de administrador para gestionar el catálogo y pedidos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.mist),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    app.loginAsAdmin();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Entrar como Administrador ahora'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: AppColors.warm, size: 24),
              SizedBox(width: 8),
              Text('Panel Administrativo'),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.mist,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2_outlined, size: 20),
                text: 'Inventario y Stock',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Control de Pedidos',
              ),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: app,
          builder: (context, _) => TabBarView(
            children: [
              _InventoryTab(app: app),
              _OrdersTab(app: app),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  final AppState app;
  const _InventoryTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final lowCount =
        app.products.where((p) => p.stockStatus == StockStatus.pocas).length;
    final soldOutCount =
        app.products.where((p) => p.stockStatus == StockStatus.agotado).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Métricas de inventario
        Row(
          children: [
            _KpiCard(
              label: 'Total Ítems',
              value: '${app.products.length}',
              icon: Icons.category_outlined,
              color: AppColors.accent,
            ),
            const SizedBox(width: 10),
            _KpiCard(
              label: 'Stock Crítico',
              value: '$lowCount',
              icon: Icons.warning_amber_rounded,
              color: AppColors.warm,
            ),
            const SizedBox(width: 10),
            _KpiCard(
              label: 'Agotados',
              value: '$soldOutCount',
              icon: Icons.error_outline,
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Botón Agregar Producto
        ElevatedButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => _ProductDialog(app: app),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('Agregar Nuevo Producto al Catálogo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de Productos
        ...app.products.map(
          (p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      p.resolvedImageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(p.icon, color: p.category.iconColor, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.sku} · ${formatCop(p.price)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.mist),
                      ),
                      const SizedBox(height: 4),
                      StockBadge(product: p, compact: true),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Editar stock y precio',
                  icon: const Icon(Icons.edit_note, size: 20),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _ProductDialog(app: app, product: p),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.mist, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final AppState app;
  const _OrdersTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final orders = app.allOrders;
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.mist),
              SizedBox(height: 12),
              Text(
                'Sin pedidos registrados aún',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Los pedidos confirmados en checkout se listarán aquí.',
                style: TextStyle(fontSize: 12.5, color: AppColors.mist),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: orders
          .map(
            (o) => OrderCard(
              order: o,
              showUser: true,
              trailing: PopupMenuButton<OrderStatus>(
                tooltip: 'Cambiar estado del pedido',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (status) => app.setOrderStatus(o, status),
                itemBuilder: (context) => OrderStatus.values
                    .map((s) => PopupMenuItem<OrderStatus>(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final AppState app;
  final Product? product;
  const _ProductDialog({required this.app, this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.product?.name ?? '');
  late final TextEditingController _sku =
      TextEditingController(text: widget.product?.sku ?? '');
  late final TextEditingController _specs =
      TextEditingController(text: widget.product?.specsText ?? '');
  late final TextEditingController _price =
      TextEditingController(text: '${widget.product?.price ?? ''}');
  late final TextEditingController _stock =
      TextEditingController(text: '${widget.product?.stock ?? ''}');
  ProductCategory _category = ProductCategory.cables;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _specs.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _save() {
    final stock = int.tryParse(_stock.text.trim());
    final price = int.tryParse(_price.text.trim());
    if (stock == null || stock < 0 || price == null || price <= 0) {
      setState(() => _error = 'Stock debe ser 0 o más y precio mayor a 0.');
      return;
    }
    if (_isEdit) {
      widget.app.updateProduct(widget.product!, stock: stock, price: price);
    } else {
      if (_name.text.trim().isEmpty || _sku.text.trim().isEmpty) {
        setState(() => _error = 'Escribe el nombre y SKU del producto.');
        return;
      }
      widget.app.addProduct(
        name: _name.text.trim(),
        sku: _sku.text.trim().toUpperCase(),
        category: _category,
        price: price,
        stock: stock,
        specs: _specs.text.trim(),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_isEdit ? 'Editar: ${widget.product!.name}' : 'Nuevo Material Eléctrico'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEdit) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sku,
                decoration: const InputDecoration(labelText: 'Código SKU (ej: BRK-20A)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _specs,
                decoration: const InputDecoration(labelText: 'Especificaciones (RETIE, voltaje...)'),
              ),
              const SizedBox(height: 14),
              const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: ProductCategory.values
                    .where((c) => c != ProductCategory.todos)
                    .map((c) => ChoiceChip(
                          avatar: Icon(c.icon, size: 14),
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio en Pesos (COP)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Unidades de Stock'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
