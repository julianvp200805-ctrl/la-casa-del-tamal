import { supabase } from '../config/supabase.js';

// Columnas públicas permitidas en las respuestas (incluyendo los nuevos campos de empleado)
const PUBLICAS = 'id, nombre, email, rol, tipo_documento, numero_documento, fecha_nacimiento';

export const crearUsuario = async (nombre, email, contrasena, rol) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({ nombre, email, contrasena, rol })
        .select(PUBLICAS);

    return { data, error };
};

// Alta de un empleado (cocina o mesero) con sus datos completos.
export const crearUsuarioEmpleado = async (campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert(campos)
        .select(PUBLICAS)
        .single();

    return { data, error };
};

// CORRECCIÓN: Usa .ilike para ignorar mayúsculas/minúsculas y .limit(1) para evitar que .single() crashee si no hay coincidencia exacta
export const obtenerPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .ilike('email', email.trim())
        .limit(1);

    return { data: (data && data.length > 0) ? data[0] : null, error };
};

export const obtenerPorDocumento = async (tipo, numero) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id')
        .eq('tipo_documento', tipo)
        .eq('numero_documento', numero)
        .limit(1);

    return { data: data?.[0] ?? null, error };
};

export const obtenerUsuarios = async () => {
    const { data, error } = await supabase
        .from('usuarios')
        .select(PUBLICAS);

    return { data, error };
};

// obtener el usuario por id
export const obtenerUsuarioPorId = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select(PUBLICAS)
        .eq('id', id)
        .single();
    return { data, error };
};

// actualizar un usuario
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select(PUBLICAS)
        .single();
    return { data, error };
};

// eliminar un usuario
export const eliminarUsuario = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id)
        .select(PUBLICAS);

    return { data, error };
};