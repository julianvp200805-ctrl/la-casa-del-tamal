import express from 'express';
import { registro, login } from '../controllers/auth.js';
import { forgotPassword, verifyCode } from '../controllers/recuperar.js';
import { verificarCodigoRegistro } from '../controllers/codigosRegistro.js';
import { limitarIntentos } from '../middlewares/limitarintentos.js';

const router = express.Router();

// Límites de intentos: frenan la fuerza bruta (códigos de 6 números, contraseñas)
const porIp = limitarIntentos({ max: 15 });
const porIpYCorreo = (max) =>
    limitarIntentos({ max, clave: (req) => `${req.ip}:${String(req.body?.email ?? '').toLowerCase()}` });

// Registro de empleados (necesita el código que genera el admin)
router.post('/verificar-codigo-registro', porIp, verificarCodigoRegistro);
router.post('/registro', porIp, registro);

router.post('/login', porIpYCorreo(8), login);

// Recuperar contraseña
router.post('/forgot-password', porIpYCorreo(5), forgotPassword);
router.post('/verify-code', porIpYCorreo(10), verifyCode);

export default router;