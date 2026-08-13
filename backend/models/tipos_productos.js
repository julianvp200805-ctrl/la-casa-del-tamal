import {supabase} from '../config/supabase.js';

// Obtener todos los productos
export const obtenerTipos = async () => {
    return await supabase
        .from("tipos_producto")
        .select("*");
};

// Obtener producto por id
export const obtenerTipoId = async (id) => {
    return await supabase
        .from("tipos_producto")
        .select("*")
        .eq("id_tipo", id)
        .single();
};

// Crear producto 
export const crearTipo = async (tipo) => {
    return await supabase
        .from("tipos_producto")
        .insert([tipo])
        .eq("nombre", tipo.nombre)
        .eq("dias_vencimiento", tipo.dias_vencimiento)
        .select();
};

// Editar producto
export const actualizarTipo = async (id, tipo) => {
    return await supabase
        .from("tipos_producto")
        .update(tipo)
        .eq("id_tipo", id)
        .eq("nombre", tipo.nombre)
        .eq("dias_venciminiento", dias_vencimiento)
        .select();
};

// Eliminar producto
export const eliminarTipo = async (id) => {
    return await supabase
        .from("tipos_producto")
        .delete()
        .eq("id_tipo", id);
};