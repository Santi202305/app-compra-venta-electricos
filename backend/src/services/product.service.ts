import { Product, ProductQueryParams } from '../models/product.model';
import { ProductRepository, defaultProductRepository } from '../repositories/product.repository';

export class AppError extends Error {
  public statusCode: number;
  public code: string;
  public details: any[];

  constructor(message: string, statusCode: number = 400, code: string = 'BAD_REQUEST', details: any[] = []) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

export class ProductService {
  private repository: ProductRepository;

  constructor(repository: ProductRepository = defaultProductRepository) {
    this.repository = repository;
  }

  async listProducts(params: ProductQueryParams): Promise<{ items: Product[]; total: number; limit: number; offset: number }> {
    const limit = params.limit ?? 50;
    const offset = params.offset ?? 0;

    const { items, total } = await this.repository.findAll({
      category: params.category,
      search: params.search,
      inStockOnly: params.inStockOnly,
      limit,
      offset,
    });

    return {
      items,
      total,
      limit,
      offset,
    };
  }

  async getProductById(id: number): Promise<Product> {
    if (isNaN(id) || id <= 0) {
      throw new AppError('El ID del producto debe ser un entero positivo válido', 400, 'INVALID_ID');
    }

    const product = await this.repository.findById(id);
    if (!product) {
      throw new AppError(`Producto con ID ${id} no encontrado`, 404, 'PRODUCT_NOT_FOUND');
    }

    return product;
  }

  async validateStock(id: number, requestedQuantity: number): Promise<{ available: boolean; currentStock: number }> {
    if (requestedQuantity <= 0) {
      throw new AppError('La cantidad solicitada debe ser mayor a cero', 400, 'INVALID_QUANTITY');
    }

    const product = await this.getProductById(id);
    return {
      available: product.stock >= requestedQuantity,
      currentStock: product.stock,
    };
  }
}

export const defaultProductService = new ProductService();
