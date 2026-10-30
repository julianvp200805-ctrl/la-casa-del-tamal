import * as Brevo from '@getbrevo/brevo';

const remitente = () => process.env.EMAIL_USER;

export const brevoConfigurado = () => Boolean(process.env.EMAIL_USER && process.env.BREVO_API_KEY);

export const enviarCorreoBrevo = async ({ para, nombre, asunto, html }) => {
  if (!brevoConfigurado()) {
    throw new Error('El servicio de correo no está configurado (falta EMAIL_USER o BREVO_API_KEY)');
  }

  // Configuración del cliente API de Brevo
  const apiInstance = new Brevo.TransactionalEmailsApi();
  
  // Autenticación usando la variable correcta de Render: BREVO_API_KEY
  apiInstance.setApiKey(Brevo.TransactionalEmailsApiApiKeys.apiKey, process.env.BREVO_API_KEY);

  // Construcción del objeto del correo transaccional según el SDK de Brevo
  const correoTransaccional = new Brevo.SendSmtpEmail();

  correoTransaccional.subject = asunto;
  correoTransaccional.htmlContent = html;
  correoTransaccional.sender = { 
    name: process.env.EMAIL_FROM_NAME || 'La Casa del Tamal', 
    email: remitente() 
  };
  correoTransaccional.to = [
    { 
      email: para, 
      name: nombre || 'Usuario' 
    }
  ];

  try {
    // Método oficial correcto del SDK de Brevo: sendTransacEmail
    const data = await apiInstance.sendTransacEmail(correoTransaccional);
    console.log(`[Brevo API] Correo enviado exitosamente a ${para}. Message ID:`, data.body.messageId);
    return data;
  } catch (error) {
    const detalleError = error.response && error.response.body ? JSON.stringify(error.response.body) : error.message;
    console.error('[Brevo API Error]:', detalleError);
    throw new Error(`Error en el despacho mediante la API de Brevo: ${detalleError}`);
  }
};