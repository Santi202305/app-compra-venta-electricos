import 'package:flutter/material.dart';

/// Clasificación de pantallas conforme a estándares de diseño responsivo.
/// - compact: ancho < 600 px (teléfonos móviles en cualquier orientación vertical).
/// - medium: ancho entre 600 y 1024 px (tablets, teléfonos en horizontal, plegables).
/// - expanded: ancho > 1024 px (pantallas de escritorio, laptops y monitores widescreen).
enum ScreenSizeClass {
  compact,
  medium,
  expanded,
}

class Breakpoints {
  Breakpoints._();

  static const double compactMax = 600;
  static const double mediumMax = 1024;
  static const double maxContentWidth = 1200;

  static ScreenSizeClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactMax) return ScreenSizeClass.compact;
    if (width <= mediumMax) return ScreenSizeClass.medium;
    return ScreenSizeClass.expanded;
  }

  static ScreenSizeClass fromWidth(double width) {
    if (width < compactMax) return ScreenSizeClass.compact;
    if (width <= mediumMax) return ScreenSizeClass.medium;
    return ScreenSizeClass.expanded;
  }
}

extension ResponsiveContext on BuildContext {
  ScreenSizeClass get screenSizeClass => Breakpoints.of(this);
  bool get isCompact => screenSizeClass == ScreenSizeClass.compact;
  bool get isMedium => screenSizeClass == ScreenSizeClass.medium;
  bool get isExpanded => screenSizeClass == ScreenSizeClass.expanded;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

/// Widget constructor responsivo basado en LayoutBuilder para tomar decisiones
/// sobre las restricciones del contenedor actual, no del sistema operativo.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSizeClass sizeClass) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = Breakpoints.fromWidth(constraints.maxWidth);
        return builder(context, sizeClass);
      },
    );
  }
}
