import { supabase } from '../config/supabase.js';

// Crear codigo de recuperación 
export const crearCodigoRecuperacion = async (usuarioId, codigo) => {
    // Calculamos los 15 minutos de expiración
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); 

    const { data, error } = await supabase
        .from('recovery_codes')
        .insert([
            {
                usuario_id: usuarioId,
                codigo: codigo,
                expires_at: expiresAt.toISOString(),
                usado: false // Forzamos explícitamente el estado inicial
            }
        ])
        .select();

    // Tu controlador espera { data: usuario, error: errorCodigo }
    // Retornamos el primer elemento del array generado si no hay errores
    return { 
        data: data && data.length > 0 ? data[0] : null, 
        error 
    };
};

// Obtener codigo no utilizado por usuario
export const obtenerCodigoValido = async (usuarioId, codigo) => {
    // Usamos new Date() directamente para que Supabase gestione la conversión nativa de zona horaria
    const ahora = new Date();

    const { data, error } = await supabase
        .from('recovery_codes')
        .select('*')
        .eq('usuario_id', usuarioId)
        .eq('codigo', codigo)
        .eq('usado', false)
        .gt('expires_at', ahora.toISOString())
        .order('creado_en', { ascending: false }) // Trae siempre el código más reciente primero
        .limit(1);

    // Evitamos caídas del servidor: si no hay filas, data es null/vacío y retorna de forma segura
    return { 
        data: data && data.length > 0 ? data[0] : null, 
        error 
    };
};

// Marcar codigo como usado
export const marcarCodigoComoUsado = async (codigoId) => {
    const { data, error } = await supabase
        .from('recovery_codes')
        .update({ usado: true })
        .eq('id', codigoId)
        .select();

    return { 
        data: data && data.length > 0 ? data[0] : null, 
        error 
    };
};
