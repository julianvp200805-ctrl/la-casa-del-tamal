import { supabase } from '../config/supabase.js';


export const crearUsuario = async (nombre, email, contrasena, rol) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            nombre,
            email,
            contrasena,
            rol
        })
        .select('*');

    return { data, error };
};

export const obtenerPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .single();

    return { data, error };
};

export const obtenerUsuarios = async () => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*');

    return { data, error };
};


// obtener el usuario por id
export const obtenerUsuarioPorId = async (id) => {
    const {data, error}= await supabase
        .from('usuarios')
        .select('id, nombre, email, rol')
        .eq('id', id)
        .single();
    return { data, error };
}

// actualizar un usuario
export const actualizarUsuario = async (id, campos) => {
    const {data, error} = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select('id, nombre, email,  contrasena, rol')
        .single();
    return { data, error };
}
//eliminar un usuario
export const eliminarUsuario = async (id) => {
    const {data, error} = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id)
        .select('id, nombre, email, contrasena, rol');

    return { data, error };
}