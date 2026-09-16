import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import { conectaDB, supabase } from './config/supabase.js';
import userRoutes from './routes/user.js';
import user2Routes from './routes/user2.js';
import menuRoutes from './routes/menu.js';
import pedidoRoutes from './routes/pedido.js';
import tipoProductoRoutes from './routes/tipo_producto.js';
import productoRoutes from './routes/productos.js';
import chatRoutes from './routes/chatRoutes.js'; // Importa las rutas de chat

//cargas variables de entorno
dotenv.config();
conectaDB();


const app = express();

// Habilita CORS para que Flutter Web (Chrome) pueda llamar al backend.
// Sin esto, el navegador bloquea la petición y da "Failed to fetch".
app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

//creamos la ruta
app.get('/',(req,res)=>{
    res.json({
        message:'Bienvenido a mi API con Supabase!',
        Estado:'en linea',
        Version:'1.0.0'
    });
});
//importamos las rutas
app.use('/user', userRoutes);
app.use('/user2', user2Routes);
app.use('/menu', menuRoutes);
app.use('/pedido', pedidoRoutes);
app.use('/tipoProducto', tipoProductoRoutes);
app.use('/producto', productoRoutes);
app.use("/api/chat", chatRoutes);
//configuramos el puerto
const PORT = 3000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});