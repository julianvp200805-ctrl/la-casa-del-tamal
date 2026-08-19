import { obtenerTipos, obtenerTipoLote, crearTipo, actualizarTipo, eliminarTipo} from "../models/tipos_productos.js";
// obtener todos los tipos de productos
export const listarTipos = async (req, res) => {

    const { data, error } = await obtenerTipos();

    if (error) return res.status(500).json(error);

    res.json(data);
};

// Obtener por ID
export const obtenerTipo = async (req, res) => {

    const { id } = req.params;

    const { data, error } = await obtenerTipoLote(id);

    if (error) return res.status(404).json(error);

    res.json(data);
};

// Crear
export const crearTipo2 = async (req, res) => {

    const { nombre, dias_vencimiento, codigo_lote } = req.body;

    const { data, error } = await crearTipo({
        nombre,
        dias_vencimiento,
        codigo_lote
    });

    if (error) return res.status(500).json(error);

    res.status(201).json({
        mensaje: "Tipo de producto creado correctamente",
        data: data[0]
    });
};

// Editar
export const editarTipo = async (req, res) => {

    const { id } = req.params;
    const { nombre, dias_vencimiento, codigo_lote } = req.body;

    const { data, error } = await actualizarTipo(id, {
        nombre,
        dias_vencimiento,
        codigo_lote
    });

    if (error) return res.status(500).json(error);

    res.json({
        mensaje: "Tipo de producto actualizado correctamente"
});
};

// Eliminar
export const deleteTipo = async (req, res) => {

    const { id } = req.params;

    const { error } = await eliminarTipo(id);

    if (error) return res.status(500).json(error);

    res.json({
        mensaje: "Tipo de producto eliminado correctamente"
    });
};