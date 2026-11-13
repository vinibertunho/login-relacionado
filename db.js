import pg from 'pg';
const { Pool } = pg;

// Configuração das credenciais de acesso ao PostgreSQL local
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'meu_bd_licao',
  password: 'amods',
  port: 7777, // Porta do PostgreSQL no laboratório SENAI
});

export default pool;
