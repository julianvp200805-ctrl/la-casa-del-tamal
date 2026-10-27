import express from "express";
import { obtenerTodos, obtenerPorId, crear, editar, eliminar } from "../controllers/productos.js";
import { verificarToken, verificarAdmin } from "../middlewares/userMiddleware.js";

const router = express.Router();

// El inventario es información interna: solo admin con token.
router.use(verificarToken, verificarAdmin);

router.get("/obtener", obtenerTodos);
router.get("/obtenerId/:id", obtenerPorId);
router.post("/crearProducto", crear);
router.put("/actualizar/:id", editar);
router.delete("/eliminar/:id", eliminar);

export default router;