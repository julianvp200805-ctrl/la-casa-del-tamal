import { obtenerTodos, obtenerPorId, obtenerPorCategoria, crearPlato, actualizarPlato, eliminarPlato } from "../models/menu.js";

//obtener todos los platillos 
export const listarMenu = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();
    if (error) {
      return res.status(500).json({ error: 'Error al obtener' });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
 //obtener uno por id 
export const obtenerMenu = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await obtenerPorId(id);
    if (error || !data) {
      return res.status(404).json({ error: 'No encontrado' });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//obtener por categoria
export const obtenerPorCat = async (req, res) => {
  try {
    const { categoria } = req.params;
    const { data, error } = await obtenerPorCategoria(categoria);
    if (error) {
      return res.status(500).json({ error: 'Error' });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//crear un platillo
export const crear = async (req, res) => {
  try {
    const { nombre, descripcion, precio, stock, imagen_url, categoria, sabor } = req.body;

    //// Cloudinary almacena la URL segura en req.file.path
    const imagen = req.file ? req.file.path : req.body.imagen_url;

    // Validar usando la variable 'imagen' que contiene la URL de Cloudinary
    if (!nombre || !precio || !imagen) {
      return res.status(400).json({
        error: 'nombre, precio e imagen requeridos'
      });
    }

   // Se envía 'imagen' con el nombre de propiedad 'imagen_url' a la base de datos
    const { data, error } = await crearPlato({
      nombre,
      descripcion,
      precio,
      stock,
      imagen_url: imagen,
      categoria,
      sabor
    });
    
    if (error) {
      return res.status(500).json({ error: 'Error al crear' });
    }
    return res.status(201).json({ message: 'Creado', menu: data[0] });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//editar un platillo del menu 
export const editar = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await actualizarPlato(id, req.body);
    if (error) {
      return res.status(500).json({ error: 'Error al actualizar' });
    }
    return res.status(200).json({ message: 'Actualizado', menu: data[0] });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//eliminar un platillo del menú 
export const eliminar = async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await eliminarPlato(id);
    if (error) {
      return res.status(500).json({ error: 'Error al eliminar' });
    }
    return res.status(200).json({ message: 'Eliminado' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};