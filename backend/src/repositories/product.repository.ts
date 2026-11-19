import { Product, ProductCategory } from '../models/product.model';
import { INITIAL_PRODUCTS } from '../data/seed-products';

export interface ProductFilterOptions {
  category?: ProductCategory;
  search?: string;
  inStockOnly?: boolean;
  limit?: number;
  offset?: number;
}

export class ProductRepository {
  private products: Product[];

  constructor(initialData: Product[] = INITIAL_PRODUCTS) {
    // Clonación profunda en memoria para evitar mutaciones externas
    this.products = JSON.parse(JSON.stringify(initialData));
  }

  async findAll(options: ProductFilterOptions = {}): Promise<{ items: Product[]; total: number }> {
    let result = [...this.products];

    // Filtro por categoría (si no es 'todos')
    if (options.category && options.category !== 'todos') {
      result = result.filter((p) => p.category.toLowerCase() === options.category!.toLowerCase());
    }

    // Filtro por término de búsqueda (nombre, sku, descripción o material)
    if (options.search && options.search.trim().length > 0) {
      const query = options.search.toLowerCase().trim();
      result = result.filter(
        (p) =>
          p.name.toLowerCase().includes(query) ||
          p.sku.toLowerCase().includes(query) ||
          p.description.toLowerCase().includes(query) ||
          (p.technicalSpecs.material && p.technicalSpecs.material.toLowerCase().includes(query))
      );
    }

    // Filtro de solo productos con inventario disponible
    if (options.inStockOnly) {
      result = result.filter((p) => p.stock > 0);
    }

    const total = result.length;
    const offset = options.offset || 0;
    const limit = options.limit || 50;

    const items = result.slice(offset, offset + limit);

    return { items, total };
  }

  async findById(id: number): Promise<Product | null> {
    const product = this.products.find((p) => p.id === id);
    return product ? { ...product } : null;
  }

  async findBySku(sku: string): Promise<Product | null> {
    const product = this.products.find((p) => p.sku.toUpperCase() === sku.toUpperCase());
    return product ? { ...product } : null;
  }

  async create(data: Omit<Product, 'id'>): Promise<Product> {
    const nextId = this.products.length > 0 ? Math.max(...this.products.map((p) => p.id)) + 1 : 1;
    const newProduct: Product = {
      id: nextId,
      ...data,
    };
    this.products.push(newProduct);
    return { ...newProduct };
  }

  async update(id: number, data: Partial<Omit<Product, 'id'>>): Promise<Product | null> {
    const index = this.products.findIndex((p) => p.id === id);
    if (index === -1) return null;

    this.products[index] = {
      ...this.products[index],
      ...data,
      technicalSpecs: {
        ...this.products[index].technicalSpecs,
        ...(data.technicalSpecs || {}),
      },
    };

    return { ...this.products[index] };
  }

  async delete(id: number): Promise<boolean> {
    const index = this.products.findIndex((p) => p.id === id);
    if (index === -1) return false;
    this.products.splice(index, 1);
    return true;
  }
}

// Instancia singleton por defecto
export const defaultProductRepository = new ProductRepository();
