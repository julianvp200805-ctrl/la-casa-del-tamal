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