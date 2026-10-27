import express from "express";
import { crearPedidoConDetalles, obtenerPedidoUsuario, misPedidos, reporteVentas, reporteRango, pedidosEnProceso, cambiarEstadoPedido, eliminarPedidoUsuario } from "../controllers/pedido.js";
import { verificarToken, verificarAdmin } from "../middlewares/userMiddleware.js";

const router = express.Router();

// POST - Crear pedido
router.post('/pedidos', crearPedidoConDetalles);
// GET - Reporte de ventas del admin (diaria/semanal/mensual) — debe ir
// ANTES que /pedidos/:id para que no la confunda con un id.
router.get('/reporte', verificarToken, verificarAdmin, reporteVentas);
// GET - Reporte para un rango de fechas explícito (un día, una semana...)
router.get('/reporte-rango', verificarToken, verificarAdmin, reporteRango);
// GET - Pedidos abiertos (admin)
router.get('/en-proceso', verificarToken, verificarAdmin, pedidosEnProceso);
// PATCH - Cambiar el estado de un pedido (admin)
router.patch('/:id/estado', verificarToken, verificarAdmin, cambiarEstadoPedido);
// GET - Mis pedidos (por usuario) — debe ir ANTES que /:id
router.get('/mis-pedidos', misPedidos);
// GET - Obtener pedido por ID
router.get('/pedidos/:id', obtenerPedidoUsuario);
// eliminar pedido por ID
router.delete("/:id", eliminarPedidoUsuario);

export default router;