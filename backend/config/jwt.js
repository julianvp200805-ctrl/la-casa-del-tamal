// Secreto del JWT. En Windows las variables de entorno no distinguen
// mayúsculas, pero en Linux sí: se aceptan ambos nombres.
export const obtenerSecretoJwt = () => process.env.JWT_SECRET ?? process.env.jwt_secret;