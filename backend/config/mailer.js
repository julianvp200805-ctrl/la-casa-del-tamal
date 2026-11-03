import { enviarCorreoBrevo, brevoConfigurado } from './brevo.js';
import { enviarCorreoResend } from './resend.js';

// Orden de despacho según las variables de entorno:
//  1) Brevo (API HTTP): llega a cualquier destinatario. Es la vía que
//     funciona en Render, donde los puertos SMTP están bloqueados.
//  2) Resend (fallback): con la key de pruebas solo envía al correo del
//     dueño de la cuenta; útil para desarrollo local.
//
// Gmail SMTP ya no se intenta: Render (plan gratis) bloquea la salida
// por los puertos 465/587 y el envío termina en "Connection timeout".
export const enviarCorreo = async ({ para, asunto, html }) => {
    if (brevoConfigurado()) {
        return enviarCorreoBrevo({ para, asunto, html });
    }
    return enviarCorreoResend({ para, asunto, html });
};
