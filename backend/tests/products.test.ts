import request from 'supertest';
import { app } from '../src/app';

describe('Products API (/api/v1/products)', () => {
  it('debe listar los productos con paginación por defecto', async () => {
    const response = await request(app).get('/api/v1/products');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
    expect(response.body.data.length).toBeGreaterThan(0);
    expect(response.body.pagination).toBeDefined();
    expect(response.body.pagination.total).toBeGreaterThanOrEqual(10);
  });

  it('debe filtrar productos por categoría (ej. cables)', async () => {
    const response = await request(app).get('/api/v1/products?category=cables');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.length).toBeGreaterThan(0);
    response.body.data.forEach((product: any) => {
      expect(product.category).toBe('cables');
    });
  });

  it('debe buscar productos por término de texto (ej. Breaker)', async () => {
    const response = await request(app).get('/api/v1/products?search=Breaker');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.length).toBeGreaterThan(0);
    expect(response.body.data[0].name).toContain('Breaker');
  });

  it('debe obtener un producto existente por su ID', async () => {
    const response = await request(app).get('/api/v1/products/1');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id', 1);
    expect(response.body.data).toHaveProperty('sku', 'BRK-220-20A');
    expect(response.body.data).toHaveProperty('retieCompliant', true);
  });

  it('debe devolver 404 con formato estándar cuando el producto no existe', async () => {
    const response = await request(app).get('/api/v1/products/9999');

    expect(response.status).toBe(404);
    expect(response.body.success).toBe(false);
    expect(response.body.error).toBeDefined();
    expect(response.body.error.code).toBe('PRODUCT_NOT_FOUND');
    expect(response.body.error.message).toContain('no encontrado');
  });

  it('debe devolver 400 cuando el ID proporcionado es inválido (no numérico)', async () => {
    const response = await request(app).get('/api/v1/products/invalido');

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.error).toBeDefined();
    expect(response.body.error.code).toBe('INVALID_ID');
  });
});
