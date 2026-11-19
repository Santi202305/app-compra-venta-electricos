import dotenv from 'dotenv';
import path from 'path';

// Cargar variables de entorno desde .env local o raíz si existe
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  corsOrigin: process.env.CORS_ORIGIN || '*',
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    name: process.env.DB_NAME || 'electricos_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres_password_local',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev_secret_key_change_in_production_32chars!',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h',
  },
};
