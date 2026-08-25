import {supabase} from '../config/supabase.js';

// crear producto
export const crearProducto = async (
    id_producto,
    id_tipo,
    fecha_ingreso,
    codigo_lote
) => {
    const { data, error } = await supabase
        .from('productos')
        .insert({
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote
        })
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

//verificar que todos los producto existan
export const obtenerTipo2 = async (id_tipo) => { 
    return await supabase 
    .from("tipos_producto") 
    .select("id_tipo, nombre, dias_vencimiento") 
    .eq("id_tipo", id_tipo) 
    .single(); 
};

// Aactualizar producto
export const actualizarProducto = async (
    id_producto,
    id_tipo,
    fecha_ingreso,
    codigo_lote
) => {
    const { data, error } = await supabase
        .from('productos')
        .update({
            id_producto,
            id_tipo,
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
        .from('productos')
        .delete()
        .eq('id_producto', id_producto);
    return { data, error };
};