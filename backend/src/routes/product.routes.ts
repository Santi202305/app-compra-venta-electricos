import { Router } from 'express';
import { productController } from '../controllers/product.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';

const router = Router();

// Endpoints públicos de catálogo
router.get('/', productController.getProducts);
router.get('/:id', productController.getProductById);

// Endpoints CRUD protegidos mediante JWT (requieren Bearer token)
router.post('/', authenticateJWT, productController.createProduct);
router.put('/:id', authenticateJWT, productController.updateProduct);
router.delete('/:id', authenticateJWT, productController.deleteProduct);

export default router;
