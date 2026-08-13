import { obtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario,eliminarUsuario } from "../models/user.js";

//obtener todos los usuarios 
export const getUsuarios = async (req, res) => {
    try {
        const { data, error } = await obtenerUsuarios();
        if (error) {
            return res.status(500).json({
                error: 'Error al obtener los usuarios'
            });
        }
        return res.status(200).json({
            usuarios: data
        });
    } catch (error) {
        console.error('Error al obtener los usuarios:', error);
        return res.status(500).json({
            error: 'Error al obtener los usuarios'
        });
    }
};

// usuario por id
export const getobtenerUsuarioPorId = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerUsuarioPorId(id);
        if (error||!data) {
            return res.status(500).json({
                error: 'Error al obtener el usuario'
            });
        }
        return res.status(200).json({
            usuario: data
        });
    } catch (error) {
        console.error('Error al obtener el usuario:', error);
        return res.status(500).json({
            error: 'Error al obtener el usuario'
        });
    }
};

//Actualizar un usuario
export const putActualizarUsuario = async (req, res) => {
    const {id} = req.params;
    const {nombre, email, contrasena, rol} = req.body;
//Validacion de los datos
    if (!nombre || !email || !contrasena || !rol) {
        return res.status(400).json({error: "Faltan datos obligatorios"});
    }
try {
    const {data, error} = await actualizarUsuario( nombre, email, contrasena, rol);
    if (error) {
        return res.status(500).json({error: "Error al actualizar el usuario"});
    }
    return res.status(200).json({
        message: "Usuario actualizado correctamente",
        usuario: data
    });
} catch (error) {
    return res.status(500).json({mensaje: "Error del servidor", error: error.message});
}
};
//Eliminar un usuario
export const deleteEliminarUsuario = async (req, res) => {
    const {id} = req.params;
    try{
        const {data, error }= await eliminarUsuario(id);
        if (error) {
            return res.status(400).json({error: "Error al eliminar el usuario", error: error.message});
        }   
        //si el dato no tiene datos vacios
        if (!data||data.length === 0) {
            return res.status(404).json({error: "Usuario no encontrado", error: error.message});
        }
        return res.status(200).json({
            message: "Usuario eliminado correctamente",
            usuario: data
        });
}catch (error) {
    return res.status(500).json({error: "Error del servidor", error: error.message});
    } 
};