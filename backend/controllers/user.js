import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { crearUsuario, obtenerPorEmail } from '../models/user.js';

//registro
export const registro = async (req, res)=> {
    try {
        const {nombre, email, contrasena}= req.body;
        //validamos los datos
        if (!nombre || !email || !contrasena) {
            return res.status (400).json({
                error: 'faltan usuarios'
            });
        }
        //verificamos el email si ya existe
        const {data:usuarioExiste}= await obtenerPorEmail(email);
        if (usuarioExiste) {
            return res.status(400).json({
                error: 'el email ya existe'
            });
        }
        //encriptar la contraseña
        const hashedContrasena = await bcrypt.hash(contrasena, 10);
        //rol por defecto
        const rolPorDefecto = 'usuario';
        //guardar en la base de datos
        const {data, error} = await crearUsuario (
            nombre, 
            email,
            hashedContrasena,
            rolPorDefecto
        );
        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }
        return res.status(201).json({
            message: 'Usuario registrado con éxito',
            usuario: {
                id: data[0].id,
                nombre: data[0].nombre,
                email: data[0].email,
                rol: data[0].rol
            }
        });
    } catch (error) {
        console.error('Error en registrado:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};

//crear el login
export const login = async(req,res)=>{
    try {
       const {email, contrasena}  = req.body;
       //validar que los campos esten llenos 
       if (!email || ! contrasena){
        return res.status(400).json({
            error: 'Todos los campos son requeridos : email y contraseña'
        });
       }
       //validamos si existe el correo 

       const {data: usuario} = await obtenerPorEmail(email)
       if(!usuario){
        return res.status(400).json({
            error: 'el email no esta registrado'
       });
    }
    //verificar la contraseña
    const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!contrasenaValida){
        return res.status(400).json({
            error: 'contraseña incorrecta'
        });
    }
    //generar el token JWT
    const token = jwt.sign(
        {
            id: usuario.id,
            nombre: usuario.nombre,
            email: usuario.email,
            rol: usuario.rol,
        },
        process.env.JWT_SECRET,
        {expiresIn: '1h'}
    );
    return res.status(200).json({
        message: 'Login exitoso',
        token
    });
    } catch (error){
        console.error('Error en login:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};