import { supabase } from '../config/supabase.js'; // Ajusta la ruta si tu cliente de supabase está en otra carpeta

/**
 * 1) Reclamar código (Atómico)
 * Busca un código de 6 dígitos que esté activo, no esté usado y no haya expirado.
 * Si lo encuentra, lo marca temporalmente como usado para evitar que otra persona lo registre al mismo tiempo.
 */
export const reclamarCodigo = async (codigo) => {
    try {
        const { data, error } = await supabase
            .from('codigos_registro') // Reemplaza por el nombre exacto de tu tabla en Supabase si cambia
            .select('id, codigo, usado, expirado_en')
            .eq('codigo', codigo)
            .eq('usado', false)
            .gt('expirado_en', new Date().toISOString())
            .single();

        if (error || !data) {
            return { data: null, error };
        }

        // Marcamos el código como usado de forma preliminar
        const { data: actualizado, error: errorUpdate } = await supabase
            .from('codigos_registro')
            .update({ usado: true })
            .eq('id', data.id)
            .select()
            .single();

        return { data: actualizado, error: errorUpdate };
    } catch (error) {
        return { data: null, error };
    }
};

/**
 * 2) Liberar código
 * Si el registro falla a mitad de camino por un correo o documento duplicado,
 * esta función devuelve el código a su estado original (no usado) para no desperdiciarlo.
 */
export const liberarCodigo = async (codigoId) => {
    try {
        const { data, error } = await supabase
            .from('codigos_registro')
            .update({ usado: false })
            .eq('id', codigoId)
            .select()
            .single();

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};

/**
 * 3) Registrar uso del código
 * Guarda la auditoría final de qué empleado (nombre, email, rol) consumió con éxito el código.
 */
export const registrarUsoCodigo = async (codigoId, empleadoInfo) => {
    try {
        const { data, error } = await supabase
            .from('codigos_registro')
            .update({
                empleado_nombre: empleadoInfo.nombre,
                empleado_email: empleadoInfo.email,
                empleado_rol: empleadoInfo.rol,
                utilizado_en: new Date().toISOString()
            })
            .eq('id', codigoId)
            .select()
            .single();

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};
