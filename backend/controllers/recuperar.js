import { crearCodigoRecuperacion, obtenerCodigoValido, marcarCodigoComoUsado } from "../models/recuperar.js";
import { obtenerPorEmail, actualizarUsuario } from "../models/user.js";
import bcrypt from "bcrypt";
import nodemailer from "nodemailer";

//configuramos el transporte de nodemailer

const transporter=nodemailer.createTransport({
    service:"gmail",
    auth:{
        user:process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});
//configurar la logica para enviar el correo de recuperacion
export const forgotPassword = async (req, res)=>{
    try{
        const {email}=req.body;
        if (!email){
            return res.status(400).json({error: 'el correo electronico es requerido'});
        }
        //verificar si el usuario
        const { data: usuario, error: errorUsuario}= await obtenerPorEmail(email);
        if(errorUsuario || !usuario){
            return res.status(400).json({error: 'Usuario no encontrado'});
        }
        //generamos los codigos de recuperacion 
        const codigo=Math.floor(100000 + Math.random() * 900000).toString();
        //guardar el codigo a la base de datos
        const {error:errorCodigo}=await crearCodigoRecuperacion(usuario.id, codigo);
        if (errorCodigo){
            return res.status(500).json({ error:'error al generar el codigo de recuperacion'});
        }
        //creamos por el email del codigo
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: email,
            subject:`tu codigo de recuperación es: ${codigo}`,
            html:`
            <h2>Recuperacion de contraseña</h2>
            <p>Hola ${usuario.nombre || 'usuario'},</p>
            <p>tu codigo de recuperacion es:</p>
            <h1 style= " color: #39a900; font-size: 36px;"> ${codigo}</h1>
            <p>Este codigo es valido por 15 minutos. si no solicitaste este codigo, porfavor ignora este correo.</p>
            <p>El equipo de soporte</p>
            <p>Gracias</p>
            <p>No compartas este codigo con nadie</p>
            `
        });
        return res.status(200).json({message:'codigo de recuperacion enviado al correo'});
    }catch (error){
        console.error('error en fogortPassword:', error);
        return res.status(500).json({error: 'error al enviar codigo de recuperacion'});
    }
}
//cambiar contraseña y verificar el codigo de recuperacion 
export const verifyCode= async(req, res)=>{
    try{
        const {email,codigo,newPassword}=req.body;
        //verificamos entradas
        if(!email|| !codigo|| !newPassword){
            return res.status(400).json({error:"Todos los campos son requeridos"})
        }
        //Verificamos si el usuario existe
        const {data: usuario} = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(404).json({error: 'Usuario no encontrado'});
        }
        //Verificamos si el código es válido
        const {data: codigoValido} = await obtenerCodigoValido(usuario.id, codigo);
        if (!codigoValido) {
            return res.status(400).json({error: 'Código de recuperación inválido o expirado'});
        }
        //Encriptamos la nueva contraseña
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        //Actualizamos la contraseña del usuario en la base de datos
        const { error: errorUpdate } = await actualizarUsuario(
            usuario.id, { contrasena: hashedPassword }
        );
        if (errorUpdate) throw errorUpdate;
        //Marcar el código como usado
        await marcarCodigoComoUsado(codigoValido.id);
        //Enviamos una respuesta de éxito
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Contraseña cambiada exitosamente',
            html: `
            <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px;">
                <h2 style="color: #333;">Contraseña cambiada exitosamente</h2>
                <p>Hola ${usuario.nombre || 'usuario'},</p>
                <p>Te informamos que tu contraseña ha sido cambiada exitosamente.</p>
                <div style="background-color: #f9f9f9; padding: 15px; border-left: 4px solid #39a900; margin: 20px;">
                    <p style="margin: 0; font-size: 14px; color: #555;">Si no realizaste este cambio, por favor contacta a nuestro soporte inmediatamente.</p>
                </div>
                <p style="color: #555; font-size: 14px; margin-top: 30px;">Gracias por confiar en nosotros.</p>
            </div>
            `
        });
        return res.status(200).json({message: 'Contraseña cambiada exitosamente'});

    }catch (error){
        console.error('Error en verifyCode:', error);
        return res.status(500).json({error: 'Error al verificar el código o cambiar la contraseña'});
    }
}