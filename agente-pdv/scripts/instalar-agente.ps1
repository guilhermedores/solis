#Requires -RunAsAdministrator

param(
    [string]$InstallPath = "C:\Solis\AgentePDV",
    [string]$DataPath = "C:\ProgramData\Solis",
    [string]$ServiceName = "SolisAgentePDV",
    [string]$ApiUrl = "http://localhost:3000",
    [string]$ImpressoraPorta = "COM3",
    [string]$GavetaPorta = "COM3"
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
Write-Host "        Instalador Windows" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Este script precisa ser executado como Administrador!"
    exit 1
}

Write-Step "Verificando .NET 8.0 SDK..."
try {
    $dotnetVersion = dotnet --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   .NET SDK Version: $dotnetVersion" -ForegroundColor Gray
        Write-Success ".NET 8.0 SDK encontrado"
    } else {
        Write-Warning ".NET SDK nao encontrado. Necessario para publicacao."
        Write-Host "   Baixe em: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Error ".NET SDK nao instalado!"
    Write-Host "   Baixe em: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}

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
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallPath\logs" | Out-Null
New-Item -ItemType Directory -Force -Path $DataPath | Out-Null
Write-Success "Diretorios criados"

$scriptDir = Split-Path -Parent $PSScriptRoot
$projectPath = $scriptDir
$csprojPath = Join-Path $projectPath "Solis.AgentePDV.csproj"

if (-not (Test-Path $csprojPath)) {
    Write-Error "Projeto nao encontrado: $csprojPath"
    exit 1
}

Write-Step "Publicando aplicacao (arquivo unico)..."
$output = dotnet publish $csprojPath -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o $InstallPath 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao publicar!"
    Write-Host $output -ForegroundColor Red
    exit 1
}
Write-Success "Aplicacao publicada como arquivo unico"

Write-Step "Configurando appsettings.json..."
try {
    $appSettingsPath = Join-Path $InstallPath "appsettings.json"
    $appSettings = Get-Content $appSettingsPath | ConvertFrom-Json
    $appSettings.ConnectionStrings.LocalDb = "Data Source=$DataPath\agente-pdv.db"
    $appSettings.SolisApi.BaseUrl = $ApiUrl
    $appSettings | ConvertTo-Json -Depth 10 | Set-Content $appSettingsPath
    Write-Success "Configuracao atualizada"
} catch {
    Write-Warning "Configure manualmente: $appSettingsPath"
}

Write-Step "Configurando permissoes..."
icacls $InstallPath /grant "NETWORK SERVICE:(OI)(CI)F" /T | Out-Null
icacls $DataPath /grant "NETWORK SERVICE:(OI)(CI)F" /T | Out-Null
Write-Success "Permissoes configuradas"

Write-Step "Criando servico..."
$exePath = Join-Path $InstallPath "Solis.AgentePDV.exe"
sc.exe create $ServiceName binPath= $exePath start= auto DisplayName= "Solis - Agente PDV" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao criar servico"
    exit 1
}
sc.exe failure $ServiceName reset= 86400 actions= restart/60000/restart/60000 | Out-Null
Write-Success "Servico criado"

Write-Step "Iniciando servico..."
Start-Service -Name $ServiceName
Start-Sleep -Seconds 3
$service = Get-Service -Name $ServiceName
if ($service.Status -eq "Running") {
    Write-Success "Servico iniciado!"
} else {
    Write-Warning "Servico nao iniciou (Status: $($service.Status))"
}

Write-Host "`n===============================================" -ForegroundColor Green
Write-Host "  INSTALACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "`nInformacoes:" -ForegroundColor Cyan
Write-Host "   Servico: $ServiceName" -ForegroundColor White
Write-Host "   Status: $((Get-Service $ServiceName).Status)" -ForegroundColor White
Write-Host "   API: http://localhost:5000" -ForegroundColor White
Write-Host "   Health: http://localhost:5000/health" -ForegroundColor White
Write-Host "`nComandos:" -ForegroundColor Cyan
Write-Host "   Get-Service $ServiceName" -ForegroundColor Gray
Write-Host "   Stop-Service $ServiceName" -ForegroundColor Gray
Write-Host "   Restart-Service $ServiceName" -ForegroundColor Gray
