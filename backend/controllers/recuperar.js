import { crearCodigoRecuperacion, obtenerCodigoValido, marcarCodigoComoUsado } from "../models/recuperar.js";
import { obtenerPorEmail, actualizarUsuario } from "../models/user.js";
// Importamos tu servicio de correo basado en nodemailer que acabas de corregir
import { enviarCorreoBrevo } from "../config/brevo.js"; 
import bcrypt from "bcrypt";

// POST /auth/forgot-password
export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ error: 'El correo electrónico es requerido' });
        }

        // Verificar si el usuario existe en tu base de datos de Supabase
        const { data: usuario, error: errorUsuario } = await obtenerPorEmail(email);
        if (errorUsuario || !usuario) {
            return res.status(400).json({ error: 'Usuario no encontrado' });
        }

        // Generamos el código de recuperación de 6 dígitos numéricos
        const codigo = Math.floor(100000 + Math.random() * 900000).toString();

        // Guardar el código en la tabla recovery_codes de Supabase
        const { error: errorCodigo } = await crearCodigoRecuperacion(usuario.id, codigo);
        if (errorCodigo) {
            return res.status(500).json({ error: 'Error al generar el código de recuperación' });
        }

        // Plantilla HTML del correo electrónico
        const htmlRecuperacion = `
        <div style="font-family: 'Segoe UI', sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0; font-size: 24px; font-weight: 700;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Sistema de Gestión Interna</p>
            </div>
            <h3 style="color: #333333; font-size: 18px; margin-top: 0;">Solicitud de recuperación de contraseña</h3>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Hemos recibido una solicitud para restablecer tu contraseña. Utiliza el siguiente código de verificación de 6 dígitos de seguridad:</p>
            <div style="text-align: center; margin: 30px 0;">
                <div style="display: inline-block; background-color: #f4faf2; border: 2px dashed #39a900; border-radius: 8px; padding: 15px 40px; letter-spacing: 6px;">
                    <span style="color: #39a900; font-size: 36px; font-weight: bold; font-family: monospace;">${codigo}</span>
                </div>
            </div>
            <p style="color: #666666; font-size: 13px;">Este código tiene un tiempo de validez limitado de 15 minutos.</p>
        </div>
        `;

        // Llamamos a tu función que ahora utiliza Nodemailer y tu clave de Gmail de forma segura
        await enviarCorreoBrevo({
            para: email,
            nombre: usuario.nombre,
            asunto: `Código de recuperación: ${codigo}`,
            html: htmlRecuperacion
        });

        return res.status(200).json({ message: 'Código de recuperación enviado al correo con éxito' });
    } catch (error) {
        console.error('Error en forgotPassword:', error);
        return res.status(500).json({ error: 'Error al enviar código de recuperación' });
    }
};

// POST /auth/verify-code
export const verifyCode = async (req, res) => {
    try {
        const { email, codigo, newPassword } = req.body;
        
        if (!email || !codigo || !newPassword) {
            return res.status(400).json({ error: "Todos los campos son requeridos: email, código y nueva contraseña" });
        }

        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const { data: codigoValido } = await obtenerCodigoValido(usuario.id, codigo);
        if (!codigoValido) {
            return res.status(400).json({ error: 'Código de recuperación inválido o expirado' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);

        const { error: errorUpdate } = await actualizarUsuario(usuario.id, { contrasena: hashedPassword });
        if (errorUpdate) throw errorUpdate;

        await marcarCodigoComoUsado(codigoValido.id);

        const htmlConfirmacion = `
        <div style="font-family: 'Segoe UI', sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0; font-size: 24px; font-weight: 700;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Confirmación de Seguridad</p>
            </div>
            <h3 style="color: #2c3e50; font-size: 18px; text-align: center;">¡Contraseña modificada exitosamente!</h3>
            <p>Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p>Te informamos que las credenciales de tu cuenta han sido actualizadas con éxito. A partir de ahora podrás iniciar sesión con tu nueva contraseña.</p>
        </div>
        `;

        await enviarCorreoBrevo({
            para: email,
            nombre: usuario.nombre,
            asunto: 'Notificación: Cambio de contraseña exitoso',
            html: htmlConfirmacion
        });

        return res.status(200).json({ message: 'Contraseña cambiada exitosamente' });
    } catch (error) {
        console.error('Error en verifyCode:', error);
        return res.status(500).json({ error: 'Error al verificar el código o cambiar la contraseña' });
    }
};
