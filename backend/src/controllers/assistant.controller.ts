import { Request, Response, NextFunction } from 'express';
import { AssistantService, defaultAssistantService } from '../services/assistant.service';

export class AssistantController {
  private service: AssistantService;

  constructor(service: AssistantService = defaultAssistantService) {
    this.service = service;
  }

  public getFaqs = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const faqs = await this.service.getFaqs();
      res.status(200).json({
        success: true,
        data: faqs,
      });
    } catch (error) {
      next(error);
    }
  };

  public getAnswer = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const answer = await this.service.getAnswer(req.params.key);
      res.status(200).json({
        success: true,
        data: answer,
      });
    } catch (error) {
      next(error);
    }
  };
}

export const assistantController = new AssistantController();
