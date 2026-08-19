import express from 'express';
import { crearTipo2, listarTipos, obtenerTipo, editarTipo, deleteTipo} from "../controllers/tipos_producto.js";
const router = express.Router();

//ruta para crear un producto
router.post('/crear_tipo', crearTipo2);

//ruta para obtener todos los productos
router.get('/obtener_tipos', listarTipos);

//ruta para obtener un producto por id
router.get('/obtener_tipo/:id', obtenerTipo);

//ruta para actualizar un producto
router.put('/actualizar_tipo/:id', editarTipo);

//ruta para eliminar un producto
router.delete('/eliminar_tipo/:id', deleteTipo);

export default router;