import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

/// Etiqueta de disponibilidad. Usa color + ícono + texto, y el texto va
/// siempre en tinta (el estado nunca se comunica solo con el color).
class StockBadge extends StatelessWidget {
  final Product product;
  final bool compact;

  const StockBadge({super.key, required this.product, this.compact = false});

  Color get _color {
    switch (product.stockStatus) {
      case StockStatus.disponible:
        return AppColors.success;
      case StockStatus.pocas:
        return AppColors.warm;
      case StockStatus.agotado:
        return AppColors.danger;
    }
  }

  String get _text {
    switch (product.stockStatus) {
      case StockStatus.disponible:
        return compact ? 'Disponible' : '${product.stock} unidades disponibles';
      case StockStatus.pocas:
        return compact
            ? 'Quedan ${product.stock}'
            : 'Quedan solo ${product.stock} unidades';
      case StockStatus.agotado:
        return compact ? 'Agotado' : 'Agotado por ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: compact ? 8 : 10, color: _color),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              _text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: compact ? 10.5 : 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
