import { Request, Response, NextFunction } from 'express';
import { ProductQuerySchema } from '../models/product.model';
import { ProductService, defaultProductService } from '../services/product.service';

export class ProductController {
  private service: ProductService;

  constructor(service: ProductService = defaultProductService) {
    this.service = service;
  }

  public getProducts = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedQuery = ProductQuerySchema.parse(req.query);
      const result = await this.service.listProducts(validatedQuery);
      res.status(200).json({
        success: true,
        data: result.items,
        pagination: {
          total: result.total,
          limit: result.limit,
          offset: result.offset,
        },
      });
    } catch (error) {
      next(error);
    }
  };

  public getProductById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const id = parseInt(req.params.id, 10);
      const product = await this.service.getProductById(id);
      res.status(200).json({
        success: true,
        data: product,
      });
    } catch (error) {
      next(error);
    }
  };
}

export const productController = new ProductController();
