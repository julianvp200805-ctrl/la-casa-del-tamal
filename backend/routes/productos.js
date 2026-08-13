import express from "express";
import { listarTipos, obtenerTipoPorId, crearTipoProducto, actualizarTipoProducto, eliminarTipoProducto } from "../controllers/tipos_producto.js";

const router = express.Router();

router.get("/", listarTipos);
router.get("/:id", obtenerTipoPorId);
router.post("/", crearTipoProducto);
router.put("/:id", actualizarTipoProducto);
router.delete("/:id", eliminarTipoProducto);