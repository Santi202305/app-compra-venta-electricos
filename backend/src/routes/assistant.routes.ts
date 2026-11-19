import { Router } from 'express';
import { assistantController } from '../controllers/assistant.controller';

const router = Router();

router.get('/faq', assistantController.getFaqs);
router.get('/faq/:key', assistantController.getAnswer);

export default router;
