import { crearCodigoRecuperacion, obtenerCodigoValido, marcarCodigoComoUsado } from "../models/recuperar.js";
import { obtenerPorEmail, actualizarUsuario } from "../models/user.js";
import { enviarCorreoResend } from "../config/resend.js"; // <-- Importamos Resend
import bcrypt from "bcrypt";

// POST /auth/forgot-password
export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ error: 'El correo electrónico es requerido' });
        }

        const { data: usuario, error: errorUsuario } = await obtenerPorEmail(email);
        if (errorUsuario || !usuario) {
            return res.status(400).json({ error: 'Usuario no encontrado' });
        }

        const codigo = Math.floor(100000 + Math.random() * 900000).toString();

        const { error: errorCodigo } = await crearCodigoRecuperacion(usuario.id, codigo);
        if (errorCodigo) {
            return res.status(500).json({ error: 'Error al generar el código de recuperación en Supabase' });
        }

        const htmlRecuperacion = `
        <div style="font-family: sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Sistema de Gestión Interna</p>
            </div>
            <h3>Solicitud de recuperación de contraseña</h3>
            <p>Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p>Utiliza el siguiente código de verificación de 6 dígitos de seguridad:</p>
            <div style="text-align: center; margin: 30px 0;">
                <div style="display: inline-block; background-color: #f4faf2; border: 2px dashed #39a900; padding: 15px 40px; letter-spacing: 6px;">
                    <span style="color: #39a900; font-size: 36px; font-weight: bold;">${codigo}</span>
                </div>
            </div>
            <p style="color: #666666; font-size: 13px;">Este código tiene un tiempo de validez limitado de 15 minutos.</p>
        </div>
        `;

        // Despacho vía Resend (sin silenciar errores)
        await enviarCorreoResend({
            para: email,
            nombre: usuario.nombre,
            asunto: `Código de recuperación: ${codigo}`,
            html: htmlRecuperacion
        });

        return res.status(200).json({ 
            message: 'Proceso de recuperación iniciado con éxito',
            info: 'Verifica tu bandeja de entrada o solicita asistencia del administrador'
        });

    } catch (error) {
        console.error('Error en forgotPassword:', error.message);
        return res.status(500).json({ 
            error: error.message || 'Error interno en la solicitud de restablecimiento' 
        });
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
        <div style="font-family: sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Confirmación de Seguridad</p>
            </div>
            <h3 style="text-align: center;">¡Contraseña modificada exitosamente!</h3>
            <p>Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p>Te informamos que las credenciales de tu cuenta han sido actualizadas con éxito.</p>
        </div>
        `;

        try {
            await enviarCorreoResend({
                para: email,
                nombre: usuario.nombre,
                asunto: 'Notificación: Cambio de contraseña exitoso',
                html: htmlConfirmacion
            });
        } catch (_) {
            // El correo de confirmación final puede fallar silenciosamente sin impedir el cambio de contraseña
        }

        return res.status(200).json({ message: 'Contraseña cambiada exitosamente' });
    } catch (error) {
        console.error('Error en verifyCode:', error);
        return res.status(500).json({ error: 'Error al verificar el código o cambiar la contraseña' });
    }
};