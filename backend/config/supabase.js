//variables de entorno
import dotenv from 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

//creacion de la conexion con supabase
const supabaseUrl = process.env.supabase_Url;
const supabaseKey = process.env.supabase_Key;

//variable de conexion
if (!supabaseUrl || !supabaseKey){
    console.error('❌Error: Las variables de entorno supabase_url y supabase_key son requeridas');
    process.exit(1);
}

//conexion a supabase
export const supabase = createClient(supabaseUrl, supabaseKey);

export const conectaDB = () => {
    console.log('✅Conexión a Supabase establecida correctamente.');
};