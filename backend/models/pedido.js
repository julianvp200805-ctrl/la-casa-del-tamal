import { supabase } from '../config/supabase.js';

export const crearPedido = async (pedidoData) => {
  const { data, error } = await supabase.from('pedidos').insert(pedidoData).select();
  return { data, error };
};

export const obtenerPedidoConDetalles = async (id) => {
  const { data, error } = await supabase
    .from('pedidos')
    .select(`*, usuario:usuario_id(id, nombre, email), detalles:detalle_pedido(id, cantidad, precio_unitario, subtotal, menu:menu_id(id, nombre, imagen_url))`)
    .eq('id', id)
    .single();
  return { data, error };
};

export const obtenerPedidosPorUsuario = async (usuarioId) => {
  const { data, error } = await supabase.from('pedidos').select('*').eq('usuario_id', usuarioId).order('fecha_pedido', { ascending: false });
  return { data, error };
};

// Cambia el estado de un pedido. Si tu tabla no tiene la columna
// "actualizado_en", reintenta solo con "estado".
export const actualizarEstadoPedido = async (id, estado) => {
  let r = await supabase.from('pedidos').update({ estado, actualizado_en: new Date() }).eq('id', id).select();
  if (r.error && /actualizado_en/.test(r.error.message || '')) {
    r = await supabase.from('pedidos').update({ estado }).eq('id', id).select();
  }
  return { data: r.data, error: r.error };
};

// Pedidos que todavía no se cierran (ni entregados ni cancelados), del más
// viejo al más nuevo, con sus productos.
export const obtenerPedidosEnProceso = async () => {
  const { data, error } = await supabase
    .from('pedidos')
    .select('*, detalles:detalle_pedido(cantidad, precio_unitario, subtotal, menu:menu_id(nombre))')
    .or('estado.is.null,estado.not.in.(entregado,cancelado)')
    .order('fecha_pedido', { ascending: true })
    .limit(100);
  return { data, error };
};

export const crearDetallePedido = async (detalleData) => {
  const { data, error } = await supabase.from('detalle_pedido').insert(detalleData).select();
  return { data, error };
};

export const obtenerPedidosPorRango = async (fechaInicioISO, fechaFinISO) => {
  const { data, error } = await supabase
    .from('pedidos')
    .select('id, usuario_id, total, estado, fecha_pedido')
    .gte('fecha_pedido', fechaInicioISO)
    .lte('fecha_pedido', fechaFinISO)
    .order('fecha_pedido', { ascending: false });
  return { data, error };
};

// NUEVO: trae el detalle (producto, cantidad, subtotal) de los pedidos
// que caen dentro de un rango de fechas. Primero busca los IDs de pedido
// en ese rango, y luego trae sus líneas de detalle_pedido con el nombre
// del plato. Es la base del desglose "10 chorizo / 15 tamales / ...".
export const obtenerItemsPorRango = async (fechaInicioISO, fechaFinISO) => {
  const { data: pedidos, error: errorPedidos } = await obtenerPedidosPorRango(fechaInicioISO, fechaFinISO);
  if (errorPedidos) return { data: null, error: errorPedidos };

  const idsValidos = (pedidos || []).filter(p => p.estado !== 'cancelado').map(p => p.id);
  if (idsValidos.length === 0) return { data: [], error: null };

  const { data, error } = await supabase
    .from('detalle_pedido')
    .select('cantidad, subtotal, menu:menu_id(nombre)')
    .in('pedido_id', idsValidos);

  return { data, error };
};

export const eliminarPedido = async (id) => {
  const { data, error } = await supabase.from('pedidos').delete().eq('id', id).select();
  return { data, error };
};