 import { crearProducto, obtenerProductos, obtenerProductoPorId, actualizarProducto, eliminarProducto } from "../models/productos.js";
 import { obtenerTipo, ProductoPorId } from "../models/tipo_producto.js";


// crear producto
export const crear = async (req, res) => {
    try {

        const {
            id_tipo,
            nombre,
            fecha_ingreso,
            codigo_lote
        } = req.body;

        // Validar datos
        if (
            !id_tipo ||
            !nombre ||
            !fecha_ingreso ||
            !codigo_lote
        ) {
            return res.status(400).json({
                error: 'Todos los campos son obligatorios'
            });
        }

        // Buscar el tipo de producto
        const {
            data: tipoProducto,
            error: errorTipo
        } = await obtenerTipoProductoPorId(id_tipo);

        if (errorTipo || !tipoProducto) {
            return res.status(404).json({
                error: 'El tipo de producto no existe'
            });
        }

        // Obtener duración
        const duracion = tipoProducto.duracion_dias;

        // Crear producto
        const {
            data,
            error
        } = await crearProducto(
            id_tipo,
            nombre,
            fecha_ingreso,
            codigo_lote
        );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        // calcular fecha de vencimiento

        const fechaVencimiento = new Date(fecha_ingreso);

        fechaVencimiento.setDate(
            fechaVencimiento.getDate() + duracion
        );

        // Convertir a YYYY-MM-DD
        const fechaVencimientoTexto =
            fechaVencimiento.toISOString().split('T')[0];

        // Respuesta
        res.status(201).json({
            mensaje: 'Producto guardado correctamente',

            producto: data[0],

            duracion_dias: duracion,

            fecha_vencimiento: fechaVencimientoTexto,

            aviso: `El producto vence el ${fechaVencimientoTexto}`
        });

    } catch (error) {

        console.error(
            'Error al crear producto:',
            error
        );

        res.status(500).json({
            error: error.message
        });
    }
};


// obtener todos
export const obtenerTodos = async (req, res) => {
    try {

        const { data, error } =
            await obtenerProductos();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        const productos = data.map(producto => {

            const fechaVencimiento =
                new Date(producto.fecha_ingreso);

            fechaVencimiento.setDate(
                fechaVencimiento.getDate() +
                producto.tipo_producto.duracion_dias
            );

            return {
                ...producto,
                fecha_vencimiento:
                    fechaVencimiento
                        .toISOString()
                        .split('T')[0]
            };
        });

        res.status(200).json(productos);

    } catch (error) {

        res.status(500).json({
            error: error.message
        });
    }
};


// obtener por id
export const obtenerPorId = async (req, res) => {
    try {

        const { id } = req.params;

        const {
            data,
            error
        } = await obtenerProductoPorId(id);

        if (error || !data) {
            return res.status(404).json({
                error: 'Producto no encontrado'
            });
        }

        const fechaVencimiento =
            new Date(data.fecha_ingreso);

        fechaVencimiento.setDate(
            fechaVencimiento.getDate() +
            data.tipo_producto.duracion_dias
        );

        const fechaVencimientoTexto =
            fechaVencimiento
                .toISOString()
                .split('T')[0];

        res.status(200).json({
            ...data,
            fecha_vencimiento:
                fechaVencimientoTexto
        });

    } catch (error) {

        res.status(500).json({
            error: error.message
        });
    }
};