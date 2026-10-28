import * as brevo from '@getbrevo/brevo';

const remitente = () => process.env.BREVO_SENDER_EMAIL || process.env.EMAIL_USER;

export const brevoConfigurado = () => Boolean(process.env.BREVO_API_KEY && remitente());

export const enviarCorreoBrevo = async ({ para, nombre, asunto, html }) => {
  if (!brevoConfigurado()) {
    throw new Error('Brevo no está configurado (falta BREVO_API_KEY o el correo remitente)');
  }

  // CORRECCIÓN DE LA SDK: Inicialización de credenciales usando el cliente global de Brevo
  const defaultClient = brevo.ApiClient.instance;
  const apiKey = defaultClient.authentications['api-key'];
  apiKey.apiKey = process.env.BREVO_API_KEY;

  // Instanciación de la API de correos transaccionales y el objeto de envío
  const apiInstance = new brevo.TransactionalEmailsApi();
  const sendSmtpEmail = new brevo.SendSmtpEmail();

  // Mapeo de parámetros y propiedades nativas
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

  // Ejecución del envío transaccional en producción
  await apiInstance.sendTransacEmail(sendSmtpEmail);
};
