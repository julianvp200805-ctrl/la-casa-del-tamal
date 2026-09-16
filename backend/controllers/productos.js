import {
    crearProducto,
    obtenerProductos,
    obtenerProductoPorId,
    obtenerTipo2,
    actualizarProducto,
    eliminarProducto
} from "../models/productos.js";
// CREAR PRODUCTO
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
                error: "Todos los campos son obligatorios"
            });
        }

        // Validar fecha antes de utilizarla
        const fechaIngreso = new Date(fecha_ingreso);

        if (isNaN(fechaIngreso.getTime())) {
            return res.status(400).json({
                error: "La fecha de ingreso no es válida. Usa el formato YYYY-MM-DD"
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

        // Obtener duración
        const duracion = tipoProducto.dias_vencimiento;

        // Crear producto
        const {
            data,
            error
        } = await crearProducto(
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
        const fechaVencimiento = new Date(fechaIngreso);

        fechaVencimiento.setDate(
            fechaVencimiento.getDate() + duracion
        );

        // Convertir a YYYY-MM-DD
        const fechaVencimientoTexto =
            fechaVencimiento.toISOString().split("T")[0];

        // Respuesta
        return res.status(201).json({
            mensaje: "Producto guardado correctamente",
            producto: data[0],
            duracion_dias: duracion,
            fecha_vencimiento: fechaVencimientoTexto,
            aviso: `El producto vence el ${fechaVencimientoTexto}`
        });

    } catch (error) {

        console.error("Error al crear producto:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};



// OBTENER TODOS

export const obtenerTodos = async (req, res) => {
    try {

        const {
            data,
            error
        } = await obtenerProductos();

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
                producto.tipos_producto.dias_vencimiento
            );

            return {
                ...producto,

                fecha_vencimiento:
                    fechaVencimiento
                        .toISOString()
                        .split("T")[0]
            };
        });

        return res.status(200).json(productos);

    } catch (error) {

        console.error("Error al obtener productos:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};
// OBTENER POR ID
export const obtenerPorId = async (req, res) => {
    try {

        const { id } = req.params;
        const {
            data,
            error
        } = await obtenerProductoPorId(id);
        if (error || !data) {
            return res.status(404).json({
                error: "Producto no encontrado"
            });
        }
        return res.status(200).json(data);
    } catch (error) {
        console.error("Error al obtener producto:", error);
        return res.status(500).json({
            error: error.message
        });
    }
};

// EDITAR PRODUCTO
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
        // Validar fecha
        const fechaIngreso = new Date(fecha_ingreso);
        if (isNaN(fechaIngreso.getTime())) {
            return res.status(400).json({
                error: "La fecha de ingreso no es válida. Usa el formato YYYY-MM-DD"
            });
        }
        // Buscar tipo de producto
        const {
            data: tipoProducto,
            error: errorTipo
        } = await obtenerTipo2(id_tipo);
        if (errorTipo || !tipoProducto) {
            return res.status(404).json({
                error: "El tipo de producto no existe"
            });
        }
        // Actualizar producto
        const {
            data,
            error
        } = await actualizarProducto(
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
        // Calcular fecha de vencimiento
        const fechaVencimiento = new Date(fechaIngreso);
        fechaVencimiento.setDate(
            fechaVencimiento.getDate() +
            tipoProducto.dias_vencimiento
        );
        const fechaVencimientoTexto =
            fechaVencimiento
                .toISOString()
                .split("T")[0];
        return res.status(200).json({
            mensaje: "Producto actualizado correctamente",
            producto: data[0],
            fecha_vencimiento: fechaVencimientoTexto,
            duracion_dias: tipoProducto.dias_vencimiento
        });
    } catch (error) {
        console.error("Error al editar producto:", error);
        return res.status(500).json({
            error: error.message
        });
    }
};
// ELIMINAR PRODUCTO
export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            data,
            error
        } = await eliminarProducto(id);
        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Producto eliminado correctamente",
            producto: data
        });
    } catch (error) {
        console.error("Error al eliminar producto:", error);
        return res.status(500).json({
            error: error.message
        });
    }
};