import express from 'express';
import { getUsuarios, getobtenerUsuarioPorId, putActualizarUsuario, deleteEliminarUsuario } from '../controllers/user.js';
import { generarCodigoRegistro, listarCodigosRegistro, revocarCodigoRegistro } from '../controllers/codigosRegistro.js';
import { verificarToken, verificarAdmin } from '../middlewares/userMiddleware.js';

const router = express.Router();

// Todo lo de este archivo es SOLO del admin (antes estaba abierto a cualquiera).
router.use(verificarToken, verificarAdmin);

// Códigos de registro de empleados
router.post('/codigos-registro', generarCodigoRegistro);
router.get('/codigos-registro', listarCodigosRegistro);
router.delete('/codigos-registro/:id', revocarCodigoRegistro);

// Gestión de usuarios
router.get('/obtener_usuarios', getUsuarios);
router.get('/obtener_usuario/:id', getobtenerUsuarioPorId);
router.put('/actualizar_usuario/:id', putActualizarUsuario);
router.delete('/eliminar_usuario/:id', deleteEliminarUsuario);

export default router;