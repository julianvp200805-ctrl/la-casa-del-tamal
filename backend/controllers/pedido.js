import {crearPedido,obtenerPedidoConDetalles,crearDetallePedido,obtenerPedidosPorUsuario,obtenerPedidosPorRango,obtenerItemsPorRango,
  obtenerPedidosEnProceso,
  actualizarEstadoPedido,
  eliminarPedido
} from "../models/pedido.js";
import { obtenerUsuarioPorId as obtenerUsuario } from "../models/user.js";

export const crearPedidoConDetalles = async (req, res) => {
  try {
    const { usuario_id, direccion_entrega, telefono, notas, mesa, detalles } = req.body;
    if (!usuario_id || !detalles || detalles.length === 0) {
      return res.status(400).json({ error: 'Datos incompletos' });
    }
    let total = 0;
    detalles.forEach(d => { total += d.subtotal; });

    const { data: pedido, error: errorPedido } = await crearPedido({ usuario_id, direccion_entrega, telefono, notas, mesa, total });
    if (errorPedido || !pedido) {
      console.error('Error Supabase (crearPedido):', errorPedido);
      return res.status(500).json({ error: 'Error al crear pedido', detalle: errorPedido?.message });
    }

    const detallesConPedido = detalles.map(d => ({ ...d, pedido_id: pedido[0].id }));
    for (let detalle of detallesConPedido) {
      const { error: errorDetalle } = await crearDetallePedido(detalle);
      if (errorDetalle) {
        console.error('Error al crear detalle:', errorDetalle);
        return res.status(500).json({ error: 'Error al crear detalle de pedido', detalle: errorDetalle.message });
      }
    }
    return res.status(201).json({ message: 'Pedido creado', pedido: pedido[0] });
  } catch (error) {
    console.error('Error en crearPedidoConDetalles:', error);
    return res.status(500).json({ error: error.message });
  }
};

export const obtenerPedidoUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await obtenerPedidoConDetalles(id);
    if (error || !data) return res.status(404).json({ error: 'Pedido no encontrado' });
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

