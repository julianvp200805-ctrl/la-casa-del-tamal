import {
  crearPedido,
  obtenerPedidoConDetalles,
  crearDetallePedido,
  obtenerPedidosPorUsuario,
  obtenerPedidosPorRango,
  eliminarPedido
} from "../models/pedido.js";
import { obtenerUsuarioPorId as obtenerUsuario } from "../models/user.js";
//creamos pedidos, en "crearPedidoConDetalles",  lo creamos para la tabla pedidos en donde el mesero visualisa que esta listo para llevar
export const crearPedidoConDetalles = async (req, res) => {
  try {
    const { usuario_id, direccion_entrega, telefono, notas, detalles } = req.body;

    if (!usuario_id || !detalles || detalles.length === 0) {
      return res.status(400).json({ error: 'Datos incompletos' });
    }
    let total = 0;
    detalles.forEach(d => {
      total += d.subtotal;
    });
//en el otro lo creamos para que cocina visualise que se pidio
    const { data: pedido, error: errorPedido } = await crearPedido({
      usuario_id, direccion_entrega, telefono, notas, total
    });

    if (errorPedido || !pedido) {
      console.error('Error Supabase (crearPedido):', errorPedido);
      return res.status(500).json({ error: 'Error al crear pedido', detalle: errorPedido?.message });
    }

    const detallesConPedido = detalles.map(d => ({
      ...d, pedido_id: pedido[0].id
    }));

    for (let detalle of detallesConPedido) {
      const { error: errorDetalle } = await crearDetallePedido(detalle);
      if (errorDetalle) {
        console.error('Error al crear detalle:', errorDetalle);
        return res.status(500).json({ error: 'Error al crear detalle de pedido', detalle: errorDetalle.message });
      }
    }
    return res.status(201).json({
      message: 'Pedido creado',
      pedido: pedido[0]
    });
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

// NUEVO: reporte de ventas para el admin.
export const reporteVentas = async (req, res) => {
  try {
    const { tipo } = req.query;

    if (!['diaria', 'semanal', 'mensual'].includes(tipo)) {
      return res.status(400).json({
        error: "El parametro 'tipo' debe ser: diaria, semanal o mensual"
      });
    }

    const ahora = new Date();
    let fechaInicio;

    if (tipo === 'diaria') {
      // desde las 00:00 de hoy
      fechaInicio = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate());
    } else if (tipo === 'semanal') {
      fechaInicio = new Date(ahora);
      fechaInicio.setDate(ahora.getDate() - 7);
    } else {
      // mensual
      fechaInicio = new Date(ahora);
      fechaInicio.setDate(ahora.getDate() - 30);
    }

    const { data, error } = await obtenerPedidosPorRango(
      fechaInicio.toISOString(),
      ahora.toISOString()
    );

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el reporte de ventas' });
    }

    // Solo se cuentan pedidos que no estén cancelados (ajusta el nombre
    // del estado si en tu tabla usas otro valor distinto a 'entregado')
    const pedidosValidos = data.filter(p => p.estado !== 'entregado');

    const totalVentas = pedidosValidos.reduce(
      (acumulado, pedido) => acumulado + Number(pedido.total || 0),
      0
    );

    return res.status(200).json({
      tipo,
      desde: fechaInicio.toISOString(),
      hasta: ahora.toISOString(),
      cantidadPedidos: pedidosValidos.length,
      totalVentas,
      pedidos: pedidosValidos
    });
  } catch (error) {
    console.error('Error en reporteVentas:', error);
    return res.status(500).json({ error: error.message });
  }
};
export const eliminarPedidoUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) {
      return res.status(400).json({
        error: "ID del pedido requerido"
      });
    }
    const { data, error } = await eliminarPedido(id);
    if (error) {
      console.error("Error al eliminar pedido:", error);
      return res.status(500).json({
        error: "Error al eliminar el pedido",
        detalle: error.message
      });
    }
    if (!data || data.length === 0) {
      return res.status(404).json({
        error: "Pedido no encontrado"
      });
    }
    return res.status(200).json({
      message: "Pedido eliminado correctamente",
      pedido: data[0]
    });
  } catch (error) {
    console.error("Error en eliminarPedidoUsuario:", error);
    return res.status(500).json({
      error: error.message
    });
  }
};