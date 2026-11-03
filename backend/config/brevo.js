const API_URL = 'https://api.brevo.com/v3/smtp/email';

export const brevoConfigurado = () => Boolean(process.env.BREVO_API_KEY);

export const enviarCorreoBrevo = async ({ para, asunto, html }) => {
  if (!brevoConfigurado()) {
    throw new Error('Brevo no está configurado (falta BREVO_API_KEY)');
  }

  const re = await fetch(API_URL, {
    method: 'POST',
    headers: {
      'api-key': process.env.BREVO_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      sender: {
        name: 'La Casa del Tamal',
        email: process.env.EMAIL_FROM ?? 'julianvp200805@gmail.com',
      },
      to: [{ email: para }],
      subject: asunto,
      htmlContent: html,
    }),
  });

  const data = await re.json().catch(() => ({}));

  if (!re.ok) {
    console.error('[Brevo Error]:', re.status, data);
    throw new Error(`Brevo rechazó el envío: ${data.message || re.status}`);
  }

  console.log(`[Brevo API] Correo enviado a ${para}. ID:`, data.messageId);
  return data;
};
