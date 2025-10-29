# 🏪 Sistema Solis PDV

Sistema completo de Ponto de Venda (PDV/POS) com arquitetura moderna, containerizado com Docker.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Desenvolvimento](#desenvolvimento)
- [Variáveis de Ambiente](#variáveis-de-ambiente)

## 🎯 Visão Geral

O Sistema Solis PDV é uma solução completa para gestão de vendas, estoque e operações de caixa. O sistema é composto por:

- **API Nuvem**: Backend principal em Node.js
- **Agente PDV**: Serviço .NET para gerenciamento de periféricos (impressoras, gaveta, TEF, SAT/MFe)
- **App PWA**: Aplicação Progressive Web App para operação de caixa
- **App Admin**: Aplicação web para gestão administrativa
- **Banco de Dados**: PostgreSQL para persistência de dados

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                         NUVEM                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐       ┌───────────┐       ┌──────────┐      │
│  │   Auth   │──────▶│ API Nuvem │──────▶│  Banco   │      │
│  └──────────┘       └─────┬─────┘       │  (Postgres) │   │
│                           │             └──────────┘      │
│                           │                               │
│                           ▼                               │
│                    ┌────────────┐                         │
│                    │  App Admin │                         │
│                    │   (Web)    │                         │
│                    └────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ HTTPS / Sync
                           │
┌─────────────────────────────────────────────────────────────┐
│                    CAIXA / DISPOSITIVO                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐         ┌──────────────┐                │
│  │   App PWA    │◀───────▶│  Agente PDV  │                │
│  │ (IndexedDB)  │         │    (.NET)     │                │
│  └──────────────┘         └───────┬──────┘                │
│                                    │                        │
│                    ┌───────────────┴──────────────┐        │
│                    ▼               ▼              ▼        │
│              ┌─────────┐    ┌─────────┐    ┌─────────┐   │
│              │   TEF   │    │ Fiscal  │    │Impressora│  │
│              └─────────┘    │SAT/MFe│    │  Gaveta  │  │
│                             └─────────┘    └─────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Tecnologias

### Backend
- **Node.js** 18+ (API Nuvem)
- **.NET** 8.0 (Agente PDV)
- **PostgreSQL** 15 (Banco de Dados)

### Frontend
- **React** / Vue / Angular (configurável)
- **PWA** (Progressive Web App)
- **Nginx** (Servidor web)

### DevOps
- **Docker** & **Docker Compose**
- **Git**

## 📁 Estrutura do Projeto

```
solis/
├── solis-api/              # API Backend (Node.js)
│   ├── src/
│   ├── Dockerfile
│   └── package.json
│
├── agente-pdv/             # Agente PDV (.NET)
│   ├── src/
│   ├── Dockerfile
│   └── Solis.AgentePDV.csproj
│
├── app-pwa/                # App de Caixa (React/PWA)
│   ├── src/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
│
├── app-admin/              # App Administrativo (React)
│   ├── src/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
│
├── database/               # Configurações do banco
│   └── init/
│       └── 01-init-database.sql
│
├── volumes/                # Volumes persistentes
│   ├── db-data/
│   ├── api-logs/
│   ├── pdv-logs/
│   └── fiscal-data/
│
├── docker-compose.yml      # Orquestração dos serviços
├── .env                    # Variáveis de ambiente
└── README.md              # Este arquivo
```

## ⚙️ Pré-requisitos

Antes de começar, você precisa ter instalado:

- [Docker](https://www.docker.com/get-started) (versão 20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versão 2.0 ou superior)
- [Git](https://git-scm.com/)

### Verificar instalação:

```powershell
docker --version
docker-compose --version
git --version
```

## 🚀 Instalação

### 1. Clone o repositório

```powershell
git clone <url-do-repositorio>
cd solis
```

### 2. Configure as variáveis de ambiente

Edite o arquivo `.env` com suas configurações:

```powershell
notepad .env
```

**IMPORTANTE**: Altere as senhas e chaves secretas antes de colocar em produção!

### 3. Inicie os serviços

```powershell
docker-compose up -d
```

### 4. Verifique o status dos containers

```powershell
docker-compose ps
```

Todos os serviços devem estar com status "Up".

## 📱 Uso

Após iniciar os serviços, você pode acessar:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **App Admin** | http://localhost:8081 | Painel administrativo |
| **App PDV** | http://localhost:8080 | Aplicação de caixa |
| **API Nuvem** | http://localhost:3000 | API Backend |
| **Agente PDV** | http://localhost:5000 | Serviço de periféricos |
| **Banco de Dados** | localhost:5432 | PostgreSQL |

### Credenciais Padrão

- **Email**: admin@solis.com
- **Senha**: admin123

**⚠️ IMPORTANTE**: Altere a senha padrão após o primeiro login!

## 🔧 Desenvolvimento

### Logs dos serviços

Ver logs de todos os serviços:
```powershell
docker-compose logs -f
```

Ver logs de um serviço específico:
```powershell
docker-compose logs -f solis-api
docker-compose logs -f agente-pdv
docker-compose logs -f app-pwa
docker-compose logs -f app-admin
```

### Reiniciar um serviço

```powershell
docker-compose restart solis-api
```

### Parar todos os serviços

```powershell
docker-compose down
```

### Parar e remover volumes (dados serão perdidos!)

```powershell
docker-compose down -v
```

### Rebuild de um serviço específico

```powershell
docker-compose up -d --build solis-api
```

### Acessar o terminal de um container

```powershell
docker-compose exec solis-api sh
docker-compose exec postgres psql -U solis_user -d solis_pdv
```

### Executar migrations manualmente

```powershell
docker-compose exec solis-api npm run migrate
```

## 🔐 Variáveis de Ambiente

As principais variáveis de ambiente estão no arquivo `.env`:

### Banco de Dados
- `DB_NAME`: Nome do banco de dados
- `DB_USER`: Usuário do banco
- `DB_PASSWORD`: Senha do banco

### API
- `JWT_SECRET`: Chave secreta para JWT (mínimo 32 caracteres)
- `API_KEY`: Chave para integrações externas
- `NODE_ENV`: Ambiente (development/production)

### Agente PDV
- `SYNC_INTERVAL`: Intervalo de sincronização em segundos
- `IMPRESSORA_TERMICA_PORT`: Porta da impressora térmica
- `TEF_ENABLED`: Habilitar TEF (true/false)
- `SAT_ENABLED`: Habilitar SAT/MFe (true/false)

## 📊 Banco de Dados

### Estrutura Principal

O banco de dados inclui as seguintes tabelas principais:

- **usuarios**: Usuários do sistema
- **estabelecimentos**: Lojas/Filiais
- **pdvs**: Caixas/Terminais
- **produtos**: Cadastro de produtos
- **categorias**: Categorias de produtos
- **vendas**: Cupons fiscais
- **venda_itens**: Itens das vendas
- **formas_pagamento**: Formas de pagamento
- **venda_pagamentos**: Pagamentos das vendas
- **sync_log**: Log de sincronização
- **perifericos_config**: Configuração de periféricos

### Backup do Banco

```powershell
# Criar backup
docker-compose exec postgres pg_dump -U solis_user solis_pdv > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U solis_user solis_pdv < backup.sql
```

## 🧪 Testes

### Testar conexão com a API

```powershell
curl http://localhost:3000/health
```

### Testar conexão com o Agente PDV

```powershell
curl http://localhost:5000/health
```

## 🐛 Troubleshooting

### Problema: Container não inicia

```powershell
# Ver logs detalhados
docker-compose logs <nome-do-servico>

# Rebuild do container
docker-compose up -d --build <nome-do-servico>
```

### Problema: Banco de dados não conecta

```powershell
# Verificar se o container está rodando
docker-compose ps postgres

# Testar conexão direta
docker-compose exec postgres psql -U solis_user -d solis_pdv
```

### Problema: Porta já está em uso

Edite o arquivo `docker-compose.yml` e altere a porta do serviço:

```yaml
ports:
  - "3001:3000"  # Use 3001 em vez de 3000
```

## 📝 Roadmap

- [ ] Implementar autenticação OAuth2
- [ ] Adicionar suporte a múltiplas moedas
- [ ] Integração com e-commerce
- [ ] Dashboard de analytics
- [ ] App mobile nativo (React Native)
- [ ] Suporte a impressoras fiscais
- [ ] Integração completa com TEF

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📧 Contato

Para dúvidas e suporte: suporte@solis.com

---

Desenvolvido com ❤️ pela equipe Solis
