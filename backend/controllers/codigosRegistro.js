import { supabase } from '../config/supabase.js';

// 1) POST /auth/verificar-codigo-registro
// body: { codigo }
export const verificarCodigoRegistro = async (req, res) => {
    try {
        const codigo = String(req.body?.codigo ?? '').trim();

        if (!/^\d{6}$/.test(codigo)) {
            return res.status(400).json({ error: 'El código de registro debe tener 6 números' });
        }

        const { data, error } = await supabase
            .from('codigos_registro')
            .select('id, usado, expirado_en')
            .eq('codigo', codigo)
            .single();

        if (error || !data) {
            return res.status(404).json({ error: 'El código ingresado no existe' });
        }

        if (data.usado) {
            return res.status(400).json({ error: 'Este código ya ha sido utilizado' });
        }

        const haExpirado = new Date(data.expirado_en) <= new Date();
        if (haExpirado) {
            return res.status(400).json({ error: 'Este código ya ha vencido' });
        }

        return res.status(200).json({ 
            message: 'Código válido y disponible para el registro',
            valido: true 
        });

    } catch (error) {
        console.error('Error al verificar código:', error);
        return res.status(500).json({ error: error.message });
    }
};

// 2) POST /codigos/generar (Acción de Admin)
// body: { diasValidez }
export const generarCodigoRegistro = async (req, res) => {
    try {
        // Genera un número aleatorio de 6 dígitos acolchado con ceros
        const numeroAleatorio = Math.floor(100000 + Math.random() * 900000);
        const nuevoCodigo = String(numeroAleatorio);
        
        const dias = parseInt(req.body?.diasValidez ?? 1, 10);
        const fechaExpiracion = new Date();
        fechaExpiracion.setDate(fechaExpiracion.getDate() + dias);

        const { data, error } = await supabase
            .from('codigos_registro')
            .insert([{ 
                codigo: nuevoCodigo, 
                usado: false, 
                expirado_en: fechaExpiracion.toISOString() 
            }])
            .select()
            .single();

        if (error) return res.status(500).json({ error: `No se pudo crear el código: ${error.message}` });

        return res.status(201).json({ message: 'Código generado con éxito', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// 3) GET /codigos
export const listarCodigosRegistro = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('codigos_registro')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) return res.status(500).json({ error: error.message });

        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// 4) DELETE o POST /codigos/revocar/:id
export const revocarCodigoRegistro = async (req, res) => {
    try {
        const { id } = req.params;

        // Lo revocamos forzando que expire inmediatamente
        const { data, error } = await supabase
            .from('codigos_registro')
            .update({ expirado_en: new Date().toISOString() })
            .eq('id', id)
            .select()
            .single();

        if (error) return res.status(500).json({ error: error.message });

        return res.status(200).json({ message: 'Código revocado con éxito', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};
