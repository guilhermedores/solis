# 📜 Scripts de Gerenciamento do Solis Agente PDV

Esta pasta contém scripts PowerShell para facilitar a instalação, manutenção e diagnóstico do Agente PDV no Windows.

## 📋 Scripts Disponíveis

### � `build.ps1`
**Compilação em arquivo único**

Compila o projeto gerando um executável standalone de ~105 MB.

**Uso:**
```powershell
# Build Release (produção)
.\build.ps1

# Build Debug
.\build.ps1 -Configuration Debug

# Especificar pasta de saída
.\build.ps1 -OutputPath "C:\Deploy\solis-agente"
```

**O que faz:**
- ✅ Verifica .NET SDK
- ✅ Limpa builds anteriores
- ✅ Compila em modo self-contained
- ✅ Gera arquivo único (~105 MB)
- ✅ Inclui runtime .NET 8.0
- ✅ Inclui todas as dependências
- ✅ Inclui bibliotecas nativas (SQLite)
- ✅ Mostra tamanho e localização

**Saída:**
- `bin\Release\net8.0\win-x64\publish\Solis.AgentePDV.exe`

---

### �🚀 `instalar-agente.ps1`
**Instalação automatizada do serviço (compila do código-fonte)**

Compila e instala o Agente PDV como um serviço do Windows. **Requer .NET 8.0 SDK**.

**Uso:**
```powershell
# Instalação padrão
.\instalar-agente.ps1

# Instalação personalizada
.\instalar-agente.ps1 `
  -ApiUrl "http://api.minhaempresa.com" `
  -InstallPath "D:\Solis\Agente"
```

**Parâmetros:**
- `-InstallPath`: Caminho de instalação (padrão: `C:\Solis\AgentePDV`)
- `-DataPath`: Caminho dos dados (padrão: `C:\ProgramData\Solis`)
- `-ServiceName`: Nome do serviço (padrão: `SolisAgentePDV`)
- `-ApiUrl`: URL da API na nuvem (padrão: `http://localhost:3000`)

**O que faz:**
- ✅ Verifica .NET 8.0 SDK
- ✅ Remove instalação anterior se existir
- ✅ Cria estrutura de diretórios
- ✅ **Compila a aplicação em arquivo único (self-contained)**
- ✅ Configura `appsettings.json`
- ✅ Define permissões NTFS
- ✅ Cria serviço do Windows
- ✅ Configura recuperação automática
- ✅ Inicia o serviço

---

### 📦 `instalar-agente-precompilado.ps1`
**Instalação a partir de executável já compilado (recomendado para produção)**

Instala o Agente PDV a partir de um executável pré-compilado. **Não requer .NET SDK**.

**Uso:**
```powershell
# Instalação automática (busca executável automaticamente)
.\instalar-agente-precompilado.ps1

# Especificar caminho do executável
.\instalar-agente-precompilado.ps1 -SourcePath "C:\Downloads\solis-agente\publish"

# Instalação personalizada
.\instalar-agente-precompilado.ps1 `
  -SourcePath "C:\Downloads\solis-agente\publish" `
  -ApiUrl "http://api.minhaempresa.com" `
  -InstallPath "D:\Solis\Agente"
```

**Parâmetros:**
- `-SourcePath`: Caminho do executável (auto-detecta se não especificado)
- `-InstallPath`: Caminho de instalação (padrão: `C:\Solis\AgentePDV`)
- `-DataPath`: Caminho dos dados (padrão: `C:\ProgramData\Solis`)
- `-ServiceName`: Nome do serviço (padrão: `SolisAgentePDV`)
- `-ApiUrl`: URL da API na nuvem (padrão: `http://localhost:3000`)

**O que faz:**
- ✅ Localiza executável automaticamente
- ✅ Remove instalação anterior se existir
- ✅ Cria estrutura de diretórios
- ✅ **Copia arquivo único (~105 MB)**
- ✅ Configura `appsettings.json`
- ✅ Define permissões NTFS
- ✅ Cria serviço do Windows
- ✅ Configura recuperação automática
- ✅ Inicia o serviço

**Vantagens:**
- ⚡ Instalação muito mais rápida (não precisa compilar)
- 📦 Não requer .NET SDK na máquina de destino
- 🎯 Recomendado para produção e distribuição

---

### 🗑️ `desinstalar-agente.ps1`
**Remoção completa do serviço**

Remove o Agente PDV do sistema, opcionalmente incluindo dados.

**Uso:**
```powershell
# Remover apenas a aplicação (mantém dados)
.\desinstalar-agente.ps1

# Remover aplicação E dados
.\desinstalar-agente.ps1 -RemoveData

# Remover tudo sem manter backup
.\desinstalar-agente.ps1 -RemoveData -KeepBackup:$false
```

**Parâmetros:**
- `-ServiceName`: Nome do serviço (padrão: `SolisAgentePDV`)
- `-InstallPath`: Caminho de instalação (padrão: `C:\Solis\AgentePDV`)
- `-DataPath`: Caminho dos dados (padrão: `C:\ProgramData\Solis`)
- `-RemoveData`: Se especificado, também remove o banco de dados
- `-KeepBackup`: Mantém backup dos dados na Área de Trabalho (padrão: `$true`)

**O que faz:**
- ✅ Solicita confirmação antes de prosseguir
- ✅ Para o serviço se estiver rodando
- ✅ Remove o serviço do Windows
- ✅ Cria backup automático dos dados (se `-RemoveData`)
- ✅ Remove arquivos de instalação
- ✅ Remove dados (se `-RemoveData` for usado)
- ✅ Remove regras de firewall
- ✅ Limpa variáveis de ambiente
- ✅ Valida a remoção completa
- ✅ Fornece instruções se algo falhar

**Exemplo de saída:**
```
===============================================
        SOLIS - AGENTE PDV
        Desinstalador Windows
===============================================

ATENCAO: Este script vai remover o Solis Agente PDV

   Servico: SolisAgentePDV
   Instalacao: C:\Solis\AgentePDV
   Dados: C:\ProgramData\Solis [sera mantido]

Deseja continuar? (S/N): S

[OK] Servico parado
[OK] Servico removido
[OK] Arquivos de instalacao removidos
[OK] Dados preservados em: C:\ProgramData\Solis

===============================================
  DESINSTALACAO CONCLUIDA!
===============================================
```

---

### 🧪 `testar-agente.ps1`
**Diagnóstico completo do sistema**

Executa uma bateria de testes para verificar a saúde do sistema.

**Uso:**
```powershell
.\testar-agente.ps1
```

**Testes realizados:**
1. ✅ .NET Runtime instalado
2. ✅ Serviço do Windows existe e está rodando
3. ✅ Arquivos de instalação presentes
4. ✅ Banco de dados SQLite criado
5. ✅ Logs sendo gerados
6. ✅ API REST respondendo
7. ✅ Portas COM disponíveis
8. ✅ Conectividade com API Nuvem
9. ✅ Regra de firewall configurada
10. ✅ Eventos do sistema

**Exemplo de saída:**
```
╔═══════════════════════════════════════════════════════════╗
║ 1. Verificando .NET Runtime                               ║
╚═══════════════════════════════════════════════════════════╝
✅ .NET 8.0 Runtime
   Versão: 8.0.0

╔═══════════════════════════════════════════════════════════╗
║ 2. Verificando Serviço do Windows                         ║
╚═══════════════════════════════════════════════════════════╝
✅ Serviço existe
   Nome: SolisAgentePDV
✅ Serviço rodando
   Status: Running
```

---

### 🎛️ `gerenciar-agente.ps1`
**Menu interativo de gerenciamento**

Interface de linha de comando para operações comuns do dia a dia.

**Uso:**
```powershell
.\gerenciar-agente.ps1
```

**Funcionalidades:**
```
╔════════════════════════════════════════════╗
║      SOLIS - GERENCIADOR DO AGENTE         ║
╚════════════════════════════════════════════╝

Status: Running

OPERAÇÕES:
  1. Iniciar serviço
  2. Parar serviço
  3. Reiniciar serviço
  4. Ver logs ao vivo
  5. Ver status detalhado
  6. Testar API (Health Check)
  7. Testar impressora
  8. Abrir gaveta
  9. Ver últimos eventos
 10. Editar configuração
 11. Backup do banco de dados
 12. Executar diagnóstico completo
  0. Sair
```

---

## 🔐 Requisitos

Todos os scripts requerem **permissões de Administrador**.

### Para executar:

**Opção 1: PowerShell como Admin**
```powershell
# Abra PowerShell como Administrador e navegue até a pasta
cd "C:\Users\Guilherme Batista\Solis\agente-pdv\scripts"
.\instalar-agente.ps1
```

**Opção 2: Botão Direito**
1. Clique com botão direito no arquivo `.ps1`
2. Selecione "Executar com PowerShell"
3. Confirme a execução como Administrador

**Opção 3: Atalho de Admin**
```powershell
# Criar atalho que sempre executa como admin
powershell -Command "Start-Process powershell -ArgumentList '-File .\instalar-agente.ps1' -Verb RunAs"
```

---

## 🛡️ Política de Execução

Se encontrar erro de política de execução:

```powershell
# Ver política atual
Get-ExecutionPolicy

# Permitir scripts locais (recomendado)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ou executar sem mudar política
powershell -ExecutionPolicy Bypass -File .\instalar-agente.ps1
```

---

## 📊 Workflow Típico de Instalação

### Para Desenvolvimento (com código-fonte):
```powershell
# 1. Compilar e instalar
.\instalar-agente.ps1 -ApiUrl "http://api.minhaempresa.com"

# 2. Verificar instalação
.\testar-agente.ps1

# 3. Gerenciar no dia a dia
.\gerenciar-agente.ps1
```

### Para Produção (executável pré-compilado):
```powershell
# 1. Gerar executável (apenas uma vez no ambiente de dev)
cd ..\
dotnet publish -c Release -r win-x64

# 2. Copiar pasta 'publish' para máquina de produção
# C:\Deploy\solis-agente\publish\

# 3. Instalar na produção (não precisa .NET SDK)
cd C:\Deploy\solis-agente\scripts
.\instalar-agente-precompilado.ps1 -ApiUrl "http://api.minhaempresa.com"

# 4. Verificar
.\testar-agente.ps1
```

---

## 🔧 Troubleshooting

### Script não executa
```powershell
# Verificar se está como Admin
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Deve retornar: True
```

### Erro de assinatura
```powershell
# Desbloquear arquivo baixado da internet
Unblock-File .\instalar-agente.ps1
Unblock-File .\desinstalar-agente.ps1
Unblock-File .\testar-agente.ps1
Unblock-File .\gerenciar-agente.ps1
```

### .NET não encontrado
```powershell
# Verificar instalação
dotnet --version
dotnet --list-runtimes

# Para desenvolvimento (compilar): .NET 8.0 SDK
# https://dotnet.microsoft.com/download/dotnet/8.0

# Para produção com executável pré-compilado: 
# Não precisa instalar nada! O executável já inclui tudo.
```

### Compilação em arquivo único
```powershell
# Gerar executável standalone (~105 MB)
cd ..\
dotnet publish -c Release -r win-x64

# Localização do executável:
# bin\Release\net8.0\win-x64\publish\Solis.AgentePDV.exe

# Este arquivo único contém:
# - Runtime .NET 8.0
# - Todas as dependências
# - Bibliotecas nativas (SQLite)
# - Código da aplicação
```

---

## 📝 Logs e Diagnóstico

### Ver logs ao vivo
```powershell
Get-Content "C:\Solis\AgentePDV\logs\agente-pdv-$(Get-Date -Format 'yyyyMMdd').txt" -Wait
```

### Ver eventos do Windows
```powershell
Get-EventLog -LogName Application -Source "Solis.AgentePDV" -Newest 20
```

### Status do serviço
```powershell
Get-Service SolisAgentePDV | Format-List *
```

---

## 🆘 Suporte

Para mais informações:
- 📖 [Documentação Completa](../INSTALACAO_WINDOWS.md)
- 📚 [README Principal](../README.md)
- 🏗️ [Decisões de Arquitetura](../ARCHITECTURE_DECISION.md)

---

## 📄 Licença

Parte do projeto Solis PDV
