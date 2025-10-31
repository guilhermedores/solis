-- ============================================================================
-- SCRIPT DE PRODUTOS DE EXEMPLO
-- Insere produtos variados para testes no Agente PDV
-- Estrutura: Produtos + ProdutoPrecos
-- ============================================================================

-- Produtos de Alimentação
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440001', '7891000100103', 'PROD001', 'COCA-COLA 2L', 'Refrigerante Coca-Cola 2 Litros', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440002', '7891000100110', 'PROD002', 'PEPSI 2L', 'Refrigerante Pepsi 2 Litros', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440003', '7891000100127', 'PROD003', 'GUARANÁ ANTARCTICA 2L', 'Refrigerante Guaraná Antarctica 2 Litros', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 8.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 7.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 7.90, 1, datetime('now'), datetime('now'));

-- Produtos de Padaria
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440004', '7891000100134', 'PROD004', 'PÃO FRANCÊS', 'Pão Francês Tradicional', 'KG', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440005', '7891000100141', 'PROD005', 'PÃO DE FORMA', 'Pão de Forma Integral 500g', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440006', '7891000100158', 'PROD006', 'BOLO DE CHOCOLATE', 'Bolo de Chocolate Caseiro', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 12.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 8.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', 18.90, 1, datetime('now'), datetime('now'));

-- Produtos de Limpeza
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440007', '7891000100165', 'PROD007', 'DETERGENTE YPÊ', 'Detergente Líquido Ypê 500ml', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440008', '7891000100172', 'PROD008', 'SABÃO EM PÓ OMO', 'Sabão em Pó Omo 1kg', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440009', '7891000100189', 'PROD009', 'ÁGUA SANITÁRIA', 'Água Sanitária 1L', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440007', 2.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440008', 15.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440009', 3.90, 1, datetime('now'), datetime('now'));

-- Produtos de Higiene
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440010', '7891000100196', 'PROD010', 'SABONETE DOVE', 'Sabonete Dove Original 90g', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440011', '7891000100202', 'PROD011', 'SHAMPOO SEDA', 'Shampoo Seda Recarga Natural 325ml', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440012', '7891000100219', 'PROD012', 'PASTA DE DENTE COLGATE', 'Creme Dental Colgate Total 12 90g', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440010', 3.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', 12.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440012', 7.90, 1, datetime('now'), datetime('now'));

-- Produtos de Mercearia
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440013', '7891000100226', 'PROD013', 'ARROZ TIO JOÃO 5KG', 'Arroz Branco Tipo 1 Tio João 5kg', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440014', '7891000100233', 'PROD014', 'FEIJÃO CARIOCA 1KG', 'Feijão Carioca Tipo 1 1kg', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440015', '7891000100240', 'PROD015', 'AÇÚCAR UNIÃO 1KG', 'Açúcar Cristal União 1kg', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', 28.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', 9.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440015', 4.90, 1, datetime('now'), datetime('now'));

-- Produtos de Laticínios
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440016', '7891000100257', 'PROD016', 'LEITE INTEGRAL 1L', 'Leite Integral UHT 1L', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440017', '7891000100264', 'PROD017', 'QUEIJO MUSSARELA', 'Queijo Mussarela Fatiado 200g', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440018', '7891000100271', 'PROD018', 'IOGURTE NATURAL', 'Iogurte Natural Integral 170g', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440016', 5.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440017', 18.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440018', 3.50, 1, datetime('now'), datetime('now'));

-- Produtos de Bebidas
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440019', '7891000100288', 'PROD019', 'SUCO DEL VALLE 1L', 'Suco Del Valle Laranja 1L', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440020', '7891000100295', 'PROD020', 'ÁGUA MINERAL 500ML', 'Água Mineral sem Gás 500ml', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440021', '7891000100301', 'PROD021', 'CHÁ MATTE LEÃO', 'Chá Matte Leão Natural 1.5L', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440019', 6.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440020', 2.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440021', 5.50, 1, datetime('now'), datetime('now'));

-- Produtos de Snacks
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440022', '7891000100318', 'PROD022', 'DORITOS 150G', 'Salgadinho Doritos Queijo Nacho 150g', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440023', '7891000100325', 'PROD023', 'RUFFLES 100G', 'Batata Frita Ruffles Original 100g', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440024', '7891000100332', 'PROD024', 'CHOCOLATE LACTA', 'Chocolate ao Leite Lacta 90g', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440022', 8.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440023', 7.50, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440024', 5.90, 1, datetime('now'), datetime('now'));

-- Produtos Diversos
INSERT INTO Produtos (Id, CodigoBarras, CodigoInterno, Nome, Descricao, UnidadeMedida, Ativo, CriadoEm, AtualizadoEm)
VALUES 
('550e8400-e29b-41d4-a716-446655440025', '7891000100349', 'PROD025', 'PILHA DURACELL AA', 'Pilha Alcalina Duracell AA 4 unidades', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440026', '7891000100356', 'PROD026', 'PAPEL HIGIÊNICO', 'Papel Higiênico Folha Dupla 4 rolos', 'UN', 1, datetime('now'), datetime('now')),
('550e8400-e29b-41d4-a716-446655440027', '7891000100363', 'PROD027', 'GUARDANAPO', 'Guardanapo de Papel 50 folhas', 'UN', 1, datetime('now'), datetime('now'));

INSERT INTO ProdutoPrecos (Id, ProdutoId, PrecoVenda, Ativo, CriadoEm, AtualizadoEm)
VALUES
('650e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440025', 18.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440026', 12.90, 1, datetime('now'), datetime('now')),
('650e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440027', 3.50, 1, datetime('now'), datetime('now'));

SELECT 'Produtos inseridos com sucesso!' as Resultado;
SELECT COUNT(*) as TotalProdutos FROM Produtos;
SELECT COUNT(*) as TotalPrecos FROM ProdutoPrecos;
