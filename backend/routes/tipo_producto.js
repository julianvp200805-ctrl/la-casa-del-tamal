import express from 'express';
import { crearTipo2, listarTipos, obtenerTipo, editarTipo, deleteTipo} from "../controllers/tipos_producto.js";
import { verificarToken, verificarAdmin } from "../middlewares/userMiddleware.js";

const router = express.Router();

// Los tipos de producto también son solo para admin.
router.use(verificarToken, verificarAdmin);

//ruta para crear un tipo de producto
router.post('/crear_tipo', crearTipo2);
//ruta para obtener todos los tipos
router.get('/obtener_tipos', listarTipos);
//ruta para obtener un tipo por id
router.get('/obtener_tipo/:id', obtenerTipo);
//ruta para actualizar un tipo
router.put('/actualizar_tipo/:id', editarTipo);
//ruta para eliminar un tipo
router.delete('/eliminar_tipo/:id', deleteTipo);

export default router;