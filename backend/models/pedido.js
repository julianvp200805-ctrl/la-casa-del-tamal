import { supabase } from '../config/supabase.js';

export const crearPedido = async (pedidoData) => {
  const { data, error } = await supabase.from('pedidos').insert(pedidoData).select();
  return { data, error };
};

// La columna "nota" de detalle_pedido puede no existir todavía en la base.
// Si la consulta falla por esa columna se reintenta sin ella, así la bandeja
// de cocina y la pantalla de estados siguen sirviendo antes de la migración.
const reintentarSinNota = async (ejecutar) => {
  const intento = await ejecutar(true);
  if (intento.error && /nota/.test(intento.error.message || '')) return ejecutar(false);
  return intento;
};

export const obtenerPedidoConDetalles = async (id) => {
  const ejecutar = (conNota) => supabase
    .from('pedidos')
    .select(`*, usuario:usuario_id(id, nombre, email), detalles:detalle_pedido(id, cantidad, precio_unitario, subtotal${conNota ? ', nota' : ''}, menu:menu_id(id, nombre, imagen_url))`)
    .eq('id', id)
    .single();
  const { data, error } = await reintentarSinNota(ejecutar);
  return { data, error };
};

// Pedidos abiertos (ni entregados ni cancelados) de un mesero concreto,
// con sus productos. Es la lista "mis pedidos" de la pantalla de estados.
export const obtenerPedidosAbiertosPorUsuario = async (usuarioId) => {
  const ejecutar = (conNota) => supabase
    .from('pedidos')
    .select(`*, detalles:detalle_pedido(cantidad, precio_unitario, subtotal${conNota ? ', nota' : ''}, menu:menu_id(nombre))`)
    .eq('usuario_id', usuarioId)
    .or('estado.is.null,estado.not.in.(entregado,cancelado)')
    .order('fecha_pedido', { ascending: true })
    .limit(100);
  const { data, error } = await reintentarSinNota(ejecutar);
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
  const ejecutar = (conNota) => supabase
    .from('pedidos')
    .select(`*, detalles:detalle_pedido(cantidad, precio_unitario, subtotal${conNota ? ', nota' : ''}, menu:menu_id(nombre))`)
    .or('estado.is.null,estado.not.in.(entregado,cancelado)')
    .order('fecha_pedido', { ascending: true })
    .limit(100);
  const { data, error } = await reintentarSinNota(ejecutar);
  return { data, error };
};

export const crearDetallePedido = async (detalleData) => {
  let { data, error } = await supabase.from('detalle_pedido').insert(detalleData).select();
  // Si la columna "nota" todavía no está en la base, el pedido no se pierde:
  // se guarda el detalle sin la nota.
  if (error && /nota/.test(error.message || '')) {
    console.warn('detalle_pedido.nota no existe, guardo el detalle sin nota');
    const { nota, ...sinNota } = detalleData;
    ({ data, error } = await supabase.from('detalle_pedido').insert(sinNota).select());
  }
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
