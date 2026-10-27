import { supabase } from '../config/supabase.js';

// POST /auth/verificar-codigo-registro
// body: { codigo }
export const verificarCodigoRegistro = async (req, res) => {
    try {
        const codigo = String(req.body?.codigo ?? '').trim();

        if (!/^\d{6}$/.test(codigo)) {
            return res.status(400).json({ error: 'El código de registro debe tener 6 números' });
        }

        // Busca el código directamente en la base de datos
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
