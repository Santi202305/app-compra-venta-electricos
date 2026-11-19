import { Request, Response, NextFunction } from 'express';
import { CreateOrderSchema } from '../models/order.model';
import { OrderService, defaultOrderService } from '../services/order.service';

export class OrderController {
  private service: OrderService;

  constructor(service: OrderService = defaultOrderService) {
    this.service = service;
  }

  public createOrder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedData = CreateOrderSchema.parse(req.body);
      const order = await this.service.createOrder(validatedData);
      res.status(201).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  };

  public getOrderById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const order = await this.service.getOrderById(req.params.id);
      res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  };

  public getOrderByTracking = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const order = await this.service.getOrderByTracking(req.params.trackingNumber);
      res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  };
}

export const orderController = new OrderController();
