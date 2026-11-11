import {
    crearProducto,
    obtenerProductos,
    obtenerProductoPorId,
    obtenerTipo2,
    obtenerLotesPorTipo,
    actualizarProducto,
    eliminarProducto
} from "../models/productos.js";

// El restaurante opera en Colombia: el "día en que entra el producto" se
// fija con la fecha de Bogotá y no con la del servidor (Render corre en
// UTC, que ya es "mañana" desde las 7 de la tarde hora local).
// en-CA formatea como YYYY-MM-DD.
const hoy = () =>
    new Intl.DateTimeFormat("en-CA", {
        timeZone: "America/Bogota",
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }).format(new Date());

// Código del próximo lote de un tipo: T{id_tipo}-LT001, LT002...
// La numeración es POR tipo de producto (puede existir un LT001 de huevo y un
// LT001 de carne a la vez) y los números de los lotes sacados vuelven a quedar
// disponibles para el próximo ingreso de ese mismo tipo.
// El prefijo "T{id_tipo}-" existe porque la columna codigo_lote es la clave
// primaria de la tabla y debe ser única en toda la tabla; la app solo muestra
// la parte del lote (LT001), sin el prefijo.
const siguienteLote = (lotes, id_tipo) => {
    const usados = new Set(
        (lotes ?? [])
            .map((fila) => {
                const lote = String(fila?.codigo_lote ?? "");
                const m = lote.match(/LT(\d+)$/);
                return m ? Number(m[1]) : null;
            })
            .filter((n) => n !== null)
    );

    let numero = 1;
    while (usados.has(numero)) numero++;

    return `T${id_tipo}-LT${String(numero).padStart(3, "0")}`;
};

// CREAR PRODUCTO (registrar un lote nuevo)
// Solo se envía el tipo de producto: la fecha de ingreso se fija al día en
// que se registra el lote y el código de lote lo asigna el backend.
export const crear = async (req, res) => {
    try {
        const { id_tipo } = req.body ?? {};

        if (!id_tipo) {
            return res.status(400).json({
                error: "Elige el tipo de producto"
            });
        }

        // Buscar el tipo de producto (define nombre y días hasta vencer)
        const {
            data: tipoProducto,
            error: errorTipo
        } = await obtenerTipo2(id_tipo);

        if (errorTipo || !tipoProducto) {
            return res.status(404).json({
                error: "El tipo de producto no existe"
            });
        }

        const duracion = tipoProducto.dias_vencimiento;

        // La fecha de ingreso SIEMPRE es el día en que se registra el lote:
        // hoy para un lote creado hoy, mañana para uno creado mañana.
        const fechaIngreso = hoy();

        // Lote automático por tipo: el menor número libre (LT001, LT002...)
        const {
            lotes,
            error: errorLotes
        } = await obtenerLotesPorTipo(id_tipo);

        if (errorLotes) {
            return res.status(500).json({
                error: "No se pudo calcular el código de lote"
            });
        }

        const codigoLote = siguienteLote(lotes, id_tipo);

        // Crear producto (el modelo genera el id_producto)
        const {
            data,
            error
        } = await crearProducto(
            id_tipo,
            fechaIngreso,
            codigoLote
        );

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        // Fecha de vencimiento = día de ingreso + días del tipo de producto
        const fechaVencimiento = new Date(`${fechaIngreso}T00:00:00Z`);

        fechaVencimiento.setUTCDate(
            fechaVencimiento.getUTCDate() + duracion
        );

        const fechaVencimientoTexto =
            fechaVencimiento.toISOString().split("T")[0];

        // Respuesta
        return res.status(201).json({
            mensaje: "Producto guardado correctamente",
            producto: data[0],
            codigo_lote: codigoLote,
            duracion_dias: duracion,
            fecha_vencimiento: fechaVencimientoTexto,
            aviso: `Lote ${codigoLote.split("-").pop()} de ${tipoProducto.nombre}: vence el ${fechaVencimientoTexto}`
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

        const productos = (data ?? []).map((producto) => {

            // Sin fecha de ingreso no hay fecha de vencimiento que calcular
            if (!producto.fecha_ingreso) {
                return {
                    ...producto,
                    fecha_vencimiento: null
                };
            }

            const fechaVencimiento =
                new Date(producto.fecha_ingreso);

            fechaVencimiento.setDate(
                fechaVencimiento.getDate() +
                (producto.tipos_producto?.dias_vencimiento ?? 0)
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
// Cambia el tipo o corrige la fecha de ingreso de un lote existente. El
// número de lote nunca cambia al editar: es la identidad del registro.
export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            id_tipo,
            fecha_ingreso
        } = req.body ?? {};

        // Producto actual: lo que no llegue se mantiene igual
        const {
            data: actual,
            error: errorBuscar
        } = await obtenerProductoPorId(id);

        if (errorBuscar || !actual) {
            return res.status(404).json({
                error: "Producto no encontrado"
            });
        }

        const tipoFinal = id_tipo ?? actual.id_tipo;

        // Buscar tipo de producto
        const {
            data: tipoProducto,
            error: errorTipo
        } = await obtenerTipo2(tipoFinal);

        if (errorTipo || !tipoProducto) {
            return res.status(404).json({
                error: "El tipo de producto no existe"
            });
        }

        // Sin fecha nueva se conserva la del registro (la fecha de ingreso
        // es el día en que entró el lote y solo se corrige si está mal)
        const fechaFinal = fecha_ingreso ?? actual.fecha_ingreso;
        const fecha = new Date(String(fechaFinal));

        if (isNaN(fecha.getTime())) {
            return res.status(400).json({
                error: "La fecha de ingreso no es válida. Usa el formato YYYY-MM-DD"
            });
        }

        // Solo se mandan los campos que realmente cambian
        const campos = {};
        if (id_tipo && id_tipo !== actual.id_tipo) campos.id_tipo = id_tipo;
        if (fecha_ingreso && fecha_ingreso !== actual.fecha_ingreso) campos.fecha_ingreso = fecha_ingreso;

        if (Object.keys(campos).length === 0) {
            return res.status(400).json({
                error: "No hay datos para actualizar"
            });
        }

        // Actualizar producto
        const {
            data,
            error
        } = await actualizarProducto(id, campos);

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        // Calcular fecha de vencimiento
        const fechaVencimiento = new Date(fecha);
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

// SACAR PRODUCTO (eliminar un lote del inventario)
// Al sacarse, su número de lote queda libre: el próximo lote de ese tipo
// reutiliza el menor número disponible.
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
        if (!data || data.length === 0) {
            return res.status(404).json({
                error: "Producto no encontrado"
            });
        }
        return res.status(200).json({
            mensaje: "Producto sacado del inventario",
            producto: data[0]
        });
    } catch (error) {
        console.error("Error al eliminar producto:", error);
        return res.status(500).json({
            error: error.message
        });
    }
};
