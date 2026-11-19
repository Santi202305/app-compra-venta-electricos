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

  async createProduct(data: Omit<Product, 'id'>): Promise<Product> {
    if (!data.name || !data.sku || data.price === undefined) {
      throw new AppError('Datos incompletos para crear el producto (name, sku y price son requeridos)', 400, 'INVALID_DATA');
    }
    const existing = await this.repository.findBySku(data.sku);
    if (existing) {
      throw new AppError(`Ya existe un producto con el SKU ${data.sku}`, 409, 'SKU_ALREADY_EXISTS');
    }
    return this.repository.create(data);
  }

  async updateProduct(id: number, data: Partial<Omit<Product, 'id'>>): Promise<Product> {
    if (isNaN(id) || id <= 0) {
      throw new AppError('El ID del producto debe ser un entero positivo válido', 400, 'INVALID_ID');
    }
    const updated = await this.repository.update(id, data);
    if (!updated) {
      throw new AppError(`Producto con ID ${id} no encontrado para actualizar`, 404, 'PRODUCT_NOT_FOUND');
    }
    return updated;
  }

  async deleteProduct(id: number): Promise<boolean> {
    if (isNaN(id) || id <= 0) {
      throw new AppError('El ID del producto debe ser un entero positivo válido', 400, 'INVALID_ID');
    }
    const deleted = await this.repository.delete(id);
    if (!deleted) {
      throw new AppError(`Producto con ID ${id} no encontrado para eliminar`, 404, 'PRODUCT_NOT_FOUND');
    }
    return true;
  }
}

export const defaultProductService = new ProductService();
