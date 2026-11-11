import { obtenerTodos, obtenerPorId, obtenerPorCategoria, crearPlato, actualizarPlato, eliminarPlato, obtenerFirma, marcarDisponibilidad } from "../models/menu.js";
import { createHash } from "node:crypto";

// GET /menu/version — huella barata para que la pantalla pública sepa
// si el admin cambió algo sin volver a bajar todo el menú.
export const versionMenu = async (_req, res) => {
  try {
    const { firma, error } = await obtenerFirma();
    if (error) return res.status(500).json({ error: 'Error al calcular la versión del menú' });
    const hash = createHash('sha1').update(firma ?? '').digest('hex');
    return res.status(200).json({ version: hash });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//obtener todos los platillos
// ?disponibles=true deja fuera los que el admin marcó como agotados. El filtro
// se hace aquí y no en la consulta para que la pantalla pública siga funcionando
// en las bases donde la columna disponible todavía no se ha creado.
export const listarMenu = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();
    if (error) {
      return res.status(500).json({ error: 'Error al obtener' });
    }
    const soloDisponibles = String(req.query.disponibles ?? '') === 'true';
    const platos = soloDisponibles ? (data ?? []).filter((p) => p.disponible !== false) : data;
    return res.status(200).json(platos);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// PATCH /menu/menu/:id/disponible  body: { disponible: true|false }
export const cambiarDisponibilidad = async (req, res) => {
  try {
    const { id } = req.params;
    const disponible = req.body?.disponible === true || String(req.body?.disponible).toLowerCase() === 'true';

    const { data, error } = await marcarDisponibilidad(id, disponible);
    if (error) {
      console.error('Error Supabase (disponibilidad):', error);
      if (/disponible/.test(error.message ?? '') && /does not exist|column|schema/i.test(error.message ?? '')) {
        return res.status(500).json({ error: 'Falta la columna "disponible" en la tabla menu. Ejecuta la migración en Supabase.' });
      }
      return res.status(500).json({ error: 'No se pudo cambiar la disponibilidad' });
    }
    if (!data || data.length === 0) return res.status(404).json({ error: 'Plato no encontrado' });
    return res.status(200).json({ message: disponible ? 'Plato habilitado' : 'Plato agotado', menu: data[0] });
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
    const { nombre, descripcion, precio, stock, imagen_url, categoria, sabor, ingredientes } = req.body;

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
      stock: stock === '' ? undefined : stock,
      imagen_url: imagen,
      categoria,
      sabor,
      // Solo se manda si trae valor: así la creación no falla en bases donde
      // la columna ingredientes todavía no existe.
      ...(ingredientes ? { ingredientes } : {})
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
// Acepta JSON o multipart (con foto nueva). Si llega una imagen, Cloudinary
// deja su URL en req.file.path y esa URL reemplaza a la anterior.
export const editar = async (req, res) => {
  try {
    const { id } = req.params;
    const campos = {};
    for (const [clave, valor] of Object.entries(req.body || {})) {
      if (valor === undefined || clave === 'imagen') continue;
      // precio y stock vacíos no se mandan (la BD no puede convertir "" a número)
      if ((clave === 'precio' || clave === 'stock') && valor === '') continue;
      // ingredientes vacío se ignora para no escribir en una columna que
      // puede no existir todavía en otras bases.
      if (clave === 'ingredientes' && valor === '') continue;
      campos[clave] = valor;
    }
    if (req.file) campos.imagen_url = req.file.path;
    if (Object.keys(campos).length === 0) {
      return res.status(400).json({ error: 'No hay datos para actualizar' });
    }
    const { data, error } = await actualizarPlato(id, campos);
    if (error) {
      return res.status(500).json({ error: 'Error al actualizar' });
    }
    return res.status(200).json({ message: 'Actualizado', menu: data[0] });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

//eliminar un platillo del menú 
// Borrado permanente: antes de borrar el menú se retiran sus líneas de
// detalle_pedido (FK detalle_pedido_menu_id_fkey), así que un plato con pedidos
// registrados ya no bloquea el borrado.
export const eliminar = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await eliminarPlato(id);
    if (error) {
      console.error('Error Supabase (eliminar plato):', error);
      return res.status(500).json({
        error: `No se pudo eliminar: ${error.message || 'el servidor no devolvió detalle'}`,
        detalle: error.message,
      });
    }
    if (!data || data.length === 0) return res.status(404).json({ error: 'Plato no encontrado' });
    return res.status(200).json({ message: 'Eliminado' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};