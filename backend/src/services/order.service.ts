import { Order, OrderItem, CreateOrderDTO } from '../models/order.model';
import { OrderRepository, defaultOrderRepository } from '../repositories/order.repository';
import { ProductRepository, defaultProductRepository } from '../repositories/product.repository';
import { AppError } from './product.service';

const NATIONAL_SHIPPING_COST = 12000; // 12.000 COP según kShippingCost

export class OrderService {
  private orderRepository: OrderRepository;
  private productRepository: ProductRepository;

  constructor(
    orderRepository: OrderRepository = defaultOrderRepository,
    productRepository: ProductRepository = defaultProductRepository
  ) {
    this.orderRepository = orderRepository;
    this.productRepository = productRepository;
  }

  async createOrder(data: CreateOrderDTO): Promise<Order> {
    const items: OrderItem[] = [];
    let subtotal = 0;

    // Validar cada producto y su inventario
    for (const itemInput of data.items) {
      const product = await this.productRepository.findById(itemInput.productId);
      if (!product) {
        throw new AppError(
          `El producto con ID ${itemInput.productId} no existe en el catálogo`,
          400,
          'PRODUCT_NOT_FOUND'
        );
      }

      if (product.stock < itemInput.quantity) {
        throw new AppError(
          `Inventario insuficiente para ${product.name}. Stock actual: ${product.stock}, solicitado: ${itemInput.quantity}`,
          400,
          'INSUFFICIENT_STOCK'
        );
      }

      const itemSubtotal = product.price * itemInput.quantity;
      subtotal += itemSubtotal;

      items.push({
        productId: product.id,
        productName: product.name,
        sku: product.sku,
        unitPrice: product.price,
        quantity: itemInput.quantity,
        subtotal: itemSubtotal,
      });

      // Descontar inventario disponible
      await this.productRepository.update(product.id, {
        stock: product.stock - itemInput.quantity,
      });
    }

    const total = subtotal + NATIONAL_SHIPPING_COST;
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomHex = Math.floor(1000 + Math.random() * 9000).toString();
    const trackingNumber = `ELC-${dateStr}-${randomHex}`;
    const orderId = 'ord_' + Math.random().toString(36).substring(2, 9) + Date.now().toString(36);

    const newOrder: Order = {
      id: orderId,
      trackingNumber,
      customerName: data.customerName.trim(),
      customerEmail: data.customerEmail.toLowerCase().trim(),
      shippingAddress: data.shippingAddress.trim(),
      paymentMethod: data.paymentMethod,
      status: 'pending',
      items,
      subtotal,
      shippingCost: NATIONAL_SHIPPING_COST,
      total,
      createdAt: new Date().toISOString(),
    };

    return this.orderRepository.create(newOrder);
  }

  async getOrderById(id: string): Promise<Order> {
    const order = await this.orderRepository.findById(id);
    if (!order) {
      throw new AppError(`Pedido con ID ${id} no encontrado`, 404, 'ORDER_NOT_FOUND');
    }
    return order;
  }

  async getOrderByTracking(trackingNumber: string): Promise<Order> {
    const order = await this.orderRepository.findByTrackingNumber(trackingNumber);
    if (!order) {
      throw new AppError(`Pedido con número de guía ${trackingNumber} no encontrado`, 404, 'ORDER_NOT_FOUND');
    }
    return order;
  }
}

export const defaultOrderService = new OrderService();
