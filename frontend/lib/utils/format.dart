/// Formatea un valor en pesos colombianos con separador de miles.
/// Ejemplo: 38900 -> $38.900
String formatCop(int value) {
  final s = value.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buffer.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return value < 0 ? '-\$$buffer' : '\$$buffer';
}

/// Fecha y hora simples: 28/10/2026 14:05
String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
