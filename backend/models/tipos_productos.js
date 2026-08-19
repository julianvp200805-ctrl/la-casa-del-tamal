import {supabase} from '../config/supabase.js';

// Obtener todos los productos
export const obtenerTipos = async () => {
    return await supabase
        .from("tipos_producto")
        .select("*")
        return { data, error };
        
};

// Obtener producto por codigo de lote
export const obtenerTipoLote = async (codigo_lote) => {
    return await supabase
        .from("tipos_producto")
        .select("*")
        .eq("codigo_lote", codigo_lote)
        .single();
        return { data, error };
};

// Crear producto 
export const crearTipo = async (crear) => {
    return await supabase
        .from("tipos_producto")
        .insert([crear])
        .select();
        return { data, error };
};

// Editar producto
export const actualizarTipo = async (actualizar, id) => {
    return await supabase
        .from("tipos_producto")
        .update(actualizar)
        .eq("id_tipo", id)
        .select();
        return { data, error };
};

// Eliminar producto
export const eliminarTipo = async (eliminarId) => {
    return await supabase
        .from("tipos_producto")
        .delete()
        .eq("id_tipo", eliminarId)
        return { data, error };
};