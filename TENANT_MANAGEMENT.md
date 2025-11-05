# Sistema de Controle de Tenants - Solis

## Visão Geral

Sistema multi-tenant para gerenciar empresas/clientes que utilizam o Solis PDV. Cada tenant possui:

- **Identificação única** via subdomain
- **Limites configuráveis** (terminais, usuários)
- **Planos** (basic, professional, premium)
- **Tokens de vinculação** para agentes/terminais
- **Controle de ativação/desativação**

---

## 📊 Estrutura do Banco de Dados

### Schema: `public`

#### Tabela: `tenants`
```sql
id              UUID PRIMARY KEY
subdomain       VARCHAR(100) UNIQUE    -- Ex: "loja1", "demo"
company_name    VARCHAR(255)           -- Nome da empresa
cnpj            VARCHAR(18) UNIQUE     -- CNPJ (opcional)
active          BOOLEAN                -- Tenant ativo?
plan            VARCHAR(50)            -- basic, professional, premium
max_terminals   INTEGER                -- Limite de terminais
max_users       INTEGER                -- Limite de usuários
features        JSONB                  -- Features habilitadas
created_at      TIMESTAMP
updated_at      TIMESTAMP
deleted_at      TIMESTAMP              -- Soft delete
```

#### Tabela: `token_vinculacoes`
```sql
id              UUID PRIMARY KEY
tenant_id       UUID REFERENCES tenants(id)
token           VARCHAR(500) UNIQUE    -- JWT para vincular agente
nome_agente     VARCHAR(100)           -- Nome do terminal/agente
tipo            VARCHAR(50)            -- terminal, mobile, web
ativo           BOOLEAN
valido_ate      TIMESTAMP              -- Expiração do token
ultimo_uso      TIMESTAMP              -- Última vez que foi usado
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

---

## 🔌 API Endpoints

### **Listar Tenants**
```http
GET /api/tenants
Query Params:
  - active: boolean (opcional)
  - plan: string (opcional)
  - subdomain: string (opcional)
  - page: number (default: 1)
  - limit: number (default: 50)

Response:
{
  "data": [...],
  "total": 100,
  "page": 1,
  "totalPages": 2
}
```

### **Criar Tenant**
```http
POST /api/tenants
Body:
{
  "subdomain": "loja1",          // Obrigatório
  "companyName": "Loja 1 Ltda",  // Obrigatório
  "cnpj": "12.345.678/0001-90",  // Opcional
  "plan": "basic",               // Opcional (default: basic)
  "maxTerminals": 2,             // Opcional (default: 1)
  "maxUsers": 5,                 // Opcional (default: 5)
  "features": {}                 // Opcional
}

Response: 201 Created
{
  "id": "uuid",
  "subdomain": "loja1",
  ...
}
```

### **Buscar Tenant**
```http
GET /api/tenants/:id

Response: 200 OK
{
  "id": "uuid",
  "subdomain": "loja1",
  "companyName": "Loja 1 Ltda",
  "active": true,
  "plan": "basic",
  "tokenVinculacoes": [...]
}
```

### **Atualizar Tenant**
```http
PUT /api/tenants/:id
Body:
{
  "companyName": "Novo Nome",
  "plan": "premium",
  "maxTerminals": 5
}

Response: 200 OK
```

### **Desativar Tenant**
```http
DELETE /api/tenants/:id

Response: 200 OK
{
  "message": "Tenant desativado com sucesso",
  "tenant": {...}
}
```

### **Reativar Tenant**
```http
POST /api/tenants/:id/reactivate

Response: 200 OK
{
  "message": "Tenant reativado com sucesso",
  "tenant": {...}
}
```

### **Estatísticas do Tenant**
```http
GET /api/tenants/:id/stats

