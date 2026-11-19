import { Router } from 'express';
import { orderController } from '../controllers/order.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';

const router = Router();

// Creación y consulta de pedidos protegidos por JWT
router.post('/', authenticateJWT, orderController.createOrder);
router.get('/:id', authenticateJWT, orderController.getOrderById);

// Rastreo público por número de guía
router.get('/tracking/:trackingNumber', orderController.getOrderByTracking);

export default router;
