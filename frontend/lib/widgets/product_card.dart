import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'stock_badge.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final soldOut = product.stockStatus == StockStatus.agotado;

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focused
                    ? AppColors.primary
                    : (_hovered ? AppColors.primary.withValues(alpha: 0.7) : AppColors.borderSubtle),
                width: (_focused || _hovered) ? 1.5 : 1.0,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de producto con Semantics y badges
                Stack(
                  children: [
                    Semantics(
                      label: product.name,
                      image: true,
                      child: Container(
                        height: 98,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            product.resolvedImageAsset,
                            fit: BoxFit.contain,
                            cacheWidth: 320,
                            cacheHeight: 320,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                product.icon,
                                color: product.category.iconColor,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pill de categoría
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.label,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Rating o Tag
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: product.featuredTag != null
                            ? Text(
                                product.featuredTag!,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warm,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 10, color: Color(0xFFEAB308)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.rating}',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nombre con Tooltip
                Tooltip(
                  message: product.name,
                  waitDuration: const Duration(milliseconds: 600),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      height: 1.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // SKU
                Text(
                  product.sku,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mist,
                  ),
                ),

                // shortDescription (máx 2 líneas)
                if (product.shortDescription.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    product.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.25,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
                const SizedBox(height: 4),

                // Badge de disponibilidad
                StockBadge(product: product, compact: true),

                const Spacer(),

                // Precio y botón de agregar con Tooltip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        formatCop(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: soldOut ? 'Producto agotado' : 'Agregar 1 unidad al carrito',
                      child: Material(
                        color: soldOut ? const Color(0xFFE2E8F0) : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          onTap: soldOut ? null : widget.onQuickAdd,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 16,
                              color: soldOut ? const Color(0xFF94A3B8) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
