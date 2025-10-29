# 🪟 Instalação do Solis Agente PDV no Windows

## Pré-requisitos

- Windows 10/11 ou Windows Server 2019+
- .NET 8.0 Runtime instalado
- Permissões de Administrador
- Portas COM disponíveis (para periféricos)

## Métodos de Instalação

### 📦 Método 1: Instalação Manual com SC (Recomendado para desenvolvimento)

#### 1. Publicar a aplicação

```powershell
# Navegue até o diretório do projeto
cd "C:\Users\Guilherme Batista\Solis\agente-pdv"

# Publique a aplicação em modo Release
dotnet publish -c Release -o "C:\Solis\AgentePDV"
```

#### 2. Configurar appsettings.json

Edite o arquivo `C:\Solis\AgentePDV\appsettings.json` conforme necessário:

```json
{
  "ConnectionStrings": {
    "LocalDb": "Data Source=C:\\ProgramData\\Solis\\agente-pdv.db",
    "CloudApi": "Server=seu-servidor;Database=solis;User Id=usuario;Password=senha;"
  },
  "ApiNuvem": {
    "BaseUrl": "http://api.seuservidor.com",
    "Timeout": 30
  },
  "Perifericos": {
    "Impressora": {
      "PortaCOM": "COM3",
      "VelocidadeBaud": 9600
    },
    "Gaveta": {
      "PortaCOM": "COM3",
      "VelocidadeBaud": 9600
    }
  }
}
```

#### 3. Criar diretórios necessários

```powershell
# Criar diretório para dados
New-Item -ItemType Directory -Force -Path "C:\ProgramData\Solis"

# Criar diretório para logs
New-Item -ItemType Directory -Force -Path "C:\Solis\AgentePDV\logs"
```

#### 4. Instalar como serviço do Windows

```powershell
# Criar o serviço
sc.exe create "SolisAgentePDV" `
  binPath= "C:\Solis\AgentePDV\Solis.AgentePDV.exe" `
  start= auto `
  DisplayName= "Solis - Agente PDV" `
  description= "Serviço de comunicação com periféricos e sincronização do sistema Solis PDV"

# Configurar recuperação automática em caso de falha
sc.exe failure "SolisAgentePDV" reset= 86400 actions= restart/60000/restart/60000/restart/60000

# Iniciar o serviço
sc.exe start SolisAgentePDV
```

#### 5. Verificar status

```powershell
# Verificar se está rodando
sc.exe query SolisAgentePDV

# Ver logs
Get-Content "C:\Solis\AgentePDV\logs\agente-pdv-$(Get-Date -Format 'yyyyMMdd').txt" -Wait
```

---

### 🔧 Método 2: PowerShell Script Automatizado (Recomendado para produção)

Crie um arquivo `instalar-agente.ps1`:

```powershell
#Requires -RunAsAdministrator

param(
    [string]$InstallPath = "C:\Solis\AgentePDV",
    [string]$DataPath = "C:\ProgramData\Solis",
    [string]$ServiceName = "SolisAgentePDV",
    [string]$ApiUrl = "http://localhost:3000"
)

Write-Host "🚀 Instalando Solis Agente PDV..." -ForegroundColor Cyan

# 1. Parar serviço se já existir
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Host "⏸️  Parando serviço existente..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force
    sc.exe delete $ServiceName
    Start-Sleep -Seconds 2
}

# 2. Criar diretórios
Write-Host "📁 Criando diretórios..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallPath\logs" | Out-Null
New-Item -ItemType Directory -Force -Path $DataPath | Out-Null

# 3. Publicar aplicação
Write-Host "📦 Publicando aplicação..." -ForegroundColor Green
$projectPath = Split-Path -Parent $PSScriptRoot
dotnet publish "$projectPath" -c Release -o $InstallPath --self-contained false

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao publicar aplicação!" -ForegroundColor Red
    exit 1
}

# 4. Configurar appsettings
Write-Host "⚙️  Configurando aplicação..." -ForegroundColor Green
$appSettings = Get-Content "$InstallPath\appsettings.json" | ConvertFrom-Json
$appSettings.ConnectionStrings.LocalDb = "Data Source=$DataPath\agente-pdv.db"
$appSettings.ApiNuvem.BaseUrl = $ApiUrl
$appSettings | ConvertTo-Json -Depth 10 | Set-Content "$InstallPath\appsettings.json"

# 5. Configurar permissões
Write-Host "🔒 Configurando permissões..." -ForegroundColor Green
$acl = Get-Acl $DataPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("NETWORK SERVICE", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-Acl $DataPath $acl

# 6. Criar serviço
Write-Host "🔧 Criando serviço do Windows..." -ForegroundColor Green
sc.exe create $ServiceName `
    binPath= "$InstallPath\Solis.AgentePDV.exe" `
    start= auto `
    DisplayName= "Solis - Agente PDV" `
    description= "Serviço de comunicação com periféricos e sincronização do sistema Solis PDV"

# 7. Configurar recuperação
sc.exe failure $ServiceName reset= 86400 actions= restart/60000/restart/60000/restart/60000

# 8. Iniciar serviço
Write-Host "▶️  Iniciando serviço..." -ForegroundColor Green
Start-Service -Name $ServiceName

# 9. Verificar status
Start-Sleep -Seconds 3
$service = Get-Service -Name $ServiceName
if ($service.Status -eq "Running") {
    Write-Host "✅ Serviço instalado e iniciado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Informações:" -ForegroundColor Cyan
    Write-Host "   - API: http://localhost:5000" -ForegroundColor White
    Write-Host "   - Health: http://localhost:5000/health" -ForegroundColor White
    Write-Host "   - Logs: $InstallPath\logs" -ForegroundColor White
    Write-Host "   - Banco: $DataPath\agente-pdv.db" -ForegroundColor White
} else {
    Write-Host "⚠️  Serviço instalado mas não está rodando. Verifique os logs." -ForegroundColor Yellow
    Write-Host "   Log do Windows: Get-EventLog -LogName Application -Source $ServiceName -Newest 10" -ForegroundColor Gray
}
```

#### Uso do script:

```powershell
# Executar como Administrador
.\instalar-agente.ps1

# Ou com parâmetros personalizados
.\instalar-agente.ps1 -ApiUrl "http://api.minhaempresa.com" -InstallPath "D:\Solis\Agente"
```

---

### 🗑️ Desinstalação

#### Script PowerShell `desinstalar-agente.ps1`:

```powershell
#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "SolisAgentePDV",
    [string]$InstallPath = "C:\Solis\AgentePDV",
    [switch]$RemoveData
)

Write-Host "🗑️  Desinstalando Solis Agente PDV..." -ForegroundColor Yellow

# 1. Parar serviço
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Host "⏸️  Parando serviço..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # 2. Remover serviço
    Write-Host "🔧 Removendo serviço..." -ForegroundColor Yellow
    sc.exe delete $ServiceName
}

# 3. Remover arquivos
if (Test-Path $InstallPath) {
    Write-Host "📁 Removendo arquivos de instalação..." -ForegroundColor Yellow
    Remove-Item -Path $InstallPath -Recurse -Force
}

# 4. Remover dados (opcional)
if ($RemoveData -and (Test-Path "C:\ProgramData\Solis")) {
    Write-Host "💾 Removendo banco de dados..." -ForegroundColor Yellow
    Remove-Item -Path "C:\ProgramData\Solis" -Recurse -Force
}

Write-Host "✅ Desinstalação concluída!" -ForegroundColor Green
```

---

## 🛠️ Comandos Úteis

### Gerenciar o Serviço

