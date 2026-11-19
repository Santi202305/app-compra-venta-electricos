import { Order } from '../models/order.model';

export class OrderRepository {
  private orders: Order[] = [];

  async create(order: Order): Promise<Order> {
    this.orders.push({ ...order });
    return { ...order };
  }

  async findById(id: string): Promise<Order | null> {
    const order = this.orders.find((o) => o.id === id);
    return order ? { ...order } : null;
  }

  async findByTrackingNumber(trackingNumber: string): Promise<Order | null> {
    const order = this.orders.find((o) => o.trackingNumber.toUpperCase() === trackingNumber.toUpperCase());
    return order ? { ...order } : null;
  }

  async findAll(): Promise<Order[]> {
    return this.orders.map((o) => ({ ...o }));
  }
}

export const defaultOrderRepository = new OrderRepository();
