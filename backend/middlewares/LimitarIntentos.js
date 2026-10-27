// Límite de intentos en memoria (se reinicia al reiniciar el servidor).
// Frena la fuerza bruta sobre login, códigos de registro y recuperación.
// Si algún día despliegas detrás de un proxy, activa app.set('trust proxy', 1)
// para que req.ip sea la IP real del cliente.
export const limitarIntentos = ({
    ventanaMs = 15 * 60 * 1000,
    max = 10,
    clave = (req) => req.ip,
    mensaje = 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.'
} = {}) => {
    const registros = new Map();
    
    // limpia las entradas vencidas para no acumular memoria
    setInterval(() => {
        const ahora = Date.now();
        for (const [k, r] of registros) if (r.reinicia <= ahora) registros.delete(k);
    }, ventanaMs).unref();

    return (req, res, next) => {
        const ahora = Date.now();
        const k = clave(req);
        const r = registros.get(k);

        if (!r || r.reinicia <= ahora) {
            registros.set(k, { n: 1, reinicia: ahora + ventanaMs });
            return next();
        }
        r.n += 1;
        if (r.n > max) {
            res.set('Retry-After', String(Math.ceil((r.reinicia - ahora) / 1000)));
            return res.status(429).json({ error: mensaje });
        }
        next();
    };
};