export const misPedidos = async (req, res) => {
  try {
    const { usuario_id } = req.query;
    if (!usuario_id) return res.status(400).json({ error: 'usuario_id requerido' });
    const { data, error } = await obtenerPedidosPorUsuario(usuario_id);
    if (error) return res.status(500).json({ error: 'Error al obtener pedidos' });
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// Agrupa las líneas de detalle_pedido por nombre de producto, sumando
// cantidad y subtotal. Usado tanto por reporteVentas como por reporteRango.
function agruparItems(itemsRaw) {
  const mapa = {};
  (itemsRaw || []).forEach(item => {
    const nombre = item.menu?.nombre || 'Producto';
    if (!mapa[nombre]) mapa[nombre] = { nombre, cantidad: 0, subtotal: 0 };
    mapa[nombre].cantidad += Number(item.cantidad || 0);
    mapa[nombre].subtotal += Number(item.subtotal || 0);
  });
  return Object.values(mapa);
}

// Reporte de ventas para el admin (rangos fijos: diaria/semanal/mensual).
export const reporteVentas = async (req, res) => {
  try {
    const { tipo } = req.query;
    if (!['diaria', 'semanal', 'mensual'].includes(tipo)) {
      return res.status(400).json({ error: "El parametro 'tipo' debe ser: diaria, semanal o mensual" });
    }

    const ahora = new Date();
    let fechaInicio;
    if (tipo === 'diaria') {
      fechaInicio = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate());
    } else if (tipo === 'semanal') {
      fechaInicio = new Date(ahora);
      fechaInicio.setDate(ahora.getDate() - 7);
    } else {
      fechaInicio = new Date(ahora);
      fechaInicio.setDate(ahora.getDate() - 30);
    }

    const desdeISO = fechaInicio.toISOString();
    const hastaISO = ahora.toISOString();

    const { data, error } = await obtenerPedidosPorRango(desdeISO, hastaISO);
    if (error) return res.status(500).json({ error: 'Error al obtener el reporte de ventas' });

    // CORREGIDO: el filtro estaba al revés (excluía 'entregado', que son
    // justo las ventas ya completadas, y contaba todo lo demás incluyendo
    // pedidos cancelados). Ahora se excluye solo 'cancelado'.
    const pedidosValidos = data.filter(p => p.estado !== 'cancelado');
    const totalVentas = pedidosValidos.reduce((acc, p) => acc + Number(p.total || 0), 0);

    const { data: itemsRaw, error: errorItems } = await obtenerItemsPorRango(desdeISO, hastaISO);
    if (errorItems) return res.status(500).json({ error: 'Error al obtener el detalle de ventas' });

    return res.status(200).json({
      tipo,
      desde: desdeISO,
      hasta: hastaISO,
      cantidadPedidos: pedidosValidos.length,
      totalVentas,
      itemsAgrupados: agruparItems(itemsRaw)
    });
  } catch (error) {
    console.error('Error en reporteVentas:', error);
    return res.status(500).json({ error: error.message });
  }
};

// NUEVO: reporte para un rango de fechas explícito (un día de la semana,
// una semana del mes, etc). GET /pedido/reporte-rango?desde=&hasta=
export const reporteRango = async (req, res) => {
  try {
    const { desde, hasta } = req.query;
    if (!desde || !hasta) return res.status(400).json({ error: "'desde' y 'hasta' son requeridos (ISO 8601)" });

    const { data, error } = await obtenerPedidosPorRango(desde, hasta);
    if (error) return res.status(500).json({ error: 'Error al obtener el reporte' });

    const pedidosValidos = data.filter(p => p.estado !== 'cancelado');
    const totalVentas = pedidosValidos.reduce((acc, p) => acc + Number(p.total || 0), 0);

    const { data: itemsRaw, error: errorItems } = await obtenerItemsPorRango(desde, hasta);
    if (errorItems) return res.status(500).json({ error: 'Error al obtener el detalle de ventas' });

    return res.status(200).json({
      desde,
      hasta,
      cantidadPedidos: pedidosValidos.length,
      totalVentas,
      itemsAgrupados: agruparItems(itemsRaw)
    });
  } catch (error) {
    console.error('Error en reporteRango:', error);
    return res.status(500).json({ error: error.message });
  }
};

export const eliminarPedidoUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) return res.status(400).json({ error: "ID del pedido requerido" });
    const { data, error } = await eliminarPedido(id);
    if (error) {
      console.error("Error al eliminar pedido:", error);
      return res.status(500).json({ error: "Error al eliminar el pedido", detalle: error.message });
    }
    if (!data || data.length === 0) return res.status(404).json({ error: "Pedido no encontrado" });
    return res.status(200).json({ message: "Pedido eliminado correctamente", pedido: data[0] });
  } catch (error) {
    console.error("Error en eliminarPedidoUsuario:", error);
    return res.status(500).json({ error: error.message });
  }
};

// GET /pedido/en-proceso (admin): pedidos abiertos con sus productos.
export const pedidosEnProceso = async (req, res) => {
  try {
    const { data, error } = await obtenerPedidosEnProceso();
    if (error) return res.status(500).json({ error: 'Error al obtener los pedidos en proceso', detalle: error.message });
    return res.status(200).json({ pedidos: data || [] });
  } catch (error) {
    console.error('Error en pedidosEnProceso:', error);
    return res.status(500).json({ error: error.message });
  }
};

// PATCH /pedido/:id/estado (admin)  body: { estado }
export const cambiarEstadoPedido = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;
    if (!estado || typeof estado !== 'string' || !estado.trim()) {
      return res.status(400).json({ error: "'estado' es requerido" });
    }
    const { data, error } = await actualizarEstadoPedido(id, estado.trim());
    if (error) return res.status(500).json({ error: 'No se pudo actualizar el estado', detalle: error.message });
    if (!data || data.length === 0) return res.status(404).json({ error: 'Pedido no encontrado' });
    return res.status(200).json({ message: 'Estado actualizado', pedido: data[0] });
  } catch (error) {
    console.error('Error en cambiarEstadoPedido:', error);
    return res.status(500).json({ error: error.message });
  }
};