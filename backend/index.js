import express from 'express';
import dotenv from 'dotenv';
import { conectaDB,supabase } from './config/supabase.js';
import userRoutes from './routes/user.js';
import user2Routes from './routes/user2.js';
import menuRoutes from './routes/menu.js';
import pedidoRoutes from './routes/pedido.js';
import tipoProductoRoutes from './routes/tipo_producto.js';


//cargas variables de entorno
dotenv.config();
conectaDB();


const app = express();

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

//configuramos el puerto
const PORT = 3000;

//Ponemos a escuchar el servidor
app.listen(PORT,()=>{
    console.log(`Servidor corriendo en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});