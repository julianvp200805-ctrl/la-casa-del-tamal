import { obtenerTodos, obtenerPorId, obtenerPorCategoria, crearPlato,actualizarPlato, eliminarPlato } from "../models/menu.js";

export const listarMenu = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();
    if (error) {
      return res.status(500).json({
        error: 'Error al obtener' 
      });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};
export const obtenerMenu = async (req, res) => {
    try {
    const { id } = req.params;
    const { data, error } = await obtenerPorId(id);
    if (error || !data) {
      return res.status(404).json({
        error: 'No encontrado'
      });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};
export const obtenerPorCat = async (req, res) => {
  try {
    const { categoria } = req.params;
    const { data, error } = await obtenerPorCategoria(categoria);
    if (error) {
      return res.status(500).json({
        error: 'Error'
      });
    }
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};
export const crear = async (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      precio,
      stock,
      imagen_url,
      categoria,
      sabor
    } = req.body;
    if (!nombre || !precio || !imagen_url) {
      return res.status(400).json({
        error: 'nombre, precio e imagen_url requeridos'
      });
    }
    const { data, error } = await crearMenu({
      nombre,
      descripcion,
      precio,
      stock,
      imagen_url,
      categoria,
      sabor
    });
    if (error) {
      return res.status(500).json({
        error: 'Error al crear'
      });
    }
    return res.status(201).json({
      message: 'Creado',
      helado: data[0]
    });
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};
export const editar = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await actualizarMenu(id, req.body);
    if (error) {
      return res.status(500).json({
        error: 'Error al actualizar'
      });
    }
    return res.status(200).json({
      message: 'Actualizado',
      helado: data[0]
    });
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};
export const eliminar = async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await eliminarMenu(id);
    if (error) {
      return res.status(500).json({
        error: 'Error al eliminar'
      });
    }
    return res.status(200).json({
      message: 'Eliminado'
    });
  } catch (error) {
    return res.status(500).json({
      error: error.message
    });
  }
};