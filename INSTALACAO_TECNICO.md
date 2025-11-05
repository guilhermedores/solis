# 🔧 Guia de Instalação: Técnico em Campo

## Cenário: Primeira Instalação em Cliente

**Personagens:**
- **Técnico**: Vai ao estabelecimento instalar o sistema
- **Admin do Sistema**: Gestor que administra os tenants (pode ser remoto)
- **Cliente**: Dono da loja/estabelecimento

**Equipamento no cliente:**
- 1 PC Windows (para caixa)
- Impressora térmica USB
- Gaveta de dinheiro
- Leitor de código de barras (opcional)

---

## 📋 Processo de Instalação - Passo a Passo

### **ANTES de ir ao cliente: (ADMIN - REMOTO)**

#### 1. Admin cria o tenant no sistema

```bash
# Via painel admin: https://admin.solis.com.br
# Ou via API:

POST https://api.solis.com.br/api/tenants
{
  "subdomain": "loja-exemplo",
  "companyName": "Loja Exemplo Ltda",
  "cnpj": "12.345.678/0001-90",
  "plan": "basic",
  "maxTerminals": 2
}

# Resposta:
{
  "id": "uuid-do-tenant",
  "subdomain": "loja-exemplo",
  ...
}
```

#### 2. Admin gera token de vinculação

```bash
POST https://api.solis.com.br/api/tenants/{id}/tokens
{
  "nomeAgente": "Terminal Caixa 01",
  "tipo": "terminal",
  "validoAte": "2026-12-31T23:59:59Z"
}

# Resposta:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZW5hbnQiOiJsb2phLWV4ZW1wbG8iLCJhZ2VudE5hbWUiOiJUZXJtaW5hbCBDYWl4YSAwMSIsInR5cGUiOiJ0ZXJtaW5hbCIsInZhbGlkYWRlIjoiMjAyNi0xMi0zMVQyMzo1OTo1OVoifQ.abc123...",
  "tenantId": "loja-exemplo",
  "nomeAgente": "Terminal Caixa 01"
}
```

#### 3. Admin envia token ao técnico

```
Via WhatsApp, email, ou sistema interno:

📱 "Guilherme, token para instalação da Loja Exemplo:

Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Tenant: loja-exemplo
Terminal: Caixa 01
Validade: 31/12/2026"
```

---

### **NO CLIENTE: (TÉCNICO - PRESENCIAL)**

#### **ETAPA 1: Preparar o Hardware** ⏱️ 15 min

```
✅ Ligar o PC do caixa
✅ Conectar impressora térmica via USB
✅ Conectar gaveta na impressora
✅ Conectar leitor de código de barras via USB
✅ Testar impressora (imprimir teste)
```

#### **ETAPA 2: Instalar o Agente PDV** ⏱️ 10 min

##### Opção A: Via Instalador (Recomendado)

```powershell
# 1. Executar instalador
.\SolisAgentePDV-Setup-v1.0.0.exe

# O instalador faz automaticamente:
# - Copia arquivos para C:\Program Files\Solis\AgentePDV\
# - Instala como serviço Windows
# - Configura inicialização automática
# - Abre firewall (porta 5000)
```

##### Opção B: Via Manual

```powershell
# 1. Copiar binários
xcopy /E /I "\\servidor\Solis\AgentePDV" "C:\Solis\AgentePDV"

# 2. Instalar serviço
cd C:\Solis\AgentePDV
powershell -ExecutionPolicy Bypass -File .\scripts\instalar-servico.ps1

# 3. Iniciar serviço
net start Solis.AgentePDV
```

##### Verificar instalação:

```powershell
# Testar se agente está respondendo
Invoke-RestMethod http://localhost:5000/api/health
```

**Saída esperada:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "configurado": false
}
```

#### **ETAPA 3: Configurar Impressora** ⏱️ 5 min

```powershell
# Verificar se impressora foi detectada
Invoke-RestMethod http://localhost:5000/api/impressoras

