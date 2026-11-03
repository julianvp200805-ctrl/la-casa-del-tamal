import nodemailer from 'nodemailer';
import { enviarCorreoResend } from './resend.js';

// Dos formas de despacho, elegidas según las variables de entorno:
//  1) Gmail SMTP (recomendada sin dominio): requiere EMAIL_USER y la
//     contraseña de aplicación en EMAIL_APP_PASSWORD o EMAIL_PASS
//     (16 caracteres, se crea en https://myaccount.google.com/apppasswords
//     con verificación en 2 pasos activada). Llega a CUALQUIER destinatario.
//  2) Resend (fallback): con la key de pruebas solo envía al correo
//     dueño de la cuenta; sirve mientras no configures Gmail.
const claveSmtp = () => process.env.EMAIL_APP_PASSWORD ?? process.env.EMAIL_PASS;

export const hayGmailConfigurado = () =>
    Boolean(process.env.EMAIL_USER && claveSmtp());

let transporte = null;
const obtenerTransporte = () => {
    if (!transporte) {
        transporte = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: claveSmtp(),
            },
            // Solo para máquinas con proxy corporativo que reemplaza el
            // certificado TLS (caso de desarrollo local). En producción
            // (Render) NO se debe poner EMAIL_TLS_INSECURE.
            tls: process.env.EMAIL_TLS_INSECURE === '1'
                ? { rejectUnauthorized: false }
                : undefined,
        });
    }
    return transporte;
};

export const enviarCorreo = async ({ para, asunto, html }) => {
    if (hayGmailConfigurado()) {
        try {
            const info = await obtenerTransporte().sendMail({
                from: `"La Casa del Tamal" <${process.env.EMAIL_USER}>`,
                to: para,
                subject: asunto,
                html,
            });
            console.log(`[Gmail SMTP] Correo enviado a ${para}. ID:`, info.messageId);
            return info;
        } catch (error) {
            console.error('[Gmail SMTP Error]:', error.message);
            throw new Error(`No se pudo enviar el correo por Gmail: ${error.message}`);
        }
    }
    // Sin Gmail configurado se intenta con Resend (solo destinatarios
    // permitidos por la key de pruebas).
    return enviarCorreoResend({ para, asunto, html });
};
