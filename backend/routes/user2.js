import express from 'express';
import {getUsuarios, getobtenerUsuarioPorId, putActualizarUsuario, deleteEliminarUsuario} from '../controllers/user2.js'

const router = express.Router();
//ruta para obtener todos los usuarios
router.get('/obtener_usuarios', getUsuarios);
//ruta para obtener un usuario por id
router.get('/obtener_usuario/:id', getobtenerUsuarioPorId);
//ruta para actualizar un usuario
router.put('/actualizar_usuario/:id', putActualizarUsuario);
//ruta para eliminar un usuario
router.delete('/eliminar_usuario/:id', deleteEliminarUsuario);

export default router;