# Resposta esperada:
{
  "impressoras": [
    {
      "nome": "Elgin i9",
      "porta": "USB001",
      "status": "conectada",
      "modelo": "ESC/POS"
    }
  ]
}
```

Se necessário configurar manualmente, via Postman ou curl:
```bash
POST http://localhost:5000/api/impressoras/configurar
{
  "porta": "USB001",
  "modelo": "ELGIN_I9",
  "velocidade": 9600
}
```

#### **ETAPA 4: Acessar o PWA** ⏱️ 2 min

```
1. Abrir Chrome ou Edge (recomendado)
2. Acessar: https://pdv.solis.com.br
3. Browser detecta PWA e mostra prompt de instalação
4. Clicar em "Instalar Solis PDV"
5. Ícone aparece na área de trabalho e menu iniciar
```

**Prompt de instalação:**
```
┌─────────────────────────────────────┐
│  🌐 Chrome                          │
│                                     │
│  Instalar Solis PDV?                │
│                                     │
│  Este site pode ser instalado      │
│  como aplicativo.                   │
│                                     │
│  [Instalar]  [Agora não]           │
└─────────────────────────────────────┘
```

#### **ETAPA 5: Configurar o Token** ⏱️ 3 min

```
1. Abrir o PWA (duplo clique no ícone da área de trabalho)
2. PWA detecta que agente não está configurado
3. Redireciona automaticamente para /configurar-agente
```

**Tela exibida:**
```
┌───────────────────────────────────────────────┐
│  🔧 Configuração Inicial                      │
│                                               │
│  Status: 🟢 Agente Local: CONECTADO          │
│                                               │
│  ℹ️  Cole o token fornecido pelo             │
│      administrador do sistema                 │
│                                               │
│  ┌─────────────────────────────────────────┐ │
│  │ Token:                                  │ │
│  │ [                                    ]  │ │
│  │ (Cole aqui o token recebido)           │ │
│  └─────────────────────────────────────────┘ │
│                                               │
│           [Configurar Agente]                 │
└───────────────────────────────────────────────┘
```

**Ações do técnico:**
```
1. Abrir WhatsApp/email no celular
2. Copiar o token enviado pelo admin
3. Colar no campo "Token"
4. Clicar em "Configurar Agente"
```

**Sistema processa (automático):**
```
PWA → POST http://localhost:5000/api/config/setup
{
  "token": "eyJhbGc...",
  "apiBaseUrl": "https://api.solis.com.br"
}
         ↓
Agente valida o token:
  1. Decodifica JWT
  2. Valida assinatura
  3. Verifica expiração
  4. Extrai: tenant="loja-exemplo", nome="Terminal Caixa 01"
         ↓
Salva no banco local (SQLite):
  C:\ProgramData\Solis\data\agente-pdv.db
         ↓
Responde: { 
  success: true, 
  tenantId: "loja-exemplo",
  nomeAgente: "Terminal Caixa 01"
}
```

**Mensagem de sucesso:**
```
✅ Agente configurado com sucesso!
   Tenant: loja-exemplo
   Nome: Terminal Caixa 01

   Redirecionando para o sistema...
```

#### **ETAPA 6: Sincronização Inicial** ⏱️ 5 min

```
Sistema redireciona para /dashboard
         ↓
Dashboard carrega e inicia sincronização automática
```

**Progresso na tela:**
```
┌───────────────────────────────────┐
│  Sincronizando dados...           │
│                                   │
│  ✅ Produtos: 150 itens          │
│  ✅ Formas de pagamento: 4       │
│  ✅ Configurações                │
│                                   │
│  [████████████████] 100%          │
└───────────────────────────────────┘
```

**O que é sincronizado:**
1. Produtos do tenant (com preços e estoque)
2. Formas de pagamento configuradas
3. Configurações gerais do estabelecimento
4. Categorias de produtos

#### **ETAPA 7: Teste de Venda** ⏱️ 5 min

```
Técnico faz venda de teste:

