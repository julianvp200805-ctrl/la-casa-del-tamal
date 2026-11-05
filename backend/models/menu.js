import { supabase } from '../config/supabase.js';


export const obtenerTodos = async () => {
  const { data, error } = await supabase.from('menu').select('*');
  return { data, error };
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase
    .from('menu')
    .select('*')
    .eq('id', id)
    .single();

  return { data, error };
};

export const obtenerPorCategoria = async (categoria) => {
  const { data, error } = await supabase
    .from('menu')
    .select('*')
    .eq('categoria', categoria);

  return { data, error };
};

export const crearPlato = async (menuData) => {
  const { data, error } = await supabase
    .from('menu')
    .insert(menuData)
    .select();

  return { data, error };
};

export const actualizarPlato = async (id, menuData) => {
  const { data, error } = await supabase
    .from('menu')
    .update(menuData)
    .eq('id', id)
    .select();

  return { data, error };
};

export const eliminarPlato = async (id) => {
  const { data, error } = await supabase
    .from('menu')
    .delete()
    .eq('id', id);

  return { data, error };
};

// Deshabilitar un plato temporalmente (se acabó el insumo) sin borrarlo del
// menú ni perder su foto, precio ni categoría.
export const marcarDisponibilidad = async (id, disponible) => {
  const { data, error } = await supabase
    .from('menu')
    .update({ disponible })
    .eq('id', id)
    .select();

  return { data, error };
};

// Huella del contenido del menú: cambia con cualquier alta, edición o borrado.
// Ordenar por id es obligatorio: sin orden garantizado la misma tabla puede
// devolver las filas en otro orden y la huella cambiaría sin que nadie editó.
export const obtenerFirma = async () => {
  const { data, error } = await supabase.from('menu').select('*').order('id');
  const firma = error ? null : (data || []).map((f) => JSON.stringify(f)).join('|');
  return { firma, error };
};
