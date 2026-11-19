import request from 'supertest';
import { app } from '../src/app';

describe('Products API (/api/v1/products)', () => {
  let authToken: string;
  let newProductId: number;

  beforeAll(async () => {
    const loginRes = await request(app).post('/api/v1/auth/login').send({
      email: 'admin@electroindustrial.com',
      password: 'Admin2026*',
    });
    authToken = loginRes.body.token;
  });

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

  // --- PRUEBAS CRUD PROTEGIDAS CON TOKEN JWT ---

  it('debe rechazar la creación de producto sin token con status 401', async () => {
    const response = await request(app).post('/api/v1/products').send({
      name: 'Transformador Seco 15kVA',
      sku: 'TRF-15K-220',
      category: 'herramientas',
      price: 1850000,
      stock: 3,
    });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('debe crear un producto correctamente al enviar token JWT válido', async () => {
    const response = await request(app)
      .post('/api/v1/products')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        name: 'Transformador Seco 15kVA',
        sku: 'TRF-15K-220',
        category: 'herramientas',
        description: 'Transformador de distribución tipo seco para uso interior',
        price: 1850000,
        stock: 3,
        unit: 'Unidad',
        retieCompliant: true,
        technicalSpecs: {
          voltage: '220V',
        },
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data.sku).toBe('TRF-15K-220');
    newProductId = response.body.data.id;
  });

  it('debe rechazar la actualización de producto sin token con status 401', async () => {
    const response = await request(app)
      .put(`/api/v1/products/${newProductId}`)
      .send({ price: 1950000 });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('debe actualizar producto correctamente al enviar token JWT válido', async () => {
    const response = await request(app)
      .put(`/api/v1/products/${newProductId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        price: 1920000,
        stock: 5,
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.price).toBe(1920000);
    expect(response.body.data.stock).toBe(5);
  });

  it('debe rechazar la eliminación de producto sin token con status 401', async () => {
    const response = await request(app).delete(`/api/v1/products/${newProductId}`);

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('debe eliminar producto correctamente al enviar token JWT válido', async () => {
    const response = await request(app)
      .delete(`/api/v1/products/${newProductId}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);

    // Verificar que ya no existe
    const getRes = await request(app).get(`/api/v1/products/${newProductId}`);
    expect(getRes.status).toBe(404);
  });
});
