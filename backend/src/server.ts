import { app } from './app';
import { config } from './config';

const server = app.listen(config.port, () => {
  console.log(`⚡ [Backend] Servidor corriendo en modo ${config.env}`);
  console.log(`🌐 [Backend] URL: http://localhost:${config.port}${config.apiPrefix}`);
  console.log(`🩺 [Backend] Health: http://localhost:${config.port}${config.apiPrefix}/health`);
});

process.on('SIGTERM', () => {
  console.log('Cerrando servidor HTTP con gracia (SIGTERM)...');
  server.close(() => {
    console.log('Servidor finalizado.');
  });
});
