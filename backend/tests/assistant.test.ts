import request from 'supertest';
import { app } from '../src/app';

describe('Assistant API (/api/v1/assistant)', () => {
  it('debe listar todas las respuestas frecuentes del chatbot', async () => {
    const response = await request(app).get('/api/v1/assistant/faq');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
    expect(response.body.data.length).toBeGreaterThanOrEqual(5);

    const keys = response.body.data.map((faq: any) => faq.key);
    expect(keys).toContain('horario');
    expect(keys).toContain('envios');
    expect(keys).toContain('pagos');
    expect(keys).toContain('garantia');
    expect(keys).toContain('devolucion');
  });

  it('debe responder a una clave específica de FAQ (ej. horario)', async () => {
    const response = await request(app).get('/api/v1/assistant/faq/horario');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.key).toBe('horario');
    expect(response.body.data.text).toContain('lunes a viernes');
  });

  it('debe responder 404 para una pregunta no registrada', async () => {
    const response = await request(app).get('/api/v1/assistant/faq/no_existe');

    expect(response.status).toBe(404);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('FAQ_NOT_FOUND');
  });
});