Response: 200 OK
{
  "totalTerminals": 3,
  "activeTerminals": 2,
  "maxTerminals": 5,
  "plan": "professional"
}
```

---

## 💻 Uso no Código

### Serviço de Tenant

```typescript
import { tenantService } from '@/lib/tenant-service'

// Criar tenant
const tenant = await tenantService.createTenant({
  subdomain: 'loja1',
  companyName: 'Loja 1 Ltda',
  cnpj: '12.345.678/0001-90',
  plan: 'basic',
  maxTerminals: 2
})

// Buscar por subdomain
const tenant = await tenantService.getTenantBySubdomain('loja1')

// Verificar se pode adicionar terminal
const canAdd = await tenantService.canAddTerminal(tenantId)

// Obter estatísticas
const stats = await tenantService.getTenantStats(tenantId)
```

---

## 🔐 Fluxo de Vinculação de Agente

1. **Admin gera token JWT** com:
   - `tenant`: subdomain do tenant
   - `agentName`: nome do terminal
   - `type`: "terminal"
   - `validade`: data de expiração

2. **Token é salvo** em `token_vinculacoes`:
   ```sql
   INSERT INTO token_vinculacoes (tenant_id, token, nome_agente, tipo, valido_ate)
   VALUES (tenant_uuid, 'eyJhbGc...', 'Terminal 01', 'terminal', '2026-12-31')
   ```

3. **Agente recebe token** e salva localmente

4. **Agente extrai tenant** do JWT e envia como `X-Tenant` header

5. **API valida** token e tenant antes de processar requests

---

## 📋 Planos e Limites

### Basic (Padrão)
- 1 terminal
- 5 usuários
- Features básicas

### Professional
- 3 terminais
- 15 usuários
- Features avançadas

### Premium
- 10+ terminais
- 50+ usuários
- Todas as features

---

## 🗄️ Isolamento Multi-Tenant

Cada tenant possui dados isolados usando **Schema Isolation**:

```
public               → Controle de tenants
tenant_demo          → Dados do tenant "demo"
tenant_loja1         → Dados do tenant "loja1"
tenant_loja2         → Dados do tenant "loja2"
```

Tabelas por tenant:
- `users` - Usuários
- `produtos` - Produtos
- `produto_precos` - Preços
- `formas_pagamento` - Formas de pagamento
- `vendas` - Vendas
- `venda_itens` - Itens de venda
- `venda_pagamentos` - Pagamentos

---

## 🚀 Inicialização

### Via SQL

```bash
psql -U postgres -d solis < database/init/01-init-multitenant.sql
psql -U postgres -d solis < database/init/02-token-vinculacao.sql
```

### Via Prisma

```bash
cd solis-api
npx prisma generate
npx prisma db push
```

---

## 📝 Notas Importantes

1. **Subdomain** deve ser único e conter apenas letras minúsculas, números e hífen
2. **CNPJ** é opcional mas deve ter 14 dígitos
3. **Soft Delete**: DELETE desativa o tenant, não remove do banco
4. **Tokens** têm validade e são validados em cada request
5. **Limites** são verificados antes de criar novos terminais/usuários

---

## 🔍 Exemplos de Queries

```typescript
// Listar tenants ativos
const result = await tenantService.listTenants({ active: true })

// Buscar por subdomain
const tenant = await tenantService.getTenantBySubdomain('demo')

// Verificar limite de terminais
if (await tenantService.canAddTerminal(tenantId)) {
  // Criar novo terminal
}

// Atualizar plano
await tenantService.updateTenant(tenantId, { 
  plan: 'premium',
  maxTerminals: 10 
})
```

---

## 📚 Arquivos Relacionados

- **Schema**: `solis-api/prisma/schema.prisma`
- **Serviço**: `solis-api/lib/tenant-service.ts`
- **API Routes**: `solis-api/app/api/tenants/**`
- **SQL Init**: `database/init/01-init-multitenant.sql`
- **SQL Tokens**: `database/init/02-token-vinculacao.sql`