```powershell
# Iniciar
sc.exe start SolisAgentePDV
# ou
Start-Service SolisAgentePDV

# Parar
sc.exe stop SolisAgentePDV
# ou
Stop-Service SolisAgentePDV

# Reiniciar
Restart-Service SolisAgentePDV

# Ver status
Get-Service SolisAgentePDV

# Ver detalhes
sc.exe qc SolisAgentePDV
```

### Verificar Logs

```powershell
# Logs da aplicação
Get-Content "C:\Solis\AgentePDV\logs\agente-pdv-$(Get-Date -Format 'yyyyMMdd').txt" -Wait

# Logs do Windows (Event Viewer)
Get-EventLog -LogName Application -Source "Solis.AgentePDV" -Newest 20

# Ou pelo Event Viewer GUI
eventvwr.msc
```

### Testar API

```powershell
# Health Check
Invoke-RestMethod -Uri "http://localhost:5000/health"

# Listar produtos sincronizados
Invoke-RestMethod -Uri "http://localhost:5000/api/produtos"

# Status de periféricos
Invoke-RestMethod -Uri "http://localhost:5000/api/perifericos/status"
```

---

## 🔥 Firewall

Se necessário, abra a porta 5000:

```powershell
New-NetFirewallRule -DisplayName "Solis Agente PDV" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5000 `
    -Action Allow
```

---

## 🐛 Troubleshooting

### Serviço não inicia

1. **Verificar .NET Runtime:**
```powershell
dotnet --list-runtimes
# Deve mostrar: Microsoft.AspNetCore.App 8.0.x
```

2. **Verificar permissões:**
```powershell
# O serviço roda como NETWORK SERVICE por padrão
# Garantir que tem acesso aos diretórios
icacls "C:\Solis\AgentePDV" /grant "NETWORK SERVICE:(OI)(CI)F"
icacls "C:\ProgramData\Solis" /grant "NETWORK SERVICE:(OI)(CI)F"
```

3. **Ver erros de inicialização:**
```powershell
Get-EventLog -LogName Application -Source "Solis.AgentePDV" -Newest 10 | Format-List
```

### Portas COM não funcionam

```powershell
# Listar portas disponíveis
[System.IO.Ports.SerialPort]::getportnames()

# Verificar se estão em uso
Get-CimInstance -ClassName Win32_SerialPort
```

### Banco de dados corrompido

```powershell
# Fazer backup
Copy-Item "C:\ProgramData\Solis\agente-pdv.db" "C:\ProgramData\Solis\agente-pdv.db.backup"

# Recriar (apagar e deixar o EF criar novamente)
Remove-Item "C:\ProgramData\Solis\agente-pdv.db"
Restart-Service SolisAgentePDV
```

---

## 📋 Checklist de Instalação

- [ ] .NET 8.0 Runtime instalado
- [ ] Aplicação publicada em `C:\Solis\AgentePDV`
- [ ] Diretório de dados criado em `C:\ProgramData\Solis`
- [ ] `appsettings.json` configurado corretamente
- [ ] Serviço Windows criado e configurado
- [ ] Serviço iniciado com sucesso
- [ ] API respondendo em `http://localhost:5000/health`
- [ ] Portas COM configuradas e testadas
- [ ] Logs sendo gerados corretamente
- [ ] Sincronização com nuvem funcionando

---

## 🚀 Próximos Passos

Após a instalação:

1. Configurar as portas COM dos periféricos em `appsettings.json`
2. Testar impressão: `POST http://localhost:5000/api/perifericos/impressora/teste`
3. Testar gaveta: `POST http://localhost:5000/api/perifericos/gaveta/abrir`
4. Configurar o PWA para apontar para `http://localhost:5000`
5. Realizar uma venda de teste

---

## 📞 Suporte

Para problemas de instalação, verifique:
- Logs da aplicação: `C:\Solis\AgentePDV\logs\`
- Event Viewer do Windows
- Arquivo README.md para mais informações
