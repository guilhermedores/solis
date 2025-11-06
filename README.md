# Solis - Sistema de PDV Multi-tenant

Documentação central do ecossistema Solis - Sistema completo de Ponto de Venda com arquitetura multi-tenant e suporte offline.

## 📦 Repositórios do Projeto

### Backend
- **[solis-api](https://github.com/guilhermedores/solis-api)** - API REST em Next.js com Prisma e PostgreSQL multi-tenant

### Frontend
- **[solis-pwa](https://github.com/guilhermedores/solis-pwa)** - Progressive Web App do PDV (React + Vite)
- **[solis-admin](https://github.com/guilhermedores/solis-admin)** - Painel administrativo web

### Agente Local
- **[solis-agente](https://github.com/guilhermedores/solis-agente)** - Agente Windows em .NET para comunicação offline

## 🏗️ Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────┐
│                      CLOUD (Multi-tenant)                    │
│  ┌────────────────┐          ┌──────────────────┐          │
│  │   solis-api    │ ←─────→  │   PostgreSQL     │          │
│  │   (Next.js)    │          │  (Multi-schema)  │          │
│  └────────┬───────┘          └──────────────────┘          │
│           │ HTTPS + X-Tenant Header                         │
└───────────┼─────────────────────────────────────────────────┘
            │
            │ Internet
            │
┌───────────▼─────────────────────────────────────────────────┐
│                    LOJA LOCAL (Offline-first)                │
│                                                               │
│  ┌────────────────┐          ┌──────────────────┐          │
│  │ solis-agente   │ ←─────→  │     SQLite       │          │
│  │   (.NET 8)     │          │   (Local DB)     │          │
│  └────────┬───────┘          └──────────────────┘          │
│           │ HTTP (localhost:5000)                           │
│           │                                                  │
│  ┌────────▼───────┐          ┌──────────────────┐          │
│  │   solis-pwa    │          │   Periféricos    │          │
│  │ (React PWA)    │ ←─────→  │ Impressora, TEF, │          │
│  │ localhost:80   │          │  SAT, Gaveta     │          │
│  └────────────────┘          └──────────────────┘          │
└───────────────────────────────────────────────────────────────┘
```

## 🚀 Stack Tecnológica

### API Backend
- Next.js 16 (App Router)
- TypeScript
- Prisma ORM
- PostgreSQL (multi-tenant com schemas)
- JWT Authentication
- Swagger/OpenAPI

### PWA Frontend
- React 18
- TypeScript
- Vite
- TailwindCSS
- Zustand (state management)
- Service Workers (offline)

### Agente Local
- .NET 8
- C#
- Entity Framework Core
- SQLite
- Serilog
- Windows Service

## 📋 Fluxo de Instalação (Técnico de Campo)

Documentação completa: [INSTALACAO_TECNICO.md](./INSTALACAO_TECNICO.md)

### Resumo Rápido

1. **Instalar PostgreSQL** (servidor central)
2. **Executar migrations** (database/init/*.sql)
3. **Instalar solis-api** (npm install && npm run dev)
4. **Instalar solis-agente** (dotnet publish + instalar-servico.ps1)
5. **Configurar agente** (token JWT via API)
6. **Acessar PWA** (navegador → http://localhost)

⏱️ Tempo estimado: **45-60 minutos**

## 🔐 Multi-tenancy

### Isolamento por Schema PostgreSQL

```sql
-- Schema público (controle)
public.tenants → tenant_id, nome, ativo, criado_em

-- Schemas isolados por tenant
tenant_demo.produtos
tenant_demo.vendas
tenant_demo.empresas
tenant_xyz.produtos
tenant_xyz.vendas
tenant_xyz.empresas
```

### Roteamento de Requisições

```typescript
// Middleware extrai tenant do header
const tenant = request.headers.get('X-Tenant')

// Prisma conecta no schema correto
const prisma = await getPrismaClient(tenant)
const produtos = await prisma.produto.findMany()
// → SELECT * FROM tenant_demo.produtos
```

## 📡 Sincronização Offline

### Outbox Pattern

```csharp
// 1. Venda criada localmente (SQLite)
var venda = new Venda { ... }
context.Vendas.Add(venda)

// 2. Mensagem adicionada ao Outbox
var outbox = new OutboxMessage {
    TipoEntidade = "Venda",
    Operacao = "CREATE",
    PayloadJson = JsonSerializer.Serialize(venda),
    EndpointApi = "/api/vendas"
}
context.OutboxMessages.Add(outbox)
context.SaveChanges()

// 3. Background Service processa fila
OutboxProcessorService → POST /api/vendas → 200 OK → Marca como enviado
```

## 🔒 Segurança

### JWT Token para Agente

```typescript
// API gera token com tenant embedado
POST /api/auth/generate-agent-token
{
  "tenantId": "demo",
  "adminKey": "admin-secret",
  "agentName": "PDV 01"
}

→ Token: eyJhbGc... (validade: 10 anos)
  Payload: { tenant: "demo", type: "agente-pdv", agentName: "PDV 01" }
```

```csharp
// Agente usa token em todas as requisições
client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}")
client.DefaultRequestHeaders.Add("X-Tenant", tenantId)
```

## 📚 Documentação Detalhada

### Arquitetura
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Visão geral do sistema
- [agente-pdv/ARCHITECTURE_DECISION.md](./agente-pdv/ARCHITECTURE_DECISION.md) - Decisões técnicas do agente
- [solis-api/HYBRID_ARCHITECTURE.md](./solis-api/HYBRID_ARCHITECTURE.md) - Arquitetura híbrida da API

### Multi-tenancy
- [TENANT_MANAGEMENT.md](./TENANT_MANAGEMENT.md) - Gestão de tenants
- [agente-pdv/CORS_MULTITENANT.md](./agente-pdv/CORS_MULTITENANT.md) - CORS multi-tenant

### Segurança
- [SECURITY_HTTPS_LOCAL.md](./SECURITY_HTTPS_LOCAL.md) - Segurança localhost
- [agente-pdv/AUTENTICACAO_JWT.md](./agente-pdv/AUTENTICACAO_JWT.md) - JWT no agente

### Patterns
- [agente-pdv/OUTBOX_PATTERN.md](./agente-pdv/OUTBOX_PATTERN.md) - Implementação do Outbox Pattern
- [solis-api/PRISMA.md](./solis-api/PRISMA.md) - Uso do Prisma com multi-tenancy

### Instalação
- [INSTALACAO_TECNICO.md](./INSTALACAO_TECNICO.md) - Guia completo para técnicos
- [QUICKSTART.md](./QUICKSTART.md) - Start rápido para desenvolvimento

## 🛠️ Desenvolvimento Local

### Pré-requisitos
- Node.js 18+
- .NET 8 SDK
- PostgreSQL 14+
- Docker (opcional)

### Setup Completo

```bash
# 1. Clonar todos os repositórios
git clone https://github.com/guilhermedores/solis-api.git
git clone https://github.com/guilhermedores/solis-pwa.git
git clone https://github.com/guilhermedores/solis-admin.git
git clone https://github.com/guilhermedores/solis-agente.git

# 2. Subir banco de dados
docker-compose up -d postgres

# 3. API
cd solis-api
npm install
npm run prisma:generate
npm run dev  # → http://localhost:3000

# 4. PWA
cd ../solis-pwa
npm install
npm run dev  # → http://localhost:5173

# 5. Agente
cd ../solis-agente
dotnet restore
dotnet run   # → http://localhost:5000

# 6. Admin (opcional)
cd ../solis-admin
npm install
npm run dev  # → http://localhost:5174
```

## 🧪 Testes

```bash
# API
cd solis-api
npm test

# PWA
cd solis-pwa
npm test

# Agente
cd solis-agente
dotnet test
```

## 📦 Deploy

### Produção (Cloud)

```bash
# API
docker build -t solis-api ./solis-api
docker run -p 3000:3000 solis-api

# Admin
docker build -t solis-admin ./solis-admin
docker run -p 80:80 solis-admin
```

### Loja (Local)

```bash
# Agente (Windows Service)
cd solis-agente
dotnet publish -c Release
.\scripts\instalar-servico.ps1

# PWA (Nginx)
cd solis-pwa
npm run build
# Copiar dist/ para C:\inetpub\wwwroot\solis
```

## 🤝 Contribuindo

Veja [CONTRIBUTING.md](./CONTRIBUTING.md) para diretrizes de contribuição.

## 📄 Licença

MIT License - veja [LICENSE](./LICENSE) para detalhes.

## 👥 Time

- **Guilherme Batista** - [guilhermedores](https://github.com/guilhermedores)

## 📞 Suporte

- Issues: Abra uma issue no repositório específico
- Email: suporte@solis.com.br
- Documentação: https://docs.solis.com.br

---

**Nota:** Este repositório contém apenas a documentação global. Para código-fonte, acesse os repositórios individuais listados acima.
