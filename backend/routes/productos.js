import express from "express";
import { obtenerTodos, obtenerPorId, crear, editar, eliminar } from "../controllers/productos.js";

const router = express.Router();

router.get("/obtener", obtenerTodos);
router.get("/obtenerId/:id", obtenerPorId);
router.post("/crearProducto", crear);
router.put("/actualizar/:id", editar);
<<<<<<< HEAD
router.delete("/eliminar/:id", eliminar);
=======
router.delete("/eliminar:id", eliminar);
>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17

export default router;