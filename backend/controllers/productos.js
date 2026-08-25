 import { crearProducto, obtenerProductos, obtenerProductoPorId, obtenerTipo2, actualizarProducto, eliminarProducto } from "../models/productos.js";

// crear producto
export const crear = async (req, res) => {
    try {

        const {
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote
        } = req.body;

        // Validar datos
        if (
            !id_producto ||
            !id_tipo ||
            !fecha_ingreso ||
            !codigo_lote
        ) {
            return res.status(400).json({
                error: 'Todos los campos son obligatorios'
            });
        }

        // Buscar el tipo de producto
        const {
            data: tiposProducto,
            error: errorTipo
        } = await obtenerTipo2(id_tipo);

        if (errorTipo || !tiposProducto) {
            return res.status(404).json({
                error: 'El tipo de producto no existe'
            });
        }   

        // Obtener duración
        const duracion = tiposProducto.dias_vencimiento;

        // Crear producto
        const { data, error } = await crearProducto(
            id_producto,
            id_tipo,
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

<<<<<<< HEAD
         res.status(200).json({
            productos: data
=======
        const productos = data.map(producto => {

            const fechaVencimiento =
                new Date(producto.fecha_ingreso);

            fechaVencimiento.setDate(
                fechaVencimiento.getDate() +
                producto.tipos_producto.duracion_dias
            );

            return {
                ...producto,
                fecha_vencimiento:
                    fechaVencimiento
                        .toISOString()
                        .split('T')[0]
            };
>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17
        });

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

<<<<<<< HEAD
        const { data, error } = await obtenerProductoPorId(id);
=======
        const { data, error } = await obtenerProductoPorId(id_producto);
>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17

        if (error || !data) {
            return res.status(404).json({
                error: 'Producto no encontrado'
            });
        }

        res.status(200).json(data);

    } catch (error) {

        res.status(500).json({
            error: error.message
        });
    }
};

// Editar producto
export const editar = async (req, res) => {
    try {

        const { id } = req.params;

        const {
            id_tipo,
            fecha_ingreso,
            codigo_lote
        } = req.body;

        // Validar datos
        if (
            !id_tipo ||
            !fecha_ingreso ||
            !codigo_lote
        ) {
            return res.status(400).json({
                error: "Todos los campos son obligatorios"
            });
        }

        // Buscar el tipo de producto
        const {
            data: tipoProducto,
            error: errorTipo
        } = await obtenerTipo2(id_tipo); 

        if (errorTipo || !tipoProducto) {
            return res.status(404).json({
                error: "El tipo de producto no existe"
            });
        }

        // Validar fecha
        const fechaVencimiento = new Date(fecha_ingreso);

        if (isNaN(fechaVencimiento.getTime())) {
            return res.status(400).json({
                error: "La fecha de ingreso no es válida"
            });
        }

        // Calcular fecha de vencimiento
        fechaVencimiento.setDate(
            fechaVencimiento.getDate() +
<<<<<<< HEAD
            tipoProducto.dias_vencimiento 
=======
            data.tipos_producto.duracion_dias
>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17
        );

        const fechaVencimientoTexto =
            fechaVencimiento
                .toISOString()
                .split("T")[0];

        // Actualizar producto
        const { data, error } =
            await actualizarProducto(
                id,
                id_tipo,
                fecha_ingreso,
                codigo_lote
            );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json({
            mensaje: "Producto actualizado correctamente",
            producto: data[0],
            fecha_vencimiento: fechaVencimientoTexto,
            duracion_dias: tipoProducto.dias_vencimiento 
        });

    } catch (error) {

        res.status(500).json({
            error: error.message
        });
    }
};

<<<<<<< HEAD
=======
// editar producto
export const editar = async (req, res) => {
    try {

        const { id } = req.params;

        const {
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote
        } = req.body;

        // Validar datos
        if (
            !id_producto ||
            !id_tipo ||
            !fecha_ingreso ||
            !codigo_lote
        ) {
            return res.status(400).json({
                error: 'Todos los campos son obligatorios'
            });
        }

        // Buscar el tipo de producto
        const { data: tipos_Producto, error: errorTipo } = await obtenerProductoPorId(id_tipo);

        if (errorTipo || !tipos_Producto) {
            return res.status(404).json({
                error: 'El tipo de producto no existe'
            });
        }

        // Actualizar producto
        const { data, error } = await actualizarProducto(
            id_producto,
            id_tipo,
            fecha_ingreso,
            codigo_lote
        );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        // Calcular fecha de vencimiento
        const fechaVencimiento = new Date(fecha_ingreso);

        fechaVencimiento.setDate(
            fechaVencimiento.getDate() +
            tipos_Producto.duracion_dias
        );

        const fechaVencimientoTexto =
            fechaVencimiento
                .toISOString()
                .split('T')[0];

        res.status(200).json({
            mensaje: 'Producto actualizado correctamente',

            producto: data[0],

            duracion_dias:
                tipos_Producto.duracion_dias,

            fecha_vencimiento:
                fechaVencimientoTexto,

            aviso:
                `El producto vence el ${fechaVencimientoTexto}`
        });

    } catch (error) {

        console.error(
            'Error al actualizar producto:',
            error
        );

        res.status(500).json({
            error: error.message
        });
    }
};


>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17
// eliminar producto
export const eliminar = async (req, res) => {
    try {

        const { id } = req.params;

        // Eliminar producto
        const { data, error } =
<<<<<<< HEAD
            await eliminarProducto(id);
=======
            await eliminarProducto(id_producto);
>>>>>>> 74dce6cebc1b65e8b7f1bb05005ed48f01f79b17

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json({
            mensaje: 'Producto eliminado correctamente',
            producto: data
        });

    } catch (error) {

        console.error(
            'Error al eliminar producto:',
            error
        );

        res.status(500).json({
            error: error.message
        });
    }
};