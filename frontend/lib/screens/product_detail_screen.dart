import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/breakpoints.dart';
import '../utils/format.dart';
import '../widgets/stock_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final AppState app;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.app,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  void _changeQty(int delta) {
    final max = widget.product.stock;
    if (max <= 0) return;
    int next = _qty + delta;
    if (next < 1) next = 1;
    if (next > max) next = max;
    setState(() => _qty = next);
  }

  void _addToCart() {
    final ok = widget.app.cart.addProduct(widget.product, _qty);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ok
                    ? '${widget.product.name} (x$_qty) agregado al carrito'
                    : 'Ya tienes todas las unidades disponibles en el carrito',
              ),
            ),
          ],
        ),
        backgroundColor: ok ? AppColors.ink : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final soldOut = product.stockStatus == StockStatus.agotado;
    final isExpanded = context.isExpanded;

    final imageWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: product.name,
          image: true,
          child: Container(
            height: isExpanded ? 340 : 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    product.resolvedImageAsset,
                    fit: BoxFit.contain,
                    cacheWidth: 800,
                    cacheHeight: 800,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        product.icon,
                        size: 90,
                        color: product.category.iconColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(product.category.icon, size: 14, color: product.category.iconColor),
                        const SizedBox(width: 5),
                        Text(
                          product.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: product.category.iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (product.imageCredit != null) ...[
          const SizedBox(height: 6),
          Text(
            'Crédito: ${product.imageCredit}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );

    final technicalDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre y SKU
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mistLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                'SKU: ${product.sku}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mist,
                ),
              ),
            ),
            StockBadge(product: product),
            if (product.brand != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: SelectableText(
                  product.brand!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
          ],
        ),

        // Descripción Larga
        if (product.longDescription.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            product.longDescription,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF334155),
            ),
          ),
        ],

        const SizedBox(height: 18),
        const Divider(color: AppColors.border),
        const SizedBox(height: 12),

        // Ficha Técnica / Tabla de Specs
        if (product.specs.isNotEmpty) ...[
          const Text(
            'Especificaciones Técnicas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < product.specs.entries.length; i++)
                  Container(
                    color: i.isEven ? const Color(0xFFF8FAFC) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: SelectableText(
                            product.specs.entries.elementAt(i).key,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: SelectableText(
                            product.specs.entries.elementAt(i).value,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Aplicaciones
        if (product.applications.isNotEmpty) ...[
          const Text(
            'Aplicaciones y Usos Típicos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final appText in product.applications)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appText,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Contenido del empaque (Includes)
        if (product.includes != null && product.includes!.isNotEmpty) ...[
          const Text(
            'Contenido del Empaque',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in product.includes!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.all_inbox_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Normas y Certificaciones (Standards)
        if (product.standards != null && product.standards!.isNotEmpty) ...[
          const Text(
            'Normas y Certificaciones',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final std in product.standards!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            std,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Garantía
        if (product.warranty != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, size: 18, color: Color(0xFF16A34A)),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    'Garantía: ${product.warranty!}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    final purchaseBar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isExpanded ? BorderRadius.circular(8) : null,
        border: isExpanded
            ? Border.all(color: AppColors.border)
            : const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Precio unitario',
                  style: TextStyle(fontSize: 10.5, color: AppColors.mist),
                ),
                Text(
                  formatCop(product.price),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            if (!soldOut) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mistLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeQty(-1),
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '$_qty',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeQty(1),
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: soldOut ? null : _addToCart,
                icon: Icon(
                  soldOut ? Icons.block : Icons.add_shopping_cart,
                  size: 16,
                ),
                label: Text(soldOut ? 'Agotado' : 'Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: soldOut ? Colors.grey : AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enlace del producto copiado al portapapeles.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: isExpanded
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda: Imagen y compra
                      SizedBox(
                        width: 420,
                        child: Column(
                          children: [
                            imageWidget,
                            const SizedBox(height: 16),
                            purchaseBar,
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                      // Columna derecha: Ficha técnica completa
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: technicalDetails,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageWidget,
                        const SizedBox(height: 16),
                        technicalDetails,
                      ],
                    ),
                  ),
                ),
                purchaseBar,
              ],
            ),
    );
  }
}
