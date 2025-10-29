# 🏗️ Arquitetura Técnica - Sistema Solis PDV

## Visão Geral da Arquitetura

O Sistema Solis PDV foi projetado com uma arquitetura moderna, escalável e desacoplada, utilizando containers Docker para facilitar o deployment e manutenção.

## Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAMADA DE NUVEM                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                              │
│  │  Auth Service│                                              │
│  └──────┬───────┘                                              │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────┐        ┌─────────────────┐                  │
│  │  API Nuvem   │───────▶│   PostgreSQL    │                  │
│  │  (Node.js)   │        │   (Database)    │                  │
│  └──────┬───────┘        └─────────────────┘                  │
│         │                                                       │
│         ├──────────────┬────────────────────┐                 │
│         ▼              ▼                    ▼                  │
│  ┌────────────┐ ┌────────────┐      ┌────────────┐           │
│  │  Banco     │ │   Cache    │      │   Fila     │           │
│  │  (CRUD)    │ │  (Sesão)   │      │ (Arquivo)  │           │
│  └────────────┘ └────────────┘      └────────────┘           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ HTTPS / REST API
                           │ Bearer Token (JWT)
                           │
┌─────────────────────────────────────────────────────────────────┐
│                     CAMADA ADMINISTRATIVA                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │           App Admin (React/Vue/Angular)                  │ │
│  │                                                          │ │
│  │  • Gestão de Produtos                                   │ │
│  │  • Gestão de Usuários                                   │ │
│  │  • Relatórios e Dashboard                               │ │
│  │  • Configurações do Sistema                             │ │
│  │  • Gestão de Estabelecimentos                           │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ HTTPS / REST API
                           │
┌─────────────────────────────────────────────────────────────────┐
│                    CAMADA DE PONTO DE VENDA                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │         App PWA (Progressive Web App)                   │  │
│  │                                                         │  │
│  │  • Operação de Caixa                                   │  │
│  │  • Consulta de Produtos                                │  │
│  │  • Emissão de Cupons                                   │  │
│  │  • Modo Offline (IndexedDB)                            │  │
│  │  • Sincronização Automática                            │  │
│  └─────────────────┬───────────────────────────────────────┘  │
│                    │                                            │
│                    │ HTTP (Localhost)                           │
│                    ▼                                            │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │          Agente PDV (.NET Core)                         │  │
│  │                                                         │  │
│  │  • Gerenciamento de Periféricos                        │  │
│  │  • Impressoras Térmicas                                │  │
│  │  • Impressoras Fiscais (SAT/MFe)                       │  │
│  │  • Gaveta de Dinheiro                                  │  │
│  │  • Integração TEF                                      │  │
│  │  • Balança                                             │  │
│  │  • Sincronização com Nuvem                             │  │
│  └─────────────┬───────────────────────────────────────────┘  │
│                │                                                │
│                ├──────────┬──────────┬──────────┬──────────┐  │
│                ▼          ▼          ▼          ▼          ▼  │
│         ┌──────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────┐│
│         │Impressora│ │ Gaveta │ │  SAT/  │ │  TEF   │ │Bal.││
│         │ Térmica  │ │Dinheiro│ │  MFe   │ │        │ │    ││
│         └──────────┘ └────────┘ └────────┘ └────────┘ └────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Componentes do Sistema

### 1. API Nuvem (Backend)

**Tecnologia**: Node.js 18+ com Express

**Responsabilidades**:
- Autenticação e autorização (JWT)
- CRUD de todas as entidades
- Lógica de negócio centralizada
- Gestão de sincronização
- API RESTful
- Validação de dados

**Endpoints Principais**:
```
/api/v1/auth/*           - Autenticação
/api/v1/produtos/*       - CRUD de produtos
/api/v1/vendas/*         - CRUD de vendas
/api/v1/usuarios/*       - CRUD de usuários
/api/v1/estabelecimentos/* - CRUD de estabelecimentos
/api/v1/sync/*           - Sincronização
/api/v1/relatorios/*     - Relatórios
```

**Porta**: 3000

### 2. Agente PDV (Serviço Local)

