import express from "express";
import { obtenerTodos, obtenerPorId, crear, editar, eliminar } from "../controllers/productos.js";

const router = express.Router();

router.get("/obtener", obtenerTodos);
router.get("/obtenerId/:id", obtenerPorId);
router.post("/crearProducto", crear);
router.put("/actualizar/:id", editar);
router.delete("/eliminar/:id", eliminar);

export default router;