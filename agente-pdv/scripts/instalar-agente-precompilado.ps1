#Requires -RunAsAdministrator

param(
    [string]$SourcePath = "",
    [string]$InstallPath = "C:\Solis\AgentePDV",
    [string]$DataPath = "C:\ProgramData\Solis",
    [string]$ServiceName = "SolisAgentePDV",
    [string]$ApiUrl = "http://localhost:3000"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERRO] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[AVISO] $Message" -ForegroundColor Yellow
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "        SOLIS - AGENTE PDV" -ForegroundColor Cyan
Write-Host "        Instalador Windows (Pre-compilado)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Este script precisa ser executado como Administrador!"
    exit 1
}

# Determinar caminho do executavel
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $scriptDir = Split-Path -Parent $PSCommandPath
    $possiblePaths = @(
        (Join-Path (Split-Path -Parent $scriptDir) "bin\Release\net8.0\win-x64\publish"),
        (Join-Path $scriptDir "publish"),
        $scriptDir
    )
    
    foreach ($path in $possiblePaths) {
        $exePath = Join-Path $path "Solis.AgentePDV.exe"
        if (Test-Path $exePath) {
            $SourcePath = $path
            break
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($SourcePath)) {
        Write-Error "Executavel nao encontrado!"
        Write-Host "   Compile o projeto com: dotnet publish -c Release -r win-x64" -ForegroundColor Yellow
        Write-Host "   Ou especifique o caminho: -SourcePath 'C:\caminho\publish'" -ForegroundColor Yellow
        exit 1
    }
}

$sourceExe = Join-Path $SourcePath "Solis.AgentePDV.exe"
if (-not (Test-Path $sourceExe)) {
    Write-Error "Executavel nao encontrado: $sourceExe"
    exit 1
}

Write-Success "Executavel encontrado: $sourceExe"

Write-Step "Verificando instalacao anterior..."
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Warning "Servico existente encontrado. Removendo..."
    $service = Get-Service -Name $ServiceName
    if ($service.Status -eq "Running") {
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 2
    }
    sc.exe delete $ServiceName | Out-Null
    Start-Sleep -Seconds 2
    Write-Success "Servico removido"
}

