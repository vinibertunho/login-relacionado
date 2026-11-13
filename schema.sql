-- ============================================================================
-- SCRIPT DE BANCO DE DADOS RELACIONAL (V4.1)
-- Banco: meu_banco_db (PostgreSQL)
-- ============================================================================

-- 1. Criação da tabela de usuários
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL
);

-- 2. Criação da tabela de Grupos de Produtos (Nova Tabela)
CREATE TABLE IF NOT EXISTS grupos (
    id SERIAL PRIMARY KEY,
    descricao_grupo VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Criação da tabela de Produtos com a Chave Estrangeira 'grupo_id'
-- A cláusula REFERENCES estabelece o relacionamento N:1 com a tabela grupos.
-- ON DELETE SET NULL garante que, se um grupo for excluído, os produtos vinculados não
-- serão apagados, apenas perderão o vínculo.
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    peso NUMERIC(10, 2) NOT NULL CHECK (peso >= 0),
    preco NUMERIC(10, 2) NOT NULL CHECK (preco >= 0),
    grupo_id INT REFERENCES grupos(id) ON DELETE SET NULL
);

-- 4. Inserção do usuário administrador inicial (Senha padrão: 123456)
-- EXPLICAÇÃO DA CLÁUSULA 'ON CONFLICT (email) DO NOTHING':
-- Garante a IDEMPOTÊNCIA do script. Se a carga SQL for executada múltiplas vezes no
-- banco, o PostgreSQL ignora a inserção caso o e-mail já esteja cadastrado (devido à restrição
-- UNIQUE), evitando erros de duplicação.
INSERT INTO usuarios (nome, email, senha)
VALUES ('Administrador', 'admin@email.com', '$2b$10$f.hXaJvcMfcvERmNT0U.YO4TesI9mZCoIxzy/hsioGoDcHS2IWFVy')
ON CONFLICT (email) DO NOTHING;

-- 5. Inserção de grupos padrão para testes iniciais
INSERT INTO grupos (descricao_grupo) VALUES
    ('Eletrônicos'),
    ('Periféricos'),
    ('Acessórios')
ON CONFLICT (descricao_grupo) DO NOTHING;

-- 6. Inserção de produtos vinculados aos grupos
-- O SELECT encontra o ID real do grupo, sem supor que ele seja 1, 2 ou 3.
-- WHERE NOT EXISTS evita duplicar os exemplos ao executar novamente.
INSERT INTO produtos (nome_produto, peso, preco, grupo_id)
SELECT 'Monitor UltraWide 29', 4.20, 1299.00, id FROM grupos
WHERE descricao_grupo = 'Eletrônicos'
AND NOT EXISTS (SELECT 1 FROM produtos WHERE nome_produto = 'Monitor UltraWide 29');

INSERT INTO produtos (nome_produto, peso, preco, grupo_id)
SELECT 'Teclado Mecânico RGB', 0.95, 280.00, id FROM grupos
WHERE descricao_grupo = 'Periféricos'
AND NOT EXISTS (SELECT 1 FROM produtos WHERE nome_produto = 'Teclado Mecânico RGB');

INSERT INTO produtos (nome_produto, peso, preco, grupo_id)
SELECT 'Mousepad Extra Large', 0.40, 65.00, id FROM grupos
WHERE descricao_grupo = 'Acessórios'
AND NOT EXISTS (SELECT 1 FROM produtos WHERE nome_produto = 'Mousepad Extra Large');

-- ============================================================================
-- OPCIONAL (3.1): Migração apenas para quem já possui a tabela 'produtos' da V3
-- Descomente os comandos abaixo caso esteja migrando um banco existente da V3:
-- ============================================================================
-- CREATE TABLE IF NOT EXISTS grupos (
--     id SERIAL PRIMARY KEY,
--     descricao_grupo VARCHAR(100) NOT NULL UNIQUE
-- );
--
-- ALTER TABLE produtos
-- ADD COLUMN IF NOT EXISTS grupo_id INTEGER REFERENCES grupos(id) ON DELETE SET NULL;
