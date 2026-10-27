import { supabase } from '../config/supabase.js';

// Obtener todos los tipos de productos
export const obtenerTipos = async () => {
    const { data, error } = await supabase
        .from("tipos_producto")
        .select("*");
    
    return { data, error };
};

// Obtener tipo de producto por id_tipo
export const obtenerTipoLote = async (id_tipo) => {
    const { data, error } = await supabase
        .from("tipos_producto")
        .select("*")
        .eq("id_tipo", id_tipo)
        .single();

    return { data, error };
};

// Crear tipo de producto
export const crearTipo = async (datosFormulario) => {
    // Clonamos el objeto del formulario para limpiarlo de forma segura
    const fila = { ...datosFormulario };
    
    // Eliminamos id_tipo para evitar que envíe campos vacíos, cadenas "" o valores nulos.
    // Esto obliga a PostgreSQL a generar el ID automático de forma correcta.
    delete fila.id_tipo; 

    const { data, error } = await supabase
        .from("tipos_producto")
        .insert([fila])
        .select();

    return { data, error };
};

// Editar tipo de producto
export const actualizarTipo = async (actualizar, id) => {
    const { data, error } = await supabase
        .from("tipos_producto")
        .update(actualizar)
        .eq("id_tipo", id)
        .select();

    return { data, error };
};

// Eliminar tipo de producto
export const eliminarTipo = async (eliminarId) => {
    const { data, error } = await supabase
        .from("tipos_producto")
        .delete()
        .eq("id_tipo", eliminarId);

    return { data, error };
};