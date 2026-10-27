// CORRECCIÓN: Se cambia la importación para traer todos los módulos nombrados de la SDK
import * as brevo from '@getbrevo/brevo';

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

  // 1. Configuración de la API Key usando el cliente global de la SDK
  const defaultClient = brevo.ApiClient.instance;
  const apiKey = defaultClient.authentications['api-key'];
  apiKey.apiKey = process.env.BREVO_API_KEY;

  // 2. Instanciación de la API de correos transaccionales
  const apiInstance = new brevo.TransactionalEmailsApi();
  const sendSmtpEmail = new brevo.SendSmtpEmail();

  // 3. Estructuración del objeto de envío
  sendSmtpEmail.subject = asunto;
  sendSmtpEmail.htmlContent = html;
  sendSmtpEmail.sender = { 
    name: process.env.EMAIL_FROM_NAME || 'La Casa del Tamal', 
    email: remitente() 
  };
  sendSmtpEmail.to = [{ 
    email: para, 
    name: nombre || para 
  }];

  // 4. Ejecución del envío
  await apiInstance.sendTransacEmail(sendSmtpEmail);
};
