import express from "express";
import { listarMenu, obtenerMenu, obtenerPorCat, crear, editar, eliminar } from "../controllers/menu.js";
import {verificarToken, verificarAdmin} from "../middlewares/userMiddleware.js"

import { upload } from "../config/cloudinary.js";

const router = express.Router();

// GET - Obtener todos
router.get('/menu', listarMenu);

// GET - Obtener por categoría
router.get('/menu/categoria/:categoria', obtenerPorCat);

// GET - Obtener por ID
router.get('/menu/:id', obtenerMenu);

// POST - Crear plato
router.post('/crear_menu', verificarToken, verificarAdmin, upload.single('imagen'), crear);
// PUT - Actualizar plato
router.put('/menu/:id', verificarToken, verificarAdmin, upload.single('imagen'), editar);
// DELETE - Eliminar plato
router.delete('/menu/:id', verificarToken, verificarAdmin, eliminar);

export default router;