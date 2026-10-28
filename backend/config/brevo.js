import nodemailer from 'nodemailer';

const remitente = () => process.env.EMAIL_USER;

export const brevoConfigurado = () => Boolean(process.env.EMAIL_USER && process.env.EMAIL_PASS);

export const enviarCorreoBrevo = async ({ para, nombre, asunto, html }) => {
  if (!brevoConfigurado()) {
    throw new Error('El servicio de correo no está configurado (falta EMAIL_USER o EMAIL_PASS)');
  }

  // Transporte SMTP nativo de Google utilizando tu contraseña de aplicación
  const transportador = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  const opcionesCorreo = {
    from: `"${process.env.EMAIL_FROM_NAME || 'La Casa del Tamal'}" <${remitente()}>`,
    to: para,
    subject: asunto,
    html: html,
  };

  try {
    await transportador.sendMail(opcionesCorreo);
  } catch (error) {
    console.error('Error en el transporte de Gmail:', error);
    throw new Error('No se pudo despachar el correo electrónico de seguridad: ' + error.message);
  }
};
