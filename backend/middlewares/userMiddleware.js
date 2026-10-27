import jwt from 'jsonwebtoken';
import { obtenerSecretoJwt } from '../config/jwt.js';

// Verifica que exista un token válido (usuario autenticado)
export const verificarToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // formato: "Bearer TOKEN"

    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado, por favor inicie sesion ' });
    }

    jwt.verify(token, obtenerSecretoJwt(), (err, decoded) => {
        if (err) {
            return res.status(403).json({ error: 'Token inválido o expirado' });
        }

        req.usuario = decoded;
        next();
    });
};

// Solo deja pasar si el usuario tiene rol admin
export const verificarAdmin = (req, res, next) => {
    if (req.usuario?.rol !== 'admin') {
        return res.status(403).json({ error: 'No tienes permisos de administrador' });
    }
    next();
};
// Deja pasar solo a los roles indicados. Ej: verificarRol('admin', 'cocina')
export const verificarRol = (...roles) => (req, res, next) => {
    if (!roles.includes(req.usuario?.rol)) {
        return res.status(403).json({ error: 'No tienes permisos para esta acción' });
    }
    next();
};