1. Clicar em "Nova Venda"
2. Buscar produto: "COCA COLA 2L" (F3 ou barra de busca)
3. Adicionar ao carrinho
4. Selecionar pagamento: "Dinheiro"
5. Finalizar venda (F10)
         ↓
PWA → POST http://localhost:5000/api/vendas/finalizar
         ↓
Agente processa:
  1. Valida venda
  2. Imprime cupom na impressora térmica
  3. Abre gaveta de dinheiro (se configurado)
  4. Sincroniza com nuvem
         ↓
✅ Venda #00001 finalizada!
```

**Cupom impresso:**
```
================================================
           LOJA EXEMPLO LTDA
      CNPJ: 12.345.678/0001-90
    Rua Exemplo, 123 - Centro
          Tel: (11) 1234-5678
================================================

CUPOM NÃO FISCAL
Venda: #00001                      05/11/2025

------------------------------------------------
ITEM  DESCRIÇÃO          QTD    UNIT.    TOTAL
------------------------------------------------
001   COCA COLA 2L       1      R$ 8,90  R$ 8,90
------------------------------------------------

TOTAL:                                  R$ 8,90

FORMA DE PAGAMENTO:
  Dinheiro                              R$ 8,90

================================================
         OBRIGADO PELA PREFERÊNCIA!
================================================
         Terminal: Caixa 01
         Operador: Técnico Guilherme
================================================
```

#### **ETAPA 8: Configurações Finais** ⏱️ 10 min

```
✅ Verificar atalho do PWA na área de trabalho
✅ Configurar inicialização automática do serviço (já feito pelo instalador)
✅ Testar leitor de código de barras
✅ Configurar usuários do sistema (se necessário)
✅ Orientar cliente sobre uso básico
✅ Deixar documentação/contatos de suporte
✅ Registrar instalação no sistema de controle interno
```

---

## 📊 Resumo do Tempo Total

| Etapa | Tempo | Responsável |
|-------|-------|-------------|
| **PRÉ-INSTALAÇÃO (REMOTO)** | | |
| Admin cria tenant | 2 min | Admin |
| Admin gera token | 1 min | Admin |
| Admin envia token ao técnico | 1 min | Admin |
| **INSTALAÇÃO NO CLIENTE** | | |
| Preparar hardware | 15 min | Técnico |
| Instalar Agente PDV | 10 min | Técnico |
| Configurar impressora | 5 min | Técnico |
| Acessar e instalar PWA | 2 min | Técnico |
| Configurar token | 3 min | Técnico |
| Sincronização inicial | 5 min | Automático |
| Teste de venda | 5 min | Técnico |
| Configurações finais | 10 min | Técnico |
| **TOTAL** | **~60 min** | |

---

## 🎯 Vantagens deste Fluxo

✅ **Admin não precisa ir ao cliente**
   - Tudo configurado remotamente
   - Gera token e envia via WhatsApp/email

✅ **Técnico não precisa de credenciais admin**
   - Só precisa do token de vinculação
   - Token tem escopo limitado (apenas aquele terminal)

✅ **Token é seguro**
   - Expira após uso
   - Se vazar, só afeta aquele terminal
   - Admin pode revogar remotamente

✅ **Processo rápido**
   - 1 hora total de instalação
   - Maioria é automática

✅ **Funciona offline**
   - Após sincronização, sistema funciona sem internet
   - Sincroniza quando conectar

---

## 🔄 Fluxo de Comunicação Durante Instalação

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│    ADMIN     │         │   TÉCNICO    │         │   SISTEMA    │
│   (Remoto)   │         │  (Cliente)   │         │   (Cloud)    │
└──────────────┘         └──────────────┘         └──────────────┘
       │                        │                         │
       │ 1. Cria tenant         │                         │
       │────────────────────────────────────────────────>│
       │                        │                         │
       │ 2. Gera token          │                         │
       │────────────────────────────────────────────────>│
       │                        │                         │
       │ 3. Envia token         │                         │
       │──────────────────────>│                         │
       │                        │                         │
       │                        │ 4. Instala Agente       │
       │                        │ (localhost)             │
       │                        │                         │
       │                        │ 5. Instala PWA          │
       │                        │ (localhost)             │
       │                        │                         │
       │                        │ 6. Configura token      │
       │                        │ PWA → Agente            │
       │                        │                         │
       │                        │ 7. Agente valida        │
       │                        │ Agente → API            │
       │                        │─────────────────────────>│
       │                        │                         │
       │                        │ 8. Sincroniza dados     │
       │                        │ PWA ← Agente ← API      │
       │                        │<─────────────────────────│
       │                        │                         │
       │                        │ 9. ✅ Sistema pronto    │
       │                        │                         │
```

