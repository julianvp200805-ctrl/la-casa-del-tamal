import { supabase } from '../config/supabase.js';

const TABLA = 'codigos_registro';
const ahoraISO = () => new Date().toISOString();

export const crearCodigo = async ({ codigo, email_destino, expira_en }) => {
    const { data, error } = await supabase
        .from(TABLA)
        .insert({ codigo, email_destino, expira_en })
        .select()
        .single();
    return { data, error };
};

export const listarCodigos = async () => {
    const { data, error } = await supabase
        .from(TABLA)
        .select('*')
        .order('creado_en', { ascending: false })
        .limit(50);
    return { data, error };
};

// ¿Existe este código sin usar y sin vencer? (no lo consume)
export const buscarCodigoDisponible = async (codigo) => {
    const { data, error } = await supabase
        .from(TABLA)
        .select('id')
        .eq('codigo', codigo)
        .eq('usado', false)
        .gt('expira_en', ahoraISO())
        .limit(1);
    return { data: data?.[0] ?? null, error };
};

// Consume el código de forma atómica: el UPDATE solo afecta una fila si
// todavía estaba sin usar, así dos registros a la vez no pueden gastarlo.
export const reclamarCodigo = async (codigo) => {
    const { data, error } = await supabase
        .from(TABLA)
        .update({ usado: true, usado_en: ahoraISO() })
        .eq('codigo', codigo)
        .eq('usado', false)
        .gt('expira_en', ahoraISO())
        .select('id');
    return { data: data?.[0] ?? null, error };
};

// Si el registro falla después de reclamar el código, se devuelve.
export const liberarCodigo = async (id) => {
    const { error } = await supabase.from(TABLA).update({ usado: false, usado_en: null }).eq('id', id);
    return { error };
};

export const registrarUsoCodigo = async (id, { nombre, email, rol }) => {
    const { error } = await supabase
        .from(TABLA)
        .update({ usado_por_nombre: nombre, usado_por_email: email, rol_asignado: rol })
        .eq('id', id);
    return { error };
};

// Solo se pueden borrar (revocar) los códigos que aún no se usaron.
export const eliminarCodigoDisponible = async (id) => {
    const { data, error } = await supabase
        .from(TABLA)
        .delete()
        .eq('id', id)
        .eq('usado', false)
        .select('id');
    return { data, error };
};