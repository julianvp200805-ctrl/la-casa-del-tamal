import {
  crearPedido,
  obtenerPedidoConDetalles,
  crearDetallePedido,
  obtenerPedidosPorRango,
  obtenerItemsPorRango,
  obtenerPedidosEnProceso,
  obtenerPedidosAbiertosPorUsuario,
  actualizarEstadoPedido
} from "../models/pedido.js";
import { obtenerPorId as obtenerPlato } from "../models/menu.js";

const ESTADOS = ['pendiente', 'en_proceso', 'listo', 'entregado', 'cancelado'];

// POST /pedido/mesero  body: { mesa, items: [{ menu_id, cantidad }] }
// El mesero arma el pedido; los precios y el total los calcula el backend
// con el menú real, y el pedido queda 'pendiente' para que lo vea la cocina.
export const crearPedidoMesero = async (req, res) => {
  try {
    const { mesa, items } = req.body ?? {};
    if (!mesa || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'Falta la mesa o los platos del pedido' });
    }

    const detalles = [];
    let total = 0;
    for (const it of items) {
      const cantidad = Number(it.cantidad);
      if (!it.menu_id || !Number.isInteger(cantidad) || cantidad <= 0) {
        return res.status(400).json({ error: 'Plato o cantidad inválida' });
      }
      const { data: plato, error } = await obtenerPlato(it.menu_id);
      if (error || !plato) return res.status(400).json({ error: 'Un plato del pedido ya no existe en el menú' });
      const precioUnitario = Number(plato.precio);
      const subtotal = precioUnitario * cantidad;
      total += subtotal;
      detalles.push({ menu_id: plato.id, cantidad, precio_unitario: precioUnitario, subtotal });
    }

    // La tabla pedidos no tiene columna "mesa": se guarda como
    // "Mesa <n>" en direccion_entrega, formato que el frontend ya sabe leer.
    const { data: pedido, error: errorPedido } = await crearPedido({
      usuario_id: req.usuario.id,
      direccion_entrega: `Mesa ${String(mesa).replace(/^mesa\s*/i, '')}`,
      total,
      estado: 'pendiente'
    });
    if (errorPedido || !pedido) {
      console.error('Error Supabase (crearPedido):', errorPedido);
      return res.status(500).json({ error: 'Error al crear el pedido', detalle: errorPedido?.message });
    }

    for (const detalle of detalles) {
      const { error: errorDetalle } = await crearDetallePedido({ ...detalle, pedido_id: pedido[0].id });
      if (errorDetalle) {
        console.error('Error al crear detalle:', errorDetalle);
        return res.status(500).json({ error: 'Error al guardar el detalle del pedido', detalle: errorDetalle.message });
      }
    }
    return res.status(201).json({ message: 'Pedido enviado a cocina', pedido: pedido[0] });
  } catch (error) {
    console.error('Error en crearPedidoMesero:', error);
    return res.status(500).json({ error: error.message });
  }
};

// GET /pedido/mesero/abiertos: los pedidos de ESTE mesero que aún no entrega.
export const pedidosMeseroAbiertos = async (req, res) => {
  try {
    const { data, error } = await obtenerPedidosAbiertosPorUsuario(req.usuario.id);
    if (error) return res.status(500).json({ error: 'No se pudieron cargar tus pedidos', detalle: error.message });
    return res.status(200).json({ pedidos: data || [] });
  } catch (error) {
    console.error('Error en pedidosMeseroAbiertos:', error);
    return res.status(500).json({ error: error.message });
  }
};

// GET /pedido/cocina/abiertos: TODOS los pedidos abiertos, sin importar
// quién los tomó. Es la bandeja de la cocina.
export const pedidosCocinaAbiertos = async (req, res) => {
  try {
    const { data, error } = await obtenerPedidosEnProceso();
    if (error) return res.status(500).json({ error: 'No se pudieron cargar los pedidos', detalle: error.message });
    return res.status(200).json({ pedidos: data || [] });
  } catch (error) {
    console.error('Error en pedidosCocinaAbiertos:', error);
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

// PATCH /pedido/:id/estado  body: { estado }
// Reglas por rol: cocina mueve pendiente -> en_proceso -> listo;
// el admin puede poner cualquier estado válido; el mesero usa /:id/entregar.
export const cambiarEstadoPedido = async (req, res) => {
  try {
    const { id } = req.params;
    const estado = String(req.body?.estado ?? '').trim();
    if (!ESTADOS.includes(estado)) {
      return res.status(400).json({ error: `Estado inválido. Usa: ${ESTADOS.join(', ')}` });
    }

    const rol = req.usuario?.rol;
    if (rol !== 'admin' && rol !== 'cocina') {
      return res.status(403).json({ error: 'Solo cocina o admin pueden cambiar el estado' });
    }

    const { data: pedidoActual, error: errorLeer } = await obtenerPedidoConDetalles(id);
    if (errorLeer || !pedidoActual) return res.status(404).json({ error: 'Pedido no encontrado' });

    if (rol === 'cocina') {
      const actual = pedidoActual.estado ?? 'pendiente';
      const permitido =
        (estado === 'en_proceso' && actual === 'pendiente') ||
        (estado === 'listo' && actual === 'en_proceso');
      if (!permitido) {
        return res.status(400).json({ error: `La cocina no puede pasar de "${actual}" a "${estado}"` });
      }
    }

    const { data, error } = await actualizarEstadoPedido(id, estado);
    if (error) return res.status(500).json({ error: 'No se pudo actualizar el estado', detalle: error.message });
    if (!data || data.length === 0) return res.status(404).json({ error: 'Pedido no encontrado' });
    return res.status(200).json({ message: 'Estado actualizado', pedido: data[0] });
  } catch (error) {
    console.error('Error en cambiarEstadoPedido:', error);
    return res.status(500).json({ error: error.message });
  }
};

// PATCH /pedido/:id/entregar
// El mesero solo puede entregar SUS pedidos y solo si la cocina los dejó 'listo'.
export const entregarPedido = async (req, res) => {
  try {
    const { id } = req.params;
    const rol = req.usuario?.rol;
    if (rol !== 'admin' && rol !== 'mesero') {
      return res.status(403).json({ error: 'Solo el mesero (o admin) puede entregar' });
    }

    const { data: pedido, error: errorLeer } = await obtenerPedidoConDetalles(id);
    if (errorLeer || !pedido) return res.status(404).json({ error: 'Pedido no encontrado' });
    if (pedido.estado !== 'listo') {
      return res.status(400).json({ error: 'La cocina aún no marca este pedido como listo' });
    }
    if (rol === 'mesero' && String(pedido.usuario_id) !== String(req.usuario.id)) {
      return res.status(403).json({ error: 'Solo puedes entregar tus propios pedidos' });
    }

    const { data, error } = await actualizarEstadoPedido(id, 'entregado');
    if (error) return res.status(500).json({ error: 'No se pudo entregar el pedido', detalle: error.message });
    return res.status(200).json({ message: 'Pedido entregado', pedido: data?.[0] });
  } catch (error) {
    console.error('Error en entregarPedido:', error);
    return res.status(500).json({ error: error.message });
  }
};