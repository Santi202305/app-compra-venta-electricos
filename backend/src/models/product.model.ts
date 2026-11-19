import { z } from 'zod';

export type ProductCategory = 'todos' | 'cables' | 'proteccion' | 'iluminacion' | 'herramientas';

export interface TechnicalSpecs {
  voltage?: string;
  amperage?: string;
  certification?: string; // RETIE, CIDET, NTC 2050
  material?: string;
  gauge?: string;
}

export interface Product {
  id: number;
  name: string;
  sku: string;
  category: ProductCategory;
  price: number; // En pesos colombianos (COP)
  stock: number;
  description: string;
  technicalSpecs: TechnicalSpecs;
  retieCompliant: boolean;
  colorHex?: string;
  iconName?: string;
}

export const ProductQuerySchema = z.object({
  category: z.enum(['todos', 'cables', 'proteccion', 'iluminacion', 'herramientas']).optional(),
  search: z.string().trim().optional(),
  inStockOnly: z
    .string()
    .optional()
    .transform((val) => val === 'true'),
  limit: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 50)),
  offset: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 0)),
});

export type ProductQueryParams = z.infer<typeof ProductQuerySchema>;
