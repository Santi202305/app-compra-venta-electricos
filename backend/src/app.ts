import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { config } from './config';
import healthRoutes from './routes/health.routes';
import productRoutes from './routes/product.routes';
import { errorHandler } from './middlewares/error.middleware';

export function createApp(): Application {
  const app = express();

  // Middlewares de seguridad y observabilidad
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigin }));
  app.use(express.json());

  if (config.env !== 'test') {
    app.use(morgan('combined'));
  }

  // Rutas base versionadas /api/v1
  const apiRouter = express.Router();
  apiRouter.use('/health', healthRoutes);
  apiRouter.use('/products', productRoutes);

  app.use(config.apiPrefix, apiRouter);

  // Redirección o respuesta raíz
  app.get('/', (_req, res) => {
    res.json({
      name: 'Electro Industrial API',
      version: '1.0.0',
      docs: '/docs/openapi.yaml',
      health: `${config.apiPrefix}/health`,
    });
  });

  // Middleware global de captura y formato de errores
  app.use(errorHandler);

  return app;
}

export const app = createApp();
