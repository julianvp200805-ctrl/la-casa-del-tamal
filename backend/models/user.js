import { supabase } from '../config/supabase.js';

// Columnas que se pueden mostrar. La contraseña (hash) NUNCA sale en estas consultas.
const PUBLICAS = 'id, nombre, email, rol';

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

// Usa select('*') porque el login necesita el hash para compararlo.
export const obtenerPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .single();

    return { data, error };
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

//eliminar un usuario
export const eliminarUsuario = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id)
        .select(PUBLICAS);

    return { data, error };
};