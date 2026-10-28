import express from 'express';
import { registro, login } from '../controllers/auth.js';
import { forgotPassword, verifyCode } from '../controllers/recuperar.js';
// LÍNEA CORREGIDA: Se cambió 'generarCodigoRegistroAdmin' por 'generarCodigoRegistro'
import { verificarCodigoRegistro, generarCodigoRegistro } from '../controllers/codigosRegistro.js';
import { limitarIntentos } from '../middlewares/limitarIntentos.js';
import { verificarToken } from '../middlewares/userMiddleware.js';

const router = express.Router();

const porIp = limitarIntentos({ max: 15 });
const porIpYCorreo = (max) =>
    limitarIntentos({ max, clave: (req) => `${req.ip}:${String(req.body?.email ?? '').toLowerCase()}` });

// --- CÓDIGOS DE ACCESO (ADMIN) ---
// LÍNEA CORREGIDA: Se usa el nombre exacto de la función exportada del controlador
router.post('/generar-codigo', verificarToken, porIp, generarCodigoRegistro);
router.post('/verificar-codigo-registro', porIp, verificarCodigoRegistro);

// --- AUTENTICACIÓN Y REGISTRO ---
router.post('/registro', porIp, registro);
router.post('/login', porIpYCorreo(8), login);

// --- RECUPERACIÓN DE CONTRASEÑA (BREVO) ---
router.post('/forgot-password', porIpYCorreo(5), forgotPassword);
router.post('/verify-code', porIpYCorreo(10), verifyCode);

export default router;
