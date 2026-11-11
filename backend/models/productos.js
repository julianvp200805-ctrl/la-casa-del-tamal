import { supabase } from '../config/supabase.js';

// crear producto.
// - id_producto: la columna es integer SIN valor por defecto y sin
//   restricción unique en la base, así que el backend le asigna el máximo
//   existente + 1. Sin esto el id quedaba NULL y el producto no se podía
//   eliminar ni editar (ese era el bug del módulo de eliminar).
// - fecha_ingreso y código de lote los calcula el controller: la fecha es
//   siempre el día del registro y el lote T{id_tipo}-LT001, LT002... por tipo.
export const crearProducto = async (id_tipo, fecha_ingreso, codigo_lote) => {
    const { data: existentes, error: errorIds } = await supabase
        .from('productos')
        .select('id_producto');

    if (errorIds) return { data: null, error: errorIds };

    const siguienteId = (existentes ?? []).reduce((max, fila) => {
        const n = Number(fila?.id_producto);
        return Number.isFinite(n) && n > max ? n : max;
    }, 0) + 1;

    const fila = {
        id_producto: siguienteId,
        id_tipo,
        fecha_ingreso,
        codigo_lote
    };

    const { data, error } = await supabase
        .from('productos')
        .insert(fila)
        .select();

    return { data, error };
};

// obtener todos los productos
export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('productos')
        .select(`
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote,
            tipos_producto (
                id_tipo,
                nombre,
                dias_vencimiento
            )
        `);

    return { data, error };
};

// obtener producto por id
export const obtenerProductoPorId = async (id_producto) => {
    const { data, error } = await supabase
        .from('productos')
        .select(`
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote,
            tipos_producto (
                id_tipo,
                nombre,
                dias_vencimiento
            )
        `)
        .eq('id_producto', id_producto)
        .single();

    return { data, error };
};

// lotes en uso de un tipo de producto: sirve para numerar el lote nuevo de
// ese tipo con el menor número libre (LT001, LT002...).
export const obtenerLotesPorTipo = async (id_tipo) => {
    const { data, error } = await supabase
        .from('productos')
        .select('codigo_lote')
        .eq('id_tipo', id_tipo);

    return { lotes: data ?? [], error };
};

// verificar que el tipo de producto exista (usado antes de crear/editar)
export const obtenerTipo2 = async (id_tipo) => {
    const { data, error } = await supabase
        .from('tipos_producto')
        .select('id_tipo, nombre, dias_vencimiento')
        .eq('id_tipo', id_tipo)
        .single();

    return { data, error };
};

// actualizar producto: solo se tocan los campos que llegan en `campos`.
export const actualizarProducto = async (id_producto, campos) => {
    const { data, error } = await supabase
        .from('productos')
        .update(campos)
        .eq('id_producto', id_producto)
        .select();

    return { data, error };
};

// eliminar producto (sacar un lote del inventario).
// .select() devuelve las filas realmente borradas; sin eso el controller no
// puede distinguir "no existía" de "no borró nada".
export const eliminarProducto = async (id_producto) => {
    const { data, error } = await supabase
        .from('productos')
        .delete()
        .eq('id_producto', id_producto)
        .select();

    return { data, error };
};