Write-Step "Criando diretorios..."
if (Test-Path $InstallPath) {
    Write-Warning "Diretorio existente. Limpando..."
    Remove-Item -Path "$InstallPath\*" -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallPath\logs" | Out-Null
New-Item -ItemType Directory -Force -Path $DataPath | Out-Null
Write-Success "Diretorios criados"

Write-Step "Copiando arquivos..."
Copy-Item -Path "$SourcePath\*" -Destination $InstallPath -Recurse -Force

# Copiar appsettings.json para a raiz (onde o .NET espera encontrar)
if (Test-Path "$InstallPath\src\appsettings.json") {
    Copy-Item -Path "$InstallPath\src\appsettings.json" -Destination "$InstallPath\appsettings.json" -Force
}
if (Test-Path "$InstallPath\src\appsettings.Production.json") {
    Copy-Item -Path "$InstallPath\src\appsettings.Production.json" -Destination "$InstallPath\appsettings.Production.json" -Force
}

Write-Success "Arquivos copiados"

Write-Step "Configurando appsettings.json..."
try {
    # Configurar tanto o da raiz quanto o da pasta src
    $appSettingsPath = Join-Path $InstallPath "appsettings.json"
    $appSettingsProdPath = Join-Path $InstallPath "appsettings.Production.json"
    $appSettingsSrcPath = Join-Path $InstallPath "src\appsettings.json"
    $appSettingsProdSrcPath = Join-Path $InstallPath "src\appsettings.Production.json"
    
    if (Test-Path $appSettingsPath) {
        # Ler o JSON como texto e fazer replace direto
        $jsonContent = Get-Content $appSettingsPath -Raw
        $dbPath = "$DataPath\agente-pdv.db".Replace('\', '\\')
        
        # Replace da connection string
        $jsonContent = $jsonContent -replace '"LocalDb":\s*"[^"]*"', "`"LocalDb`": `"Data Source=$dbPath`""
        
        # Replace da URL da API
        $jsonContent = $jsonContent -replace '"BaseUrl":\s*"[^"]*"', "`"BaseUrl`": `"$ApiUrl`""
        
        # Salvar nos arquivos da raiz
        $jsonContent | Set-Content $appSettingsPath -Encoding UTF8 -NoNewline
        
        # Também salvar na pasta src (backup)
        if (Test-Path $appSettingsSrcPath) {
            $jsonContent | Set-Content $appSettingsSrcPath -Encoding UTF8 -NoNewline
        }
        
        # Também atualizar o Production se existir
        if (Test-Path $appSettingsProdPath) {
            $jsonProdContent = Get-Content $appSettingsProdPath -Raw
            $jsonProdContent = $jsonProdContent -replace '"BaseUrl":\s*"[^"]*"', "`"BaseUrl`": `"$ApiUrl`""
            $jsonProdContent | Set-Content $appSettingsProdPath -Encoding UTF8 -NoNewline
            
            # Também na pasta src
            if (Test-Path $appSettingsProdSrcPath) {
                $jsonProdContent | Set-Content $appSettingsProdSrcPath -Encoding UTF8 -NoNewline
            }
        }
        
        Write-Success "Configuracao atualizada"
    } else {
        Write-Warning "appsettings.json nao encontrado em: $appSettingsPath"
    }
} catch {
    Write-Warning "Configure manualmente: $appSettingsPath"
}

Write-Step "Configurando permissoes..."
icacls $InstallPath /grant "Todos:(OI)(CI)F" /T | Out-Null
icacls $DataPath /grant "Todos:(OI)(CI)F" /T | Out-Null
Write-Success "Permissoes configuradas"

# NAO criar arquivo vazio - EnsureCreated() precisa que o banco nao exista
# Write-Step "Criando arquivo de banco vazio..."
# try {
#     $dbPath = Join-Path $DataPath "agente-pdv.db"
#     if (-not (Test-Path $dbPath)) {
#         $null = New-Item -Path $dbPath -ItemType File -Force
#         Write-Success "Arquivo de banco preparado"
#     } else {
#         Write-Success "Banco de dados ja existe"
#     }
# } catch {
#     Write-Warning "Erro ao criar arquivo de banco: $_"
# }
Write-Success "Banco sera criado automaticamente na primeira inicializacao"

Write-Step "Criando servico..."
$exePath = Join-Path $InstallPath "Solis.AgentePDV.exe"
sc.exe create $ServiceName binPath= "`"$exePath`"" start= auto DisplayName= "Solis - Agente PDV" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao criar servico"
    exit 1
}
sc.exe failure $ServiceName reset= 86400 actions= restart/60000/restart/60000 | Out-Null
sc.exe description $ServiceName "Agente local do sistema Solis PDV para sincronizacao e controle de perifericos" | Out-Null
Write-Success "Servico criado"

Write-Step "Iniciando servico..."
Start-Service -Name $ServiceName
Start-Sleep -Seconds 5
$service = Get-Service -Name $ServiceName
if ($service.Status -eq "Running") {
    Write-Success "Servico iniciado!"
} else {
    Write-Warning "Servico nao iniciou (Status: $($service.Status))"
    Write-Host "   Verifique os logs em: $InstallPath\logs" -ForegroundColor Yellow
}

Write-Host "`n===============================================" -ForegroundColor Green
Write-Host "  INSTALACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "`nInformacoes:" -ForegroundColor Cyan
Write-Host "   Servico: $ServiceName" -ForegroundColor White
Write-Host "   Status: $((Get-Service $ServiceName).Status)" -ForegroundColor White
Write-Host "   Instalado em: $InstallPath" -ForegroundColor White
Write-Host "   Dados em: $DataPath" -ForegroundColor White
Write-Host "   API: http://localhost:5000" -ForegroundColor White
Write-Host "   Health: http://localhost:5000/health" -ForegroundColor White
Write-Host "   Logs: $InstallPath\logs" -ForegroundColor White
Write-Host "`nComandos:" -ForegroundColor Cyan
Write-Host "   Get-Service $ServiceName" -ForegroundColor Gray
Write-Host "   Stop-Service $ServiceName" -ForegroundColor Gray
Write-Host "   Restart-Service $ServiceName" -ForegroundColor Gray
Write-Host "   Get-Content '$InstallPath\logs\agente-pdv-*.txt' -Tail 50" -ForegroundColor Gray
