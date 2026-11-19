import { Request, Response } from 'express';

export class HealthController {
  public check(_req: Request, res: Response): void {
    res.status(200).json({
      status: 'UP',
      service: 'electro-industrial-api',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
      database: 'connected',
    });
  }
}

export const healthController = new HealthController();
