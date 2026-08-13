import express from 'express';
import { registro, login } from '../controllers/user.js';
import { forgotPassword } from '../controllers/recuperar.js';
import { verifyCode } from '../controllers/recuperar.js';
const router = express.Router();
//Rutas de autenticacion
router.post('/registro', registro);
router.post('/login', login);
//ruta de olvido de contraseña
router.post ('/forgot-password', forgotPassword)
router.post('/verify-code', verifyCode);
export default router;
