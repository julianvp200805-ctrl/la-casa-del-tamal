import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearConTamalin = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `tamalin_sesion_${Date.now()}`;

    // 1. Obtener la carta desde la tabla 'menu'
    const { data: productos, error: errorProductos } = await supabase
      .from("menu")
      .select("nombre, descripcion, precio");

    if (errorProductos) {
      console.error("Error al consultar Supabase:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    const { data: detallePedido, error: errorDetalle } = await supabase
      .from("detalle_pedido")
      .select("pedido_id, cantidad, precio_unitario, subtotal, menu:menu_id(nombre)");

    if (errorDetalle) {
      console.error("Error al consultar Supabase:", errorDetalle.message);
      return res.status(500).json({ message: "Error al consultar detalle del pedido." });
    }
    const hayCarta = productos && productos.length > 0;

    if (!hayCarta) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos la carta registrada.",
        sesionId: idSesionValido
      });
    }

    const catalogoTexto = productos.map(p =>
      `- **${p.nombre}**: $${Number(p.precio).toLocaleString("es-CO")} COP | Descripcion: ${p.descripcion ?? 'Sin descripcion'}`
    ).join("\n");

    const cuentasTexto = (detallePedido && detallePedido.length > 0)
      ? detallePedido.map(p =>
          `- **${p.menu?.nombre ?? 'Producto'}**: $${Number(p.precio_unitario).toLocaleString("es-CO")} COP | Cantidad: ${p.cantidad} | Subtotal: $${Number(p.subtotal).toLocaleString("es-CO")} COP`
        ).join("\n")
      : "Aun no hay ventas registradas en el sistema.";

    const systemPrompt = `
Eres el asesor virtual y anfitrion del mejor restaurante de comida tradicional del huila "La Casa del Tamal".
Eres alegre, amable, refrescante y educado.

CATALOGO ACTUAL EN TIENDA:
${catalogoTexto}

VENTAS REGISTRADAS:
${cuentasTexto}

REGLAS DE ATENCION:
1. Si el administrador solo saluda (ej: "Hola", "¿Como estas?"), responde con cortesia y cercania sin dar la carta ni precios:
   "¡Hola! Bienvenido a La Casa del Tamal 🫔. Que alegria tenerte aqui, ¿en que te puedo colaborar hoy?"
2. Da recomendaciones sobre las finanzas del negocio y mejoras para los productos cuando te lo pidan.
3. Especifica los valores siempre en pesos colombianos ($ COP).
4. Se conciso y completa tus oraciones.
5. Solo responde a preguntas relacionadas con el restaurante, sus finanzas y sus productos, no respondas a preguntas de otro tipo.
`;

    // 3. Inferencia con Groq
    const completion = await groq.chat.completions.create({
      model: "openai/gpt-oss-20b",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: mensaje }
      ],
      temperature: 0.3,
      max_tokens: 500,
    });

    const respuestaTexto = completion.choices[0]?.message?.content || "No pude generar una respuesta.";

    // 4. Guardar la conversacion
    const registrosAInsertar = [
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "admin",
        mensaje: mensaje.trim()
      },
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "bot",
        mensaje: respuestaTexto
      }
    ];

    const { error: errorInsert } = await supabase
      .from("mensajes_chat")
      .insert(registrosAInsertar);

    if (errorInsert) {
      console.error("Error guardando el historial en Supabase:", errorInsert.message);
      // No frenamos la respuesta al cliente aunque falle el guardado en BD
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido
    });

  } catch (error) {
    console.error("Error en Groq Chat Tamalin:", error);
    return res.status(500).json({
      message: "Error al procesar la respuesta",
      error: error.message
    });
  }
};

// Endpoint extra para recuperar la conversacion si el usuario vuelve a abrir la app
export const obtenerHistorialTamalin = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data: historial, error } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje, created_at")
      .eq("sesion_id", sesionId)
      .order("created_at", { ascending: true });

    if (error) {
      return res.status(500).json({ message: "Error al consultar historial", error: error.message });
    }

    return res.status(200).json({ historial: historial || [] });
  } catch (error) {
    return res.status(500).json({ message: "Error interno", error: error.message });
  }
};