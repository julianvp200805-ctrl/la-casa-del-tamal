import express from 'express';
import { getUsuarios, getobtenerUsuarioPorId, putActualizarUsuario, deleteEliminarUsuario } from '../controllers/user.js';
import { generarCodigoRegistro, listarCodigosRegistro, revocarCodigoRegistro } from '../controllers/codigosRegistro.js';
import { verificarToken, verificarAdmin } from '../middlewares/userMiddleware.js';

const router = express.Router();

// Todas las rutas requieren sesión; las de gestión se limitan al admin.
router.use(verificarToken);

// Un usuario puede borrar SU cuenta desde la app (menú → Eliminar cuenta).
// El administrador, además, puede borrar la cuenta de cualquier trabajador.
const verificarPropietarioOAdmin = (req, res, next) => {
    const idSolicitado = String(req.params.id ?? '');
    const idSesion = String(req.usuario?.id ?? '');
    if (req.usuario?.rol !== 'admin' && idSolicitado !== idSesion) {
        return res.status(403).json({ error: 'No tienes permisos para eliminar esta cuenta' });
    }
    next();
};

// Códigos de registro de empleados (solo admin)
router.post('/codigos-registro', verificarAdmin, generarCodigoRegistro);
router.get('/codigos-registro', verificarAdmin, listarCodigosRegistro);
router.delete('/codigos-registro/:id', verificarAdmin, revocarCodigoRegistro);

// Gestión de usuarios
router.get('/obtener_usuarios', verificarAdmin, getUsuarios);
router.get('/obtener_usuario/:id', verificarAdmin, getobtenerUsuarioPorId);
router.put('/actualizar_usuario/:id', verificarAdmin, putActualizarUsuario);
router.delete('/eliminar_usuario/:id', verificarPropietarioOAdmin, deleteEliminarUsuario);

export default router;
