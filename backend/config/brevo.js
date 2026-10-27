import { BrevoClient } from '@getbrevo/brevo';

// Brevo solo ENVÍA el correo; el código lo genera este backend.
// Variables del .env: BREVO_API_KEY (obligatoria) y, opcionales,
// BREVO_SENDER_EMAIL (si falta se usa EMAIL_USER) y EMAIL_FROM_NAME.
// El correo remitente debe estar verificado en tu cuenta de Brevo.
const remitente = () => process.env.BREVO_SENDER_EMAIL || process.env.EMAIL_USER;

export const brevoConfigurado = () => Boolean(process.env.BREVO_API_KEY && remitente());

export const enviarCorreoBrevo = async ({ para, nombre, asunto, html }) => {
  if (!brevoConfigurado()) {
    throw new Error('Brevo no está configurado (falta BREVO_API_KEY o el correo remitente)');
  }
  const brevo = new BrevoClient({ apiKey: process.env.BREVO_API_KEY });
  await brevo.transactionalEmails.sendTransacEmail({
    subject: asunto,
    sender: { name: process.env.EMAIL_FROM_NAME || 'La Casa del Tamal', email: remitente() },
    to: [{ email: para, name: nombre || para }],
    htmlContent: html
  });
};