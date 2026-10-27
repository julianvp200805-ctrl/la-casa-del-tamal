import bcrypt from 'bcrypt';
import { obtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario, eliminarUsuario } from "../models/user.js";

const ROLES_VALIDOS = ['admin', 'mesero', 'cocina', 'usuario'];

//obtener todos los usuarios 
export const getUsuarios = async (req, res) => {
    try {
        const { data, error } = await obtenerUsuarios();
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los usuarios' });
        }
        return res.status(200).json({ usuarios: data });
    } catch (error) {
        console.error('Error al obtener los usuarios:', error);
        return res.status(500).json({ error: 'Error al obtener los usuarios' });
    }
};

// usuario por id
export const getobtenerUsuarioPorId = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerUsuarioPorId(id);
        if (error || !data) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        return res.status(200).json({ usuario: data });
    } catch (error) {
        console.error('Error al obtener el usuario:', error);
        return res.status(500).json({ error: 'Error al obtener el usuario' });
    }
};

//Actualizar un usuario (aquí el admin puede cambiar el rol de alguien)
export const putActualizarUsuario = async (req, res) => {
    const { id } = req.params;
    const { nombre, email, contrasena, rol } = req.body;
    if (!nombre || !email || !rol) {
        return res.status(400).json({ error: "Faltan datos obligatorios" });
    }
    if (!ROLES_VALIDOS.includes(rol)) {
        return res.status(400).json({ error: `Rol no válido. Usa: ${ROLES_VALIDOS.join(', ')}` });
    }
    try {
        const campos = { nombre, email, rol };
        // Solo si mandan una nueva contraseña se encripta y se incluye
        if (contrasena) {
            if (String(contrasena).length < 8) {
                return res.status(400).json({ error: 'La contraseña debe tener mínimo 8 caracteres' });
            }
            campos.contrasena = await bcrypt.hash(contrasena, 10);
        }

        const { data, error } = await actualizarUsuario(id, campos);
        if (error) {
            return res.status(500).json({ error: "Error al actualizar el usuario" });
        }
        return res.status(200).json({ message: "Usuario actualizado correctamente", usuario: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

//Eliminar un usuario
export const deleteEliminarUsuario = async (req, res) => {
    const { id } = req.params;
    // El admin no puede borrar su propia cuenta por accidente
    if (String(id) === String(req.usuario?.id)) {
        return res.status(400).json({ error: "No puedes eliminar tu propia cuenta" });
    }
    try {
        const { data, error } = await eliminarUsuario(id);
        if (error) {
            return res.status(400).json({ error: "Error al eliminar el usuario" });
        }
        if (!data || data.length === 0) {
            return res.status(404).json({ error: "Usuario no encontrado" });
        }
        return res.status(200).json({ message: "Usuario eliminado correctamente", usuario: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};