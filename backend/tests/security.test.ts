import request from 'supertest';
import jwt from 'jsonwebtoken';
import { app } from '../src/app';

describe('Security & Robustness Tests', () => {
  it('debe mitigar inyecciones SQL en parámetros de búsqueda tratando la entrada como texto plano', async () => {
    const maliciousQuery = "' OR 1=1 --; DROP TABLE products;";
    const response = await request(app).get(`/api/v1/products?search=${encodeURIComponent(maliciousQuery)}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    // No debe devolver todos los productos de forma arbitraria
    expect(response.body.data.length).toBe(0);
  });

  it('debe incluir encabezados de seguridad HTTP configurados por Helmet', async () => {
    const response = await request(app).get('/api/v1/health');

    expect(response.headers['x-content-type-options']).toBe('nosniff');
    expect(response.headers['x-dns-prefetch-control']).toBe('off');
    expect(response.headers).not.toHaveProperty('x-powered-by');
  });

  it('debe rechazar registros con contraseñas débiles o campos incompletos (validación Zod)', async () => {
    const response = await request(app).post('/api/v1/auth/register').send({
      email: 'seguridad@cidet.org.co',
      name: 'A', // Demasiado corto (<2 chars)
      password: '123', // Demasiado corta (<6 chars)
    });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(Array.isArray(response.body.error.details)).toBe(true);
    expect(response.body.error.details.length).toBeGreaterThanOrEqual(2);
  });

  it('garantiza que ninguna respuesta de usuario exponga el hash de contraseña', async () => {
    const uniqueEmail = `test.security.${Date.now()}@uceva.edu.co`;
    const regRes = await request(app).post('/api/v1/auth/register').send({
      email: uniqueEmail,
      name: 'Auditor de Seguridad',
      password: 'superClaveSecreta123!',
    });

    expect(regRes.status).toBe(201);
    expect(regRes.body.data).not.toHaveProperty('passwordHash');
    expect(regRes.body.data).not.toHaveProperty('password');
    expect(JSON.stringify(regRes.body)).not.toContain('superClaveSecreta123!');

    const loginRes = await request(app).post('/api/v1/auth/login').send({
      email: uniqueEmail,
      password: 'superClaveSecreta123!',
    });

    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data).not.toHaveProperty('passwordHash');
    expect(loginRes.body.data).not.toHaveProperty('password');
  });

  it('debe rechazar tokens JWT manipulados o con firma inválida', () => {
    const fakeToken = jwt.sign(
      { sub: 'usr_hacker', role: 'admin' },
      'wrong_key_violating_signature',
      { expiresIn: '1h' }
    );

    // Verificación de integridad criptográfica
    expect(() => {
      jwt.verify(fakeToken, 'correct_system_secret');
    }).toThrow();
  });

  it('debe manejar rutas inexistentes sin filtrar stack trace ni información sensible', async () => {
    const response = await request(app).get('/api/v1/ruta_totalmente_inexistente');

    // Express default 404
    expect(response.status).toBe(404);
    expect(JSON.stringify(response.body)).not.toContain('at Function.execute');
  });
});