---

## 📱 Cenários Especiais

### **Cenário 1: Cliente com múltiplos terminais**

```
Admin gera 3 tokens diferentes:
  - Token Terminal 01 (caixa principal)
  - Token Terminal 02 (caixa 2)
  - Token Terminal 03 (tablet vendedor)

Técnico:
  1. Instala agente em cada máquina
  2. Usa token específico em cada uma
  3. Todos conectam no mesmo tenant (loja-exemplo)
  4. Cada terminal tem nome único
```

### **Cenário 2: Cliente sem internet no momento**

```
Técnico:
  1. Instala agente normalmente
  2. Tenta configurar token
  3. Sistema tenta sincronizar → falha
  4. ⚠️ Mostra: "Modo offline - Sincronização pendente"
  5. Sistema funciona com dados em cache
  6. Técnico configura internet
  7. Sistema sincroniza automaticamente
  8. ✅ Pronto
```

### **Cenário 3: Token inválido/expirado**

```
Técnico cola token
Sistema valida
❌ Erro: "Token inválido ou expirado"

Solução:
  1. Técnico contata admin (WhatsApp/telefone)
  2. Admin verifica e gera novo token
  3. Admin envia novo token
  4. Técnico cola novo token
  5. ✅ Sucesso
```

### **Cenário 4: Impressora não detectada**

```
Agente não detecta impressora automaticamente

Solução:
  1. Verificar conexão USB
  2. Instalar driver (se necessário)
  3. Configurar manualmente via API:
  
  POST http://localhost:5000/api/impressoras/configurar
  {
    "porta": "USB001",
    "modelo": "ELGIN_I9"
  }
```

---

## 🔒 Segurança no Processo

### **O que o técnico NÃO tem acesso:**

❌ Painel administrativo do sistema
❌ Criar/editar outros tenants
❌ Ver dados de outros clientes
❌ Revogar tokens
❌ Alterar configurações globais
❌ Acessar banco de dados central

### **O que o técnico TEM acesso:**

✅ Instalar agente no cliente
✅ Configurar token específico daquele terminal
✅ Fazer vendas de teste
✅ Ver produtos do cliente
✅ Sincronizar dados do tenant

### **Controles de segurança:**

🔐 Token JWT tem validade (expira em data definida)
🔐 Token é específico por terminal (1 token = 1 terminal)
🔐 Token só funciona uma vez na configuração inicial
🔐 Admin pode revogar token remotamente (via API)
🔐 Logs de auditoria registram quem configurou e quando
🔐 Comunicação PWA ↔ Agente em localhost (não sai da máquina)
🔐 Comunicação Agente ↔ API em HTTPS

---

## 📋 Checklist do Técnico

### PRÉ-INSTALAÇÃO:
```
[ ] Recebeu token do admin
[ ] Verificou equipamentos necessários no cliente
[ ] Baixou instalador do Agente (pen drive/nuvem)
[ ] Verificou versão do Windows (8.1 ou superior)
```

