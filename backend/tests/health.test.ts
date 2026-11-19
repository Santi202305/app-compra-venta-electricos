import request from 'supertest';
import { app } from '../src/app';

describe('Health Check API (/api/v1/health)', () => {
  it('debe responder 200 OK con el estado operativo del servicio', async () => {
    const response = await request(app).get('/api/v1/health');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'UP');
    expect(response.body).toHaveProperty('service', 'electro-industrial-api');
    expect(response.body).toHaveProperty('timestamp');
    expect(response.body).toHaveProperty('uptimeSeconds');
  });

  it('debe responder en la ruta raíz / con la información general', async () => {
    const response = await request(app).get('/');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name', 'Electro Industrial API');
    expect(response.body).toHaveProperty('version');
  });
});
