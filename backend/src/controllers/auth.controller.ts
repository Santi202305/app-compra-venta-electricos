import { Request, Response, NextFunction } from 'express';
import { RegisterSchema, LoginSchema } from '../models/user.model';
import { AuthService, defaultAuthService } from '../services/auth.service';
import { AuthenticatedRequest } from '../middlewares/auth.middleware';

export class AuthController {
  private service: AuthService;

  constructor(service: AuthService = defaultAuthService) {
    this.service = service;
  }

  public register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedData = RegisterSchema.parse(req.body);
      const result = await this.service.register(validatedData);
      res.status(201).json({
        success: true,
        data: result.user,
        token: result.token,
      });
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedData = LoginSchema.parse(req.body);
      const result = await this.service.login(validatedData);
      res.status(200).json({
        success: true,
        data: result.user,
        token: result.token,
      });
    } catch (error) {
      next(error);
    }
  };

  public getMe = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'No autenticado',
          },
        });
        return;
      }
      res.status(200).json({
        success: true,
        data: {
          id: req.user.sub,
          email: req.user.email,
          name: req.user.name,
          role: req.user.role,
        },
      });
    } catch (error) {
      next(error);
    }
  };
}

export const authController = new AuthController();