**Tecnologia**: .NET 8.0 (C#)

**Responsabilidades**:
- Comunicação com periféricos USB/Serial
- Gerenciamento de impressoras
- Integração com SAT Fiscal/MFe
- Integração com TEF (PinPad)
- Sincronização offline-first
- Gestão de fila de documentos fiscais

**Porta**: 5000

**Drivers Suportados**:
- Impressoras ESC/POS
- SAT Dimep, Bematech, Sweda
- TEF Sitef, PayGo
- Gavetas padrão 5V/12V

### 3. App PWA (Aplicação de Caixa)

**Tecnologia**: React 18+ (ou Vue/Angular)

**Responsabilidades**:
- Interface de operação do caixa
- Cadastro rápido de vendas
- Consulta de produtos
- Processamento de pagamentos
- Modo offline com IndexedDB
- Service Worker para PWA

**Porta**: 8080 (produção via Nginx)

**Features**:
- ✅ Offline-first
- ✅ Instalável (PWA)
- ✅ Responsivo
- ✅ Atalhos de teclado
- ✅ Busca rápida de produtos
- ✅ Múltiplas formas de pagamento

### 4. App Admin (Painel Administrativo)

**Tecnologia**: React 18+ (ou Vue/Angular)

**Responsabilidades**:
- Gestão completa do sistema
- Cadastros de produtos, usuários, etc.
- Relatórios e dashboards
- Configurações gerais
- Gestão de múltiplos estabelecimentos

**Porta**: 8081 (produção via Nginx)

**Módulos**:
- Dashboard
- Produtos e Categorias
- Vendas e Cupons
- Financeiro
- Relatórios
- Configurações
- Usuários e Permissões

### 5. Banco de Dados

**Tecnologia**: PostgreSQL 15

**Características**:
- ACID compliant
- Suporte a JSON (JSONB)
- Full-text search
- Triggers para auditoria
- Índices otimizados

**Porta**: 5432

**Backup**:
- Automático via pg_dump
- Retenção configurável
- Point-in-time recovery

## Fluxo de Dados

### Fluxo de Venda

```
1. Usuário inicia venda no App PWA
   ↓
2. Busca produtos (cache local se offline)
   ↓
3. Adiciona itens ao carrinho
   ↓
4. Seleciona forma de pagamento
   ↓
5. Se TEF → Agente PDV → PinPad
   ↓
6. Finaliza venda
   ↓
7. Agente PDV → Impressora (cupom)
   ↓
8. Se online → Sincroniza com API
   ↓
9. Se offline → Guarda na fila local
   ↓
10. Quando online → Sincroniza pendências
```

### Fluxo de Sincronização

```
PDV (Offline)
   ↓
Fila Local (IndexedDB)
   ↓
Verifica Conexão
   ↓
Se Online → Agente PDV
   ↓
Agente PDV → API Nuvem
   ↓
API valida e persiste
   ↓
Retorna confirmação
   ↓
Marca como sincronizado
```

## Segurança

### Autenticação
- JWT (JSON Web Tokens)
- Refresh tokens
- Expiração configurável
- Bcrypt para senhas (salt rounds: 10)

### Autorização
- RBAC (Role-Based Access Control)
- Perfis: ADMIN, GERENTE, OPERADOR, SUPORTE
- Permissões granulares

### Comunicação
- HTTPS obrigatório em produção
- CORS configurável
- Rate limiting
- Helmet.js para headers de segurança

### Dados
- Senhas hasheadas (bcrypt)
- Dados sensíveis criptografados
- Logs de auditoria
- Backup automático

## Escalabilidade

### Horizontal
- API stateless (permite múltiplas instâncias)
- Load balancer (Nginx)
- Cache distribuído (futuro: Redis)

### Vertical
- PostgreSQL otimizado
- Índices estratégicos
- Query optimization
- Connection pooling

### Offline-First
- IndexedDB no cliente
- Sincronização inteligente
- Resolução de conflitos
- Fila de retry

## Monitoramento

### Logs
- Estruturados (JSON)
- Níveis: ERROR, WARN, INFO, DEBUG
- Rotação automática
- Agregação centralizada (futuro)

### Métricas
- Health checks em todos os serviços
- Tempo de resposta
- Taxa de erro
- Uso de recursos

### Alertas (Futuro)
- Slack/Email
- Serviços down
- Erros críticos
- Capacidade do sistema

## Performance

### Cache
- Produtos frequentes em memória
- Sessões de usuário
- Consultas pesadas cacheadas

### Otimizações
- Lazy loading de imagens
- Compressão gzip/brotli
- Minificação de assets
- CDN para estáticos (produção)

### Banco de Dados
- Índices em colunas chave
- Vacuum automático
- Analyze periódico
- Particionamento (futuro)

## Deployment

### Desenvolvimento
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### Produção
```bash
docker-compose up -d
```

### CI/CD (Futuro)
- GitHub Actions
- Testes automatizados
- Build automático
- Deploy automático

## Tecnologias Complementares

### Atual
- Docker & Docker Compose
- Nginx
- PostgreSQL
- Node.js
- .NET Core

### Futuro
- Redis (cache distribuído)
- RabbitMQ (fila de mensagens)
- Elasticsearch (logs)
- Grafana (métricas)
- Kubernetes (orquestração)

## Boas Práticas

### Código
- ✅ Clean Code
- ✅ SOLID principles
- ✅ DRY (Don't Repeat Yourself)
- ✅ Comentários significativos
- ✅ Versionamento semântico

### Git
- ✅ Commits atômicos
- ✅ Mensagens descritivas
- ✅ Branch strategy (Git Flow)
- ✅ Pull requests obrigatórios
- ✅ Code review

### Docker
- ✅ Multi-stage builds
- ✅ Usuários não-root
- ✅ Health checks
- ✅ Volumes para dados persistentes
- ✅ Networks isoladas

---

**Última atualização**: Outubro 2025  
**Versão**: 1.0.0