import request from 'supertest';
import { app } from '../src/app';

describe('Orders API (/api/v1/orders)', () => {
  let authToken: string;
  let createdOrderId: string;
  let createdTrackingNumber: string;

  beforeAll(async () => {
    // Autenticarse con usuario de prueba para obtener token JWT
    const loginRes = await request(app).post('/api/v1/auth/login').send({
      email: 'admin@electroindustrial.com',
      password: 'Admin2026*',
    });
    authToken = loginRes.body.token;
  });

  it('debe rechazar la creación de orden sin token con status 401', async () => {
    const response = await request(app).post('/api/v1/orders').send({
      customerName: 'Santiago Ingeniero',
      customerEmail: 'santiago@uceva.edu.co',
      shippingAddress: 'Carrera 27 # 45-10, Tuluá, Valle',
      paymentMethod: 'nequi',
      items: [{ productId: 1, quantity: 1 }],
    });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('debe crear una orden autenticada validando inventario, flete de $12.000 COP y guía', async () => {
    const orderPayload = {
      customerName: 'Santiago Ingeniero',
      customerEmail: 'santiago@uceva.edu.co',
      shippingAddress: 'Carrera 27 # 45-10, Tuluá, Valle',
      paymentMethod: 'nequi',
      items: [
        { productId: 1, quantity: 2 }, // Breaker DIN 20A ($38.900 * 2 = $77.800)
        { productId: 2, quantity: 10 }, // Cable THHN #12 ($3.200 * 10 = $32.000)
      ],
    };

    const response = await request(app)
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${authToken}`)
      .send(orderPayload);

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data).toHaveProperty('trackingNumber');
    expect(response.body.data.trackingNumber).toMatch(/^ELC-\d{8}-\d{4}$/);
    expect(response.body.data.status).toBe('pending');
    expect(response.body.data.items.length).toBe(2);
    expect(response.body.data.subtotal).toBe(77800 + 32000); // 109800
    expect(response.body.data.shippingCost).toBe(12000);
    expect(response.body.data.total).toBe(109800 + 12000); // 121800

    createdOrderId = response.body.data.id;
    createdTrackingNumber = response.body.data.trackingNumber;
  });

  it('debe rechazar consulta de orden por ID sin token con status 401', async () => {
    const response = await request(app).get(`/api/v1/orders/${createdOrderId}`);

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('debe obtener la orden recién creada por su ID con token JWT', async () => {
    const response = await request(app)
      .get(`/api/v1/orders/${createdOrderId}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.id).toBe(createdOrderId);
    expect(response.body.data.customerEmail).toBe('santiago@uceva.edu.co');
  });

  it('debe obtener la orden por su número de guía de rastreo (público)', async () => {
    const response = await request(app).get(`/api/v1/orders/tracking/${createdTrackingNumber}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.trackingNumber).toBe(createdTrackingNumber);
  });

  it('debe rechazar orden con producto inexistente', async () => {
    const response = await request(app)
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        customerName: 'Cliente Prueba',
        customerEmail: 'prueba@test.com',
        shippingAddress: 'Calle 10 # 5-20',
        paymentMethod: 'efecty',
        items: [{ productId: 99999, quantity: 1 }],
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('PRODUCT_NOT_FOUND');
  });

  it('debe rechazar orden cuando la cantidad solicitada excede el stock', async () => {
    const response = await request(app)
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        customerName: 'Cliente Prueba',
        customerEmail: 'prueba@test.com',
        shippingAddress: 'Calle 10 # 5-20',
        paymentMethod: 'bancolombia',
        items: [{ productId: 1, quantity: 999999 }],
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('INSUFFICIENT_STOCK');
  });
});
