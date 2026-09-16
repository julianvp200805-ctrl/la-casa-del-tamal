import express from "express";
import { listarMenu, obtenerMenu, obtenerPorCat, crear, editar, eliminar } from "../controllers/menu.js";
import {verificarToken, verificarAdmin} from "../middlewares/userMiddleware.js"

//AGREGAR ESTA LÍNEA (Ajusta la ruta de acceso a tu archivo de cloudinary):
import { upload } from "../config/cloudinary.js";

const router = express.Router();
// GET - Obtener todos
router.get('/menu', listarMenu);
// GET - Obtener por ID
router.get('/menu/:id', obtenerMenu);
// GET - Obtener por categoría
router.get('/menu/categoria/:categoria', obtenerPorCat);
// POST - Crear plato
router.post('/crear_menu', verificarToken, verificarAdmin, upload.single('imagen'), crear);
// PUT - Actualizar helado
router.put('/menu/:id', verificarToken, verificarAdmin, upload.single('imagen'), editar);
// DELETE - Eliminar helado
router.delete('/menu/:id', verificarToken, verificarAdmin, eliminar);
export default router;