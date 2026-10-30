import { Resend } from 'resend';

// Inicializamos la instancia de Resend con la API Key configurada en Render
const resend = new Resend(process.env.RESEND_API_KEY);

export const resendConfigurado = () => Boolean(process.env.RESEND_API_KEY);

export const enviarCorreoResend = async ({ para, nombre, asunto, html }) => {
  if (!resendConfigurado()) {
    throw new Error('El servicio de correo no está configurado (falta RESEND_API_KEY)');
  }

  try {
    const data = await resend.emails.send({
      // Usamos el remitente por defecto de pruebas de Resend (o tu dominio verificado si ya lo configuras)
      from: 'La Casa del Tamal <onboarding@resend.dev>',
      to: [para],
      subject: asunto,
      html: html,
    });

    // Validamos si Resend devolvió algún error estructurado
    if (data.error) {
      console.error('[Resend Error]:', data.error);
      throw new Error(`Resend rechazó el envío: ${data.error.message}`);
    }

    console.log(`[Resend API] Correo enviado exitosamente a ${para}. ID:`, data.id);
    return data;
  } catch (error) {
    console.error('[Error interno Resend]:', error.message);
    throw new Error(`Error en el despacho mediante la API de Resend: ${error.message}`);
  }
};