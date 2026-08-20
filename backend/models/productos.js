import {supabase} from '../config/supabase.js';

// crear producto
export const crearProducto = async (
    id_tipo,
    nombre,
    fecha_ingreso,
    codigo_lote
) => {
    const { data, error } = await supabase
        .from('producto')
        .insert({
            id_tipo,
            nombre,
            fecha_ingreso,
            codigo_lote
        })
        .select();

    return { data, error };
};

// obtener todos los productos
export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('producto')
        .select(`
            *,
            tipo_producto (
                nombre,
                duracion_dias
            )
        `);

    return { data, error };
};

// obtener producto por id
export const obtenerProductoPorId = async (id_producto) => {
    const { data, error } = await supabase
        .from('producto')
        .select(`
            *,
            tipo_producto (
                nombre,
                duracion_dias
            )
        `)
        .eq('id_producto', id_producto)
        .single();

    return { data, error };
};

// Aactualizar producto
export const actualizarProducto = async (
    id_producto,
    id_tipo,
    nombre,
    fecha_ingreso,
    codigo_lote
) => {
    const { data, error } = await supabase
        .from('producto')
        .update({
            id_tipo,
            nombre,
            fecha_ingreso,
            codigo_lote
        })
        .eq('id_producto', id_producto)
        .select();

    return { data, error };
};

// eliminar producto
export const eliminarProducto = async (id_producto) => {
    const { data, error } = await supabase
        .from('producto')
        .delete()
        .eq('id_producto', id_producto);

    return { data, error };
};