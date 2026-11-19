import { z } from 'zod';

export type PaymentMethod = 'nequi' | 'efecty' | 'tarjeta' | 'bancolombia';
export type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';

export interface OrderItem {
  productId: number;
  productName: string;
  sku: string;
  unitPrice: number;
  quantity: number;
  subtotal: number;
}

export interface Order {
  id: string;
  trackingNumber: string;
  customerName: string;
  customerEmail: string;
  shippingAddress: string;
  paymentMethod: PaymentMethod;
  status: OrderStatus;
  items: OrderItem[];
  subtotal: number;
  shippingCost: number; // 12000 COP
  total: number;
  createdAt: string;
}

export const OrderItemInputSchema = z.object({
  productId: z.number().int().positive('ID de producto inválido'),
  quantity: z.number().int().positive('La cantidad debe ser mayor a cero'),
});

export const CreateOrderSchema = z.object({
  customerName: z.string().min(2, 'El nombre debe tener al menos 2 caracteres'),
  customerEmail: z.string().email('Correo de contacto inválido'),
  shippingAddress: z.string().min(5, 'La dirección de entrega debe ser válida'),
  paymentMethod: z.enum(['nequi', 'efecty', 'tarjeta', 'bancolombia']),
  items: z.array(OrderItemInputSchema).min(1, 'El pedido debe incluir al menos un producto'),
});

export type CreateOrderDTO = z.infer<typeof CreateOrderSchema>;
