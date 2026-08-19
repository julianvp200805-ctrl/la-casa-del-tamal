import {supabase} from '../config/supabase.js';



// // Crear tipo de producto
// export const crearTipoProducto = async (nombre, duracion_dias) => {
//     const { data, error } = await supabase
//         .from('tipo_producto')
//         .insert({
//             nombre,
//             duracion_dias
//         })
//         .select();

//     return { data, error };
// };

// // Obtener todos los tipos
// export const obtenerTiposProducto = async () => {
//     const { data, error } = await supabase
//         .from('tipo_producto')
//         .select('*');

//     return { data, error };
// };

// // Buscar tipo por ID
// export const obtenerTipoProductoPorId = async (id_tipo) => {
//     const { data, error } = await supabase
//         .from('tipo_producto')
//         .select('*')
//         .eq('id_tipo', id_tipo)
//         .single();

//     return { data, error };
// };

// // Actualizar tipo
// export const actualizarTipoProducto = async (
//     id_tipo,
//     nombre,
//     duracion_dias
// ) => {
//     const { data, error } = await supabase
//         .from('tipo_producto')
//         .update({
//             nombre,
//             duracion_dias
//         })
//         .eq('id_tipo', id_tipo)
//         .select();

//     return { data, error };
// };

// // Eliminar tipo
// export const eliminarTipoProducto = async (id_tipo) => {
//     const { data, error } = await supabase
//         .from('tipo_producto')
//         .delete()
//         .eq('id_tipo', id_tipo);

//     return { data, error };
// };