### NO CLIENTE:
```
[ ] Hardware conectado e funcionando
    [ ] Impressora térmica USB
    [ ] Gaveta de dinheiro
    [ ] Leitor de código de barras
[ ] Agente instalado e rodando (porta 5000)
[ ] Impressora detectada e testada
[ ] PWA instalado (ícone na área de trabalho)
[ ] Token configurado com sucesso
[ ] Sincronização inicial concluída
[ ] Venda de teste realizada com sucesso
[ ] Cupom impresso corretamente
[ ] Gaveta abrindo corretamente (se configurado)
[ ] Leitor de código de barras funcionando
[ ] Cliente orientado sobre uso básico
[ ] Contatos de suporte deixados
```

### PÓS-INSTALAÇÃO:
```
[ ] Confirmar com admin que terminal está online
[ ] Verificar logs de sincronização no sistema
[ ] Registrar número de série do equipamento
[ ] Tirar fotos da instalação (documentação)
[ ] Preencher checklist de instalação
[ ] Enviar relatório ao admin
```

---

## 🆘 Troubleshooting - Problemas Comuns

### **1. Agente não inicia**

**Sintomas:**
```
GET http://localhost:5000/api/health
❌ ERR_CONNECTION_REFUSED
```

**Soluções:**
```powershell
# Verificar se serviço está rodando
Get-Service Solis.AgentePDV

# Se parado, iniciar:
net start Solis.AgentePDV

# Ver logs de erro:
Get-Content C:\ProgramData\Solis\logs\agente.log -Tail 50

# Reinstalar se necessário:
.\scripts\desinstalar-servico.ps1
.\scripts\instalar-servico.ps1
```

### **2. PWA não instala**

**Sintomas:**
- Não aparece prompt de instalação
- Erro ao acessar site

**Soluções:**
```
1. Verificar se está usando Chrome/Edge (não funciona no Firefox)
2. Verificar se site está em HTTPS
3. Limpar cache do browser: Ctrl+Shift+Del
4. Tentar em modo anônimo
5. Verificar manifest.json está acessível
```

### **3. Token inválido**

**Sintomas:**
```
❌ Erro: "Token inválido ou expirado"
```

**Soluções:**
```
1. Verificar se token foi colado completo (sem quebras de linha)
2. Verificar se token não expirou
3. Contatar admin para gerar novo token
4. Verificar se tenant existe no sistema
```

### **4. Impressora não imprime**

**Sintomas:**
- Venda finaliza mas não imprime
- Erro "Impressora não encontrada"

**Soluções:**
```powershell
# 1. Verificar conexão USB
# 2. Testar impressora no Windows (imprimir teste)

# 3. Ver se agente detectou:
Invoke-RestMethod http://localhost:5000/api/impressoras

# 4. Se não detectou, configurar manualmente:
# Usar Postman ou curl
POST http://localhost:5000/api/impressoras/configurar
{
  "porta": "USB001",
  "modelo": "ELGIN_I9",
  "velocidade": 9600
}

# 5. Verificar driver instalado
# 6. Reiniciar agente
net stop Solis.AgentePDV
net start Solis.AgentePDV
```

### **5. Sincronização falhando**

**Sintomas:**
```
⚠️ "Erro ao sincronizar dados"
```

**Soluções:**
```
1. Verificar conexão com internet
2. Verificar firewall não está bloqueando
3. Verificar se API está online (https://api.solis.com.br/health)
4. Ver logs do agente:
   C:\ProgramData\Solis\logs\sync-errors.log
5. Tentar sincronizar manualmente no PWA
```

---

## 📞 Contatos de Suporte

**Suporte Técnico:**
- 📱 WhatsApp: (11) 99999-9999
- 📧 Email: suporte@solis.com.br
- 🌐 Portal: https://suporte.solis.com.br

**Horário de Atendimento:**
- Segunda a Sexta: 8h às 18h
- Sábado: 8h às 12h
- Emergências: 24/7 (somente clientes premium)

---

**Última atualização**: Novembro 2025  
**Versão**: 1.0.0  
**Autor**: Equipe Solis
