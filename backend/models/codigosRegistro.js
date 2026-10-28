import { supabase } from '../config/supabase.js';

const TABLA = 'codigos_registro';
const ahoraISO = () => new Date().toISOString();

export const crearCodigoAcceso = async ({ codigo, rol, expira_en }) => {
  const { data, error } = await supabase
    .from(TABLA)
    .insert({ codigo, rol_asignado: rol, expira_en, usado: false })
    .select()
    .single();
  return { data, error };
};

export const buscarCodigoAccesoValido = async (codigo) => {
  const { data, error } = await supabase
    .from(TABLA)
    .select('*')
    .eq('codigo', codigo)
    .eq('usado', false)
    .gt('expira_en', ahoraISO())
    .limit(1);
  return { data: data?.[0] ?? null, error };
};

export const buscarTodosLosCodigos = async () => {
  const { data, error } = await supabase
    .from(TABLA)
    .select('*')
    .order('creado_en', { ascending: false })
    .limit(50);
  return { data, error };
};

export const eliminarCodigoNoUsado = async (id) => {
  const { data, error } = await supabase
    .from(TABLA)
    .delete()
    .eq('id', id)
    .eq('usado', false)
    .select('id');
  return { data, error };
};

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

export const liberarCodigo = async (id) => {
  const { error } = await supabase
    .from(TABLA)
    .update({ usado: false, usado_en: null })
    .eq('id', id);
  return { error };
};

export const registrarUsoCodigo = async (id, { nombre, email, rol }) => {
  const { error } = await supabase
    .from(TABLA)
    .update({ usado_por_nombre: nombre, usado_por_email: email, rol_asignado: rol })
    .eq('id', id);
  return { error };
};
