enum OrderStatus { pendiente, enCamino, entregado }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.enCamino:
        return 'En camino';
      case OrderStatus.entregado:
        return 'Entregado';
    }
  }
}

class OrderLine {
  final String productName;
  final String sku;
  final int unitPrice;
  final int qty;

  const OrderLine({
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.qty,
  });

  int get total => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'sku': sku,
        'unitPrice': unitPrice,
        'qty': qty,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        productName: json['productName'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        unitPrice: json['unitPrice'] as int? ?? 0,
        qty: json['qty'] as int? ?? 1,
      );
}

class Order {
  final int id;
  final DateTime date;
  final String userEmail;
  final List<OrderLine> lines;
  final int subtotal;
  final int shipping;
  final String paymentLabel;
  final String address;
  OrderStatus status;

  Order({
    required this.id,
    required this.date,
    required this.userEmail,
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.paymentLabel,
    required this.address,
    this.status = OrderStatus.pendiente,
  });

  int get total => subtotal + shipping;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'userEmail': userEmail,
        'lines': lines.map((l) => l.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'paymentLabel': paymentLabel,
        'address': address,
        'status': status.name,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pendiente';
    final parsedStatus = OrderStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => OrderStatus.pendiente,
    );
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    final lines = rawLines
        .map((l) => OrderLine.fromJson(Map<String, dynamic>.from(l as Map)))
        .toList();

    return Order(
      id: json['id'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      userEmail: json['userEmail'] as String? ?? '',
      lines: lines,
      subtotal: json['subtotal'] as int? ?? 0,
      shipping: json['shipping'] as int? ?? 0,
      paymentLabel: json['paymentLabel'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: parsedStatus,
    );
  }
}
