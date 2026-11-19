import request from 'supertest';
import { app } from '../src/app';

describe('Auth API (/api/v1/auth)', () => {
  const testUser = {
    email: 'electricista.test@cidet.org.co',
    name: 'Carlos Electricista Pro',
    password: 'passwordSegura123!',
    role: 'electrician' as const,
  };

  it('debe registrar un nuevo usuario y devolver token JWT sin hash de contraseña', async () => {
    const response = await request(app).post('/api/v1/auth/register').send(testUser);

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data.email).toBe(testUser.email.toLowerCase());
    expect(response.body.data.name).toBe(testUser.name);
    expect(response.body.data.role).toBe('electrician');
    expect(response.body.data).not.toHaveProperty('passwordHash');
    expect(response.body).toHaveProperty('token');
    expect(typeof response.body.token).toBe('string');
  });

  it('debe rechazar registro con correo duplicado con status 409', async () => {
    const response = await request(app).post('/api/v1/auth/register').send(testUser);

    expect(response.status).toBe(409);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('EMAIL_ALREADY_EXISTS');
  });

  it('debe autenticar con credenciales correctas en login', async () => {
    const response = await request(app).post('/api/v1/auth/login').send({
      email: testUser.email,
      password: testUser.password,
    });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body).toHaveProperty('token');
    expect(response.body.data.email).toBe(testUser.email.toLowerCase());
  });

  it('debe rechazar login con contraseña errónea con status 401', async () => {
    const response = await request(app).post('/api/v1/auth/login').send({
      email: testUser.email,
      password: 'passwordIncorrecta!',
    });

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('INVALID_CREDENTIALS');
  });
});
