import express from "express";
import {
  crearPedidoMesero,
  pedidosMeseroAbiertos,
  pedidosCocinaAbiertos,
  pedidosEnProceso,
  cambiarEstadoPedido,
  entregarPedido,
  reporteVentas,
  reporteRango
} from "../controllers/pedido.js";
import { verificarToken, verificarAdmin, verificarRol } from "../middlewares/userMiddleware.js";

const router = express.Router();

// Todas las rutas de pedidos requieren sesión.
router.use(verificarToken);

// --- MESERO ---
router.post('/mesero', verificarRol('mesero', 'admin'), crearPedidoMesero);
router.get('/mesero/abiertos', verificarRol('mesero', 'admin'), pedidosMeseroAbiertos);
router.patch('/:id/entregar', verificarRol('mesero', 'admin'), entregarPedido);

// --- COCINA ---
router.get('/cocina/abiertos', verificarRol('cocina', 'admin'), pedidosCocinaAbiertos);

// --- ADMIN (reportes y bandeja general) ---
// Deben ir ANTES de /:id para no confundirse con un id.
router.get('/reporte', verificarAdmin, reporteVentas);
router.get('/reporte-rango', verificarAdmin, reporteRango);
router.get('/en-proceso', verificarAdmin, pedidosEnProceso);

// --- COCINA Y ADMIN ---
// El controlador aplica las transiciones permitidas por rol.
router.patch('/:id/estado', verificarRol('cocina', 'admin'), cambiarEstadoPedido);

export default router;
