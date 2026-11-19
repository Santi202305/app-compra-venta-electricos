import { BotAnswer, FAQ_DATA } from '../models/assistant.model';
import { AppError } from './product.service';

export class AssistantService {
  async getFaqs(): Promise<BotAnswer[]> {
    return Object.values(FAQ_DATA);
  }

  async getAnswer(key: string): Promise<BotAnswer> {
    const answer = FAQ_DATA[key.toLowerCase().trim()];
    if (!answer) {
      throw new AppError(
        `No se encontró respuesta para la clave '${key}'. Opciones válidas: ${Object.keys(FAQ_DATA).join(', ')}`,
        404,
        'FAQ_NOT_FOUND'
      );
    }
    return answer;
  }
}

export const defaultAssistantService = new AssistantService();
