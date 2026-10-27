import { crearCodigoRecuperacion, obtenerCodigoValido, marcarCodigoComoUsado } from "../models/recuperar.js";
import { obtenerPorEmail, actualizarUsuario } from "../models/user.js";
import { enviarCorreoBrevo } from "../config/brevo.js"; // Ajusta la ruta exacta según dónde guardaste tu archivo de Brevo
import bcrypt from "bcrypt";

// POST /auth/forgot-password
// Configurar la lógica para generar y enviar el código de recuperación
export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ error: 'El correo electrónico es requerido' });
        }

        // Verificar si el usuario existe
        const { data: usuario, error: errorUsuario } = await obtenerPorEmail(email);
        if (errorUsuario || !usuario) {
            return res.status(400).json({ error: 'Usuario no encontrado' });
        }

        // Generamos el código de recuperación de 6 dígitos
        const codigo = Math.floor(100000 + Math.random() * 900000).toString();

        // Guardar el código en la base de datos
        const { error: errorCodigo } = await crearCodigoRecuperacion(usuario.id, codigo);
        if (errorCodigo) {
            return res.status(500).json({ error: 'Error al generar el código de recuperación' });
        }

        // Estructura visual elaborada para el correo de recuperación
        const htmlRecuperacion = `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff; box-shadow: 0 4px 10px rgba(0,0,0,0.05);">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Sistema de Gestión Interna</p>
            </div>
            
            <h3 style="color: #333333; font-size: 18px; margin-top: 0;">Solicitud de recuperación de contraseña</h3>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Hemos recibido una solicitud para restablecer la contraseña de tu cuenta. Utiliza el siguiente código de verificación de 6 dígitos de seguridad:</p>
            
            <div style="text-align: center; margin: 30px 0;">
                <div style="display: inline-block; background-color: #f4faf2; border: 2px dashed #39a900; border-radius: 8px; padding: 15px 40px; letter-spacing: 6px;">
                    <span style="color: #39a900; font-size: 36px; font-weight: bold; font-family: 'Courier New', Courier, monospace;">${codigo}</span>
                </div>
            </div>
            
            <div style="background-color: #fff9e6; border-left: 4px solid #ffcc00; padding: 15px; margin: 25px 0; border-radius: 4px;">
                <p style="margin: 0; font-size: 13px; color: #666666; line-height: 1.5;">
                    <strong>Seguridad importante:</strong><br>
                    • Este código tiene un tiempo de validez limitado de <strong>15 minutos</strong>.<br>
                    • Por motivos de seguridad estricta, <strong>nunca compartas este código</strong> con nadie. Ningún miembro del equipo administrativo te lo solicitará.
                </p>
            </div>
            
            <p style="color: #7f8c8d; font-size: 13px; line-height: 1.5; margin-bottom: 0;">Si tú no solicitaste este cambio, puedes ignorar este correo de forma segura. Tu contraseña actual permanecerá a salvo sin alteraciones.</p>
            
            <div style="margin-top: 35px; padding-top: 20px; border-top: 1px solid #f4f4f4; text-align: center;">
                <p style="color: #95a5a6; font-size: 12px; margin: 0;">&copy; ${new Date().getFullYear()} La Casa del Tamal. Todos los derechos reservados.</p>
            </div>
        </div>
        `;

        // Envío del correo usando Brevo
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
// Cambiar contraseña y verificar el código de recuperación
export const verifyCode = async (req, res) => {
    try {
        const { email, codigo, newPassword } = req.body;
        
        // Verificamos entradas obligatorias
        if (!email || !codigo || !newPassword) {
            return res.status(400).json({ error: "Todos los campos son requeridos: email, código y nueva contraseña" });
        }

        // Verificamos si el usuario existe
        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Verificamos si el código es válido en la BD
        const { data: codigoValido } = await obtenerCodigoValido(usuario.id, codigo);
        if (!codigoValido) {
            return res.status(400).json({ error: 'Código de recuperación inválido o expirado' });
        }

        // Encriptamos la nueva contraseña de forma segura
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Actualizamos la contraseña del usuario en la base de datos
        const { error: errorUpdate } = await actualizarUsuario(
            usuario.id, { contrasena: hashedPassword }
        );
        if (errorUpdate) throw errorUpdate;

        // Marcar el código como usado para que no se vuelva a explotar
        await marcarCodigoComoUsado(codigoValido.id);

        // Estructura visual de confirmación exitosa del cambio de credenciales
        const htmlConfirmacion = `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 550px; margin: 0 auto; padding: 30px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff; box-shadow: 0 4px 10px rgba(0,0,0,0.05);">
            <div style="text-align: center; border-bottom: 2px solid #f4f4f4; padding-bottom: 20px; margin-bottom: 25px;">
                <h2 style="color: #2c3e50; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;">La Casa del Tamal</h2>
                <p style="color: #7f8c8d; margin: 5px 0 0 0; font-size: 14px;">Confirmación de Seguridad</p>
            </div>
            
            <div style="text-align: center; margin: 20px 0;">
                <div style="display: inline-block; background-color: #eafaf1; border-radius: 50%; padding: 15px; width: 40px; height: 40px; line-height: 40px; text-align: center;">
                    <span style="color: #2ecc71; font-size: 32px; font-weight: bold;">✓</span>
                </div>
            </div>

            <h3 style="color: #2c3e50; font-size: 18px; text-align: center; margin-top: 10px;">¡Contraseña modificada exitosamente!</h3>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Hola <strong>${usuario.nombre || 'Usuario'}</strong>,</p>
            <p style="color: #555555; font-size: 15px; line-height: 1.6;">Te informamos formalmente que las credenciales de tu cuenta del sistema han sido actualizadas con éxito. A partir de ahora podrás iniciar sesión con tu nueva contraseña.</p>
            
            <div style="background-color: #f9f9f9; padding: 15px; border-left: 4px solid #39a900; margin: 25px 0; border-radius: 4px;">
                <p style="margin: 0; font-size: 13px; color: #e74c3c; line-height: 1.5;">
                    <strong>¿No fuiste tú?</strong><br>
                    Si no solicitaste este cambio ni modificaste tu perfil, ponte en contacto inmediato con el Administrador General del sistema para bloquear el acceso preventivamente.
                </p>
            </div>
            
            <p style="color: #555555; font-size: 14px; margin-top: 25px;">Gracias por tu atención a la seguridad de la plataforma.</p>
            
            <div style="margin-top: 35px; padding-top: 20px; border-top: 1px solid #f4f4f4; text-align: center;">
                <p style="color: #95a5a6; font-size: 12px; margin: 0;">&copy; ${new Date().getFullYear()} La Casa del Tamal. Todos los derechos reservados.</p>
            </div>
        </div>
        `;

        // Enviamos el correo de éxito usando Brevo
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
