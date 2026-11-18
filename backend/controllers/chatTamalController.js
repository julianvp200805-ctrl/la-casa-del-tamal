import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// Formatea un número como pesos colombianos (ej. 12345 -> "12.345").
const cop = (n) => `$${Number(n || 0).toLocaleString("es-CO")} COP`;

// Agrupa un arreglo por una clave y suma un campo numérico.
const agruparSuma = (arr, clave, campo) => {
  const mapa = {};
  for (const item of arr || []) {
    const k = item[clave];
    if (k == null) continue;
    mapa[k] = (mapa[k] || 0) + Number(item[campo] || 0);
  }
  return mapa;
};

export const chatearConTamalin = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `tamalin_sesion_${Date.now()}`;

    // 1. Carta actual del restaurante
    const { data: productos, error: errorProductos } = await supabase
      .from("menu")
      .select("id, nombre, descripcion, precio, categoria, disponible");

    if (errorProductos) {
      console.error("Error al consultar menu:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    const hayCarta = productos && productos.length > 0;
    if (!hayCarta) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos la carta registrada en el sistema.",
        sesionId: idSesionValido
      });
    }

    // 2. Pedidos y sus líneas de detalle (para finanzas y top productos)
    const { data: pedidos } = await supabase
      .from("pedidos")
      .select("id, usuario_id, total, estado, direccion_entrega, fecha_pedido, fecha_entrega");

    const { data: detalles } = await supabase
      .from("detalle_pedido")
      .select("pedido_id, menu_id, cantidad, precio_unitario, subtotal, menu:menu_id(nombre, categoria)");

    const { data: usuarios } = await supabase
      .from("usuarios")
      .select("id, nombre, rol");

    const mapaUsuarios = Object.fromEntries((usuarios || []).map((u) => [String(u.id), u]));

    // 3. Agregados financieros
    const pedidosEntregados = (pedidos || []).filter((p) => p.estado === "entregado");
    const totalVentas = pedidosEntregados.reduce((acc, p) => acc + Number(p.total || 0), 0);
    const totalPedidos = (pedidos || []).length;
    const pedidosPorEstado = agruparSuma(pedidos || [], "estado", "total");
    const conteoPorEstado = {};
    for (const p of (pedidos || [])) {
      const e = p.estado || "sin_estado";
      conteoPorEstado[e] = (conteoPorEstado[e] || 0) + 1;
    }

    // Top productos por cantidad vendida (solo pedidos entregados).
    const idsEntregados = new Set(pedidosEntregados.map((p) => p.id));
    const detallesEntregados = (detalles || []).filter((d) => idsEntregados.has(d.pedido_id));
    const cantidadPorProducto = {};
    const ingresosPorProducto = {};
    for (const d of detallesEntregados) {
      const nombre = d.menu?.nombre || `Producto #${d.menu_id}`;
      cantidadPorProducto[nombre] = (cantidadPorProducto[nombre] || 0) + Number(d.cantidad || 0);
      ingresosPorProducto[nombre] = (ingresosPorProducto[nombre] || 0) + Number(d.subtotal || 0);
    }
    const topPorCantidad = Object.entries(cantidadPorProducto)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8);
    const topPorIngresos = Object.entries(ingresosPorProducto)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8);

    // Mesas atendidas (distintas) entre pedidos entregados.
    const mesasAtendidas = new Set(pedidosEntregados.map((p) => String(p.direccion_entrega || "").trim()).filter(Boolean));

    // Ventas por mesero (top).
    const ventasPorMesero = {};
    for (const p of pedidosEntregados) {
      const uid = p.usuario_id;
      if (uid == null) continue;
      if (!ventasPorMesero[uid]) ventasPorMesero[uid] = { pedidos: 0, total: 0 };
      ventasPorMesero[uid].pedidos += 1;
      ventasPorMesero[uid].total += Number(p.total || 0);
    }
    const rankingMeseros = Object.entries(ventasPorMesero)
      .map(([uid, v]) => ({ nombre: mapaUsuarios[uid]?.nombre || `Mesero #${uid}`, pedidos: v.pedidos, total: v.total }))
      .sort((a, b) => b.total - a.total)
      .slice(0, 5);

    // Ventas del mes en curso vs mes anterior (tendencia).
    const ahora = new Date();
    const mesActual = ahora.getUTCMonth();
    const anioActual = ahora.getUTCFullYear();
    const ventasMesActual = pedidosEntregados
      .filter((p) => { const d = new Date(p.fecha_entrega || p.fecha_pedido); return d.getUTCMonth() === mesActual && d.getUTCFullYear() === anioActual; })
      .reduce((acc, p) => acc + Number(p.total || 0), 0);
    const mesAnterior = mesActual === 0 ? 11 : mesActual - 1;
    const anioAnterior = mesActual === 0 ? anioActual - 1 : anioActual;
    const ventasMesAnterior = pedidosEntregados
      .filter((p) => { const d = new Date(p.fecha_entrega || p.fecha_pedido); return d.getUTCMonth() === mesAnterior && d.getUTCFullYear() === anioAnterior; })
      .reduce((acc, p) => acc + Number(p.total || 0), 0);

    // 4. Construir el catálogo de texto
    const catalogoTexto = productos.map((p) =>
      `- **${p.nombre}** (${p.categoria ?? "General"}): ${cop(p.precio)} | ${p.disponible === false ? "AGOTADO" : "disponible"} | ${p.descripcion ?? "Sin descripcion"}`
    ).join("\n");

    const topCantidadTexto = topPorCantidad.length > 0
      ? topPorCantidad.map(([n, c]) => `- ${n}: ${c} unidades | ${cop(ingresosPorProducto[n])}`).join("\n")
      : "Aun no hay ventas registradas.";

    const topIngresosTexto = topPorIngresos.length > 0
      ? topPorIngresos.map(([n, i]) => `- ${n}: ${cop(i)} (${cantidadPorProducto[n]} uds)`).join("\n")
      : "Aun no hay ventas registradas.";

    const rankingMeserosTexto = rankingMeseros.length > 0
      ? rankingMeseros.map((r) => `- ${r.nombre}: ${r.pedidos} pedidos, ${cop(r.total)}`).join("\n")
      : "Aun no hay ventas por mesero registradas.";

    const fechaHoy = ahora.toLocaleDateString("es-CO", { weekday: "long", year: "numeric", month: "long", day: "numeric" });

    // 5. Prompt del sistema (Tamalin = asesor exclusivo del admin)
    const systemPrompt = `
Eres "Tamalin", el asesor virtual e inteligente del restaurante tradicional colombiano "La Casa del Tamal".
Eres un asistente EXCLUSIVO para el ADMINISTRADOR del negocio. Hablas en espanol, eres cercano, alegre y profesional.

HOY ES: ${fechaHoy}

CATALOGO ACTUAL (menu):
${catalogoTexto}

RESUMEN FINANCIERO DEL NEGOCIO:
- Total de pedidos registrados: ${totalPedidos}
- Pedidos entregados (ventas): ${pedidosEntregados.length}
- Ingresos totales (ventas entregadas): ${cop(totalVentas)}
- Mesas atendidas (distintas): ${mesasAtendidas.size}
- Distribucion por estado: ${Object.entries(conteoPorEstado).map(([e, c]) => `${e}: ${c}`).join(", ") || "sin datos"}
- Ventas este mes: ${cop(ventasMesActual)}
- Ventas mes anterior: ${cop(ventasMesAnterior)}
- Tendencia: ${ventasMesActual > ventasMesAnterior ? "SUBIENDO" : ventasMesActual < ventasMesAnterior ? "BAJANDO" : "ESTABLE"}

TOP PRODUCTOS POR CANTIDAD VENDIDA:
${topCantidadTexto}

TOP PRODUCTOS POR INGRESOS:
${topIngresosTexto}

RANKING DE MESEROS (por ventas):
${rankingMeserosTexto}

REGLAS ESTRICTAS (OBLIGATORIAS):
1. SOLO respondes temas del restaurante "La Casa del Tamal": su carta, finanzas, ventas, productos, recetas, ingredientes, costos, rentabilidad, recomendaciones de negocio y de cocina.
2. Si te preguntan algo que NO tenga que ver con el restaurante (politica, deportes, programacion, chistes, temas personales, etc.), responde amablemente que solo puedes ayudar con temas del restaurante y ofrece colaborar en finanzas, ventas, recetas o la carta.
3. Da cifras en pesos colombianos ($ COP) y se concreto.
4. Cuando te pidan finanzas/ventas, usa los datos reales de arriba (ingresos, top productos, tendencia) y da recomendaciones accionables (ej. promocionar el producto mas vendido, revisar el menos vendido, ajustar precios).
5. Cuando te pidan recetas nuevas, recomienda platos de desayuno, almuerzo y comida tipica colombiana (tamales, arepas, bandeja paisa, ajiaco, etc.), y si te dan ingredientes o presupuesto, arma recetas con eso.
6. Si te dan un presupuesto de dinero, recomienda recetas y platos que se puedan hacer con ese presupuesto.
7. No inventes datos que no esten en el contexto; si no sabes algo, dilo y sugiere como obtenerlo.
8. No respondas preguntas fuera del ambito del restaurante. Nunca rompas este limite.
`;

    // 6. Inferencia con Groq
    const completion = await groq.chat.completions.create({
      model: "openai/gpt-oss-20b",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: mensaje }
      ],
      temperature: 0.3,
      max_tokens: 700,
    });

    const respuestaTexto = completion.choices[0]?.message?.content || "No pude generar una respuesta.";

    // 7. Guardar la conversacion
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