import { 
  crearCodigoAcceso, 
  buscarCodigoAccesoValido, 
  buscarTodosLosCodigos, 
  eliminarCodigoNoUsado 
} from '../models/codigosRegistro.js';

export const generarCodigoRegistro = async (req, res) => {
  try {
    const { rol } = req.body;
    if (!rol || !['mesero', 'cocina'].includes(rol.toLowerCase())) {
      return res.status(400).json({ error: 'El rol debe ser mesero o cocina' });
    }

    const caracteres = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    const gen = (cant) => Array.from({ length: cant }, () => caracteres[Math.floor(Math.random() * caracteres.length)]).join('');
    const codigoFormateado = `TAM-${gen(4)}-${gen(2)}`;

    const expira_en = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    const { data, error } = await crearCodigoAcceso({
      codigo: codigoFormateado,
      rol: rol.toLowerCase().trim(),
      expira_en
    });

    if (error) throw error;

    return res.status(201).json({
      message: 'Código generado exitosamente',
      codigo: data.codigo,
      rol: data.rol_asignado,
      expira_en: data.expira_en
    });

  } catch (error) {
    console.error('Error al generar código:', error);
    return res.status(500).json({ error: 'Error interno al procesar la solicitud' });
  }
};

export const verificarCodigoRegistro = async (req, res) => {
  try {
    const { codigo } = req.body;
    if (!codigo) {
      return res.status(400).json({ error: 'El código es requerido' });
    }

    const { data: codigoValido, error } = await buscarCodigoAccesoValido(codigo);
    
    if (error || !codigoValido) {
      return res.status(400).json({ error: 'El código de registro no es válido, ya fue usado o ha expirado' });
    }

    return res.status(200).json({
      valid: true,
      message: 'Código válido',
      rol_asignado: codigoValido.rol_asignado
    });

  } catch (error) {
    console.error('Error al verificar código:', error);
    return res.status(500).json({ error: 'Error interno al validar el código' });
  }
};

export const listarCodigosRegistro = async (req, res) => {
  try {
    const { data, error } = await buscarTodosLosCodigos();
    if (error) throw error;
    return res.status(200).json(data);
  } catch (error) {
    console.error('Error al listar códigos:', error);
    return res.status(500).json({ error: 'Error interno al obtener los códigos' });
  }
};

export const revocarCodigoRegistro = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await eliminarCodigoNoUsado(id);
    
    if (error || !data || data.length === 0) {
      return res.status(400).json({ error: 'No se pudo revocar el código. Es posible que ya haya sido utilizado.' });
    }

    return res.status(200).json({ message: 'Código revocado y eliminado exitosamente' });
  } catch (error) {
    console.error('Error al revocar código:', error);
    return res.status(500).json({ error: 'Error interno al revocar el código' });
  }
};
