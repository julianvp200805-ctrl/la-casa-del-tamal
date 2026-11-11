import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import {
    crearUsuarioEmpleado,
    obtenerPorEmail,
    obtenerPorDocumento
} from '../models/user.js';
// LÍNEA CONFIRMADA: Importación exacta coincidiendo con backend/models/codigosRegistro.js
import { reclamarCodigo, liberarCodigo, registrarUsoCodigo } from '../models/codigosRegistro.js';
import { obtenerSecretoJwt } from '../config/jwt.js';

// Por este registro público solo se crean empleados de cocina o mesero.
// El admin se crea a mano en la base de datos.
const ROLES_EMPLEADO = ['cocina', 'mesero'];
const TIPOS_DOCUMENTO = ['C.C.', 'C.E.', 'T.I.', 'Pasaporte'];
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// Formato de los códigos que genera el admin (controllers/codigosRegistro.js):
// TAM-XXXX-XX con el alfabeto sin I, O, 0 y 1.
const CODIGO_RE = /^TAM-[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}-[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{2}$/;

// Hash falso para tardar lo mismo cuando el correo no existe
const HASH_FALSO = bcrypt.hashSync('hash-de-relleno', 10);

const fechaValida = (texto) => {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(texto)) return false;
    const f = new Date(`${texto}T00:00:00`);
    return !Number.isNaN(f.getTime()) && f <= new Date() && f.getFullYear() >= 1900;
};

// POST /auth/registro
// body: { nombre, tipo_documento, numero_documento, email, fecha_nacimiento,
//         contrasena, codigo }
// Sin un código de registro vigente (generado por el admin) nadie se registra.
// El rol NO lo elige el empleado: lo impone el código (rol_asignado).
export const registro = async (req, res) => {
    let codigoId = null;
    try {
        const b = req.body ?? {};
        const nombre = String(b.nombre ?? '').trim();
        const tipo_documento = String(b.tipo_documento ?? '').trim();
        const numero_documento = String(b.numero_documento ?? '').trim();
        const email = String(b.email ?? '').trim().toLowerCase();
        const fecha_nacimiento = String(b.fecha_nacimiento ?? '').trim();
        const contrasena = String(b.contrasena ?? '');
        const codigo = String(b.codigo ?? '').trim().toUpperCase();

        if (nombre.length < 3 || nombre.length > 100) return res.status(400).json({ error: 'Escribe tu nombre completo' });
        if (!TIPOS_DOCUMENTO.includes(tipo_documento)) return res.status(400).json({ error: 'Tipo de documento no válido' });
        if (!/^[0-9]{5,20}$/.test(numero_documento)) return res.status(400).json({ error: 'El número de documento solo acepta números (entre 5 y 20 dígitos)' });
        if (!EMAIL_RE.test(email)) return res.status(400).json({ error: 'Correo no válido' });
        if (!fechaValida(fecha_nacimiento)) return res.status(400).json({ error: 'Fecha de nacimiento no válida (usa el formato 2005-12-31)' });
        if (contrasena.length < 8 || contrasena.length > 72) return res.status(400).json({ error: 'La contraseña debe tener entre 8 y 72 caracteres' });
        if (!CODIGO_RE.test(codigo)) return res.status(400).json({ error: 'El código de registro no tiene un formato válido (TAM-XXXX-XX)' });

        // 1) Se consume el código primero (atómico): si no sirve, no se sigue.
        const { data: reclamado, error: errorCodigo } = await reclamarCodigo(codigo);
        if (errorCodigo) return res.status(500).json({ error: 'No se pudo validar el código' });
        if (!reclamado) return res.status(400).json({ error: 'Código de registro inválido, vencido o ya usado' });
        codigoId = reclamado.id;

        const rol = String(reclamado.rol_asignado ?? '').toLowerCase();
        if (!ROLES_EMPLEADO.includes(rol)) {
            await liberarCodigo(codigoId);
            return res.status(500).json({ error: 'El código no tiene un rol válido asignado' });
        }

        // 2) Duplicados (si hay, el código se devuelve para no gastarlo)
        const { data: porCorreo } = await obtenerPorEmail(email);
        if (porCorreo) {
            await liberarCodigo(codigoId);
            return res.status(409).json({ error: 'Ese correo ya está registrado' });
        }
        const { data: porDocumento, error: errorDoc } = await obtenerPorDocumento(tipo_documento, numero_documento);
        if (errorDoc) {
            await liberarCodigo(codigoId);
            console.error('Error al buscar documento:', errorDoc);
            return res.status(500).json({ error: `No se pudo validar el documento: ${errorDoc.message}` });
        }
        if (porDocumento) {
            await liberarCodigo(codigoId);
            return res.status(409).json({ error: 'Ese documento ya está registrado' });
        }

        // 3) Crear el usuario
        const hash = await bcrypt.hash(contrasena, 10);
        const { data: usuario, error } = await crearUsuarioEmpleado({
            nombre, email, contrasena: hash, rol, tipo_documento, numero_documento, fecha_nacimiento
        });
        if (error || !usuario) {
            await liberarCodigo(codigoId);
            console.error('Error al crear empleado:', error);
            const duplicado = error?.code === '23505';
            return res.status(duplicado ? 409 : 500).json({
                error: duplicado ? 'Ese correo o documento ya está registrado' : `No se pudo crear la cuenta: ${error?.message}`
            });
        }

        await registrarUsoCodigo(codigoId, { nombre, email, rol });
        return res.status(201).json({ message: 'Cuenta creada. Ya puedes iniciar sesión.', usuario });
    } catch (error) {
        if (codigoId) await liberarCodigo(codigoId);
        console.error('Error en registro:', error);
        return res.status(500).json({ error: error.message });
    }
};

// POST /auth/login  body: { email, contrasena }
export const login = async (req, res) => {
    try {
        const email = String(req.body?.email ?? '').trim();
        const contrasena = String(req.body?.contrasena ?? '');
        if (!email || !contrasena) {
            return res.status(400).json({ error: 'Todos los campos son requeridos : email y contraseña' });
        }

        // El correo se busca tal cual y, si no aparece, en minúsculas
        // (los teclados de celular ponen la primera letra en mayúscula).
        let { data: usuario } = await obtenerPorEmail(email);
        if (!usuario && email !== email.toLowerCase()) {
            ({ data: usuario } = await obtenerPorEmail(email.toLowerCase()));
        }

        const hash = typeof usuario?.contrasena === 'string' ? usuario.contrasena : HASH_FALSO;
        const coincide = await bcrypt.compare(contrasena, hash);
        // Mismo mensaje si el correo no existe o la contraseña falla (no revela cuál)
        if (!usuario || !coincide) {
            return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
        }

        const secreto = obtenerSecretoJwt();
        if (!secreto) {
            console.error('Falta JWT_SECRET en el .env');
            return res.status(500).json({ error: 'El servidor no está configurado correctamente' });
        }

        // Sesión de 12 h para cubrir un turno completo
        const token = jwt.sign(
            { id: usuario.id, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol },
            secreto,
            { expiresIn: '12h' }
        );

        return res.status(200).json({
            message: 'Login exitoso',
            token,
            usuario: { id: usuario.id, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol }
        });
    } catch (error) {
        console.error('Error en login:', error);
        return res.status(500).json({ error: error.message });
    }
};
