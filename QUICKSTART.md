# 🚀 Guia de Início Rápido - Solis PDV

## Instalação em 3 Passos

### 1️⃣ Pré-requisitos
Certifique-se de ter o Docker instalado:
```powershell
docker --version
docker-compose --version
```

### 2️⃣ Configurar Ambiente
Edite o arquivo `.env` e altere as senhas padrão (IMPORTANTE!):
```powershell
notepad .env
```

Altere pelo menos:
- `DB_PASSWORD`
- `JWT_SECRET`

### 3️⃣ Iniciar o Sistema
```powershell
docker-compose up -d
```

Aguarde alguns minutos para todos os serviços iniciarem.

## 📱 Acesse as Aplicações

| Aplicação | URL | Credenciais |
|-----------|-----|-------------|
| **Painel Admin** | http://localhost:8081 | admin@solis.com / admin123 |
| **Caixa PDV** | http://localhost:8080 | - |
| **API** | http://localhost:3000 | - |

## 🔍 Verificar Status

```powershell
# Ver status dos containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f solis-api
```

## ⚙️ Comandos Úteis

### Parar o sistema
```powershell
docker-compose down
```

### Reiniciar um serviço
```powershell
docker-compose restart solis-api
```

### Rebuild após mudanças
```powershell
docker-compose up -d --build
```

### Ver logs
```powershell
# Todos os serviços
docker-compose logs -f

# Apenas API
docker-compose logs -f solis-api

# Apenas Banco
docker-compose logs -f postgres
```

### Acessar o banco de dados
```powershell
docker-compose exec postgres psql -U solis_user -d solis_pdv
```

## 🛠️ Modo Desenvolvimento

Para desenvolvimento com hot reload:

```powershell
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

Isso adiciona:
- **Adminer** em http://localhost:8082 (gerenciador de banco)
- Hot reload para todas as aplicações

## 🐛 Solução de Problemas

### Container não inicia
```powershell
# Ver o erro
docker-compose logs <nome-container>

# Rebuild
docker-compose up -d --build <nome-container>
```

### Porta em uso
Edite `docker-compose.yml` e mude a porta:
```yaml
ports:
  - "3001:3000"  # Usa 3001 em vez de 3000
```

### Resetar tudo (CUIDADO: apaga dados!)
```powershell
docker-compose down -v
docker-compose up -d
```

## 📚 Próximos Passos

1. ✅ Acesse o painel admin e altere a senha padrão
2. ✅ Configure seu estabelecimento em **Configurações**
3. ✅ Cadastre produtos e categorias
4. ✅ Configure os PDVs/Caixas
5. ✅ Teste uma venda no App PWA

## 📖 Documentação Completa

Consulte o arquivo `README.md` para documentação detalhada.

## 💡 Dicas

- Use `Ctrl+C` para parar os logs em tempo real
- Sempre use `docker-compose down` antes de desligar o computador
- Faça backup regular do banco de dados
- Mantenha o `.env` seguro e não compartilhe as senhas

## 🆘 Precisa de Ajuda?

- 📧 Email: suporte@solis.com
- 📖 Docs: Veja README.md
- 🐛 Issues: Reporte problemas no repositório

---

**Desenvolvido com ❤️ pela equipe Solis**
