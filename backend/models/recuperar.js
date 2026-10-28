import { supabase } from '../config/supabase.js';

// Crear codigo de recuperación 
export const crearCodigoRecuperacion = async (usuarioId, codigo) => {
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // expira en 15 min
    const { data, error } = await supabase
        .from('recovery_codes')
        .insert({
            usuario_id: usuarioId,
            codigo: codigo,
            expires_at: expiresAt.toISOString()
            // Quitamos 'usado: false' si en Supabase ya tiene un valor default, de lo contrario se asume false
        })
        .select()
        .single(); // Añadimos .single() para que devuelva el objeto directo que tu controlador espera

    return { data, error };
};

// Obtener codigo no utilizado por usuario
export const obtenerCodigoValido = async (usuarioId, codigo) => {
    const { data, error } = await supabase
        .from('recovery_codes')
        .select('*')
        .eq('usuario_id', usuarioId)
        .eq('codigo', codigo)
        .eq('usado', false)
        .gt('expires_at', new Date().toISOString())
        .limit(1); // Cambiamos .single() por .limit(1) para evitar que falle si no encuentra registros en la BD

    return { data: data?.[0] || null, error };
};

// Marcar codigo como usado
export const marcarCodigoComoUsado = async (codigoId) => {
  const { data, error } = await supabase
    .from('recovery_codes')
    .update({ usado: true })
    .eq('id', codigoId)
    .select(); // Añadimos .select() para que tu controlador pueda leer el estado actualizado si lo necesita

  return { data, error };
};
