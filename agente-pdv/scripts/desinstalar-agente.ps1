#Requires -RunAsAdministrator

param(
    [string]$ServiceName = "SolisAgentePDV",
    [string]$InstallPath = "C:\Solis\AgentePDV",
    [string]$DataPath = "C:\ProgramData\Solis",
    [switch]$RemoveData = $false,
    [switch]$KeepBackup = $true
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
Write-Host "===============================================" -ForegroundColor Red
Write-Host "        SOLIS - AGENTE PDV" -ForegroundColor Red
Write-Host "        Desinstalador Windows" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Red

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Este script precisa ser executado como Administrador!"
    exit 1
}

Write-Warning "ATENCAO: Este script vai remover o Solis Agente PDV"
Write-Host ""
Write-Host "   Servico: $ServiceName" -ForegroundColor Yellow
Write-Host "   Instalacao: $InstallPath" -ForegroundColor Yellow
if ($RemoveData) {
    Write-Host "   Dados: $DataPath [SERA REMOVIDO]" -ForegroundColor Red
} else {
    Write-Host "   Dados: $DataPath [sera mantido]" -ForegroundColor Green
}
Write-Host ""

$confirmacao = Read-Host "Deseja continuar? (S/N)"
if ($confirmacao -ne "S" -and $confirmacao -ne "s") {
    Write-Host "Desinstalacao cancelada pelo usuario" -ForegroundColor Yellow
    exit 0
}

Write-Step "Verificando instalacao..."
$serviceExists = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if (-not $serviceExists) {
    Write-Warning "Servico '$ServiceName' nao encontrado"
} else {
    Write-Success "Servico encontrado"
}

if (-not (Test-Path $InstallPath)) {
    Write-Warning "Diretorio de instalacao nao encontrado: $InstallPath"
}

if ($serviceExists) {
    Write-Step "Parando servico..."
    try {
        $service = Get-Service -Name $ServiceName
        if ($service.Status -eq "Running") {
            Stop-Service -Name $ServiceName -Force
            Start-Sleep -Seconds 3
            Write-Success "Servico parado"
        } else {
            Write-Success "Servico ja estava parado"
        }
    } catch {
        Write-Warning "Erro ao parar servico: $_"
    }

    Write-Step "Removendo servico..."
    try {
        sc.exe delete $ServiceName | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Servico removido"
        } else {
            Write-Warning "Falha ao remover servico (codigo: $LASTEXITCODE)"
        }
        Start-Sleep -Seconds 2
    } catch {
        Write-Warning "Erro ao remover servico: $_"
    }
}

if ($RemoveData -and (Test-Path $DataPath)) {
    Write-Step "Fazendo backup dos dados..."
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = Join-Path $env:USERPROFILE "Desktop\Solis_Backup_$timestamp"
        
        New-Item -ItemType Directory -Force -Path $backupPath | Out-Null
        Copy-Item -Path "$DataPath\*" -Destination $backupPath -Recurse -Force
        
        Write-Success "Backup criado em: $backupPath"
    } catch {
        Write-Warning "Erro ao criar backup: $_"
    }

    if ($KeepBackup) {
        Write-Host "   Backup mantido na Area de Trabalho" -ForegroundColor Gray
    }
}

Write-Step "Removendo arquivos de instalacao..."
if (Test-Path $InstallPath) {
    try {
        Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $InstallPath)) {
            Write-Success "Arquivos de instalacao removidos"
        } else {
            Write-Warning "Alguns arquivos nao puderam ser removidos"
            Write-Host "   Tente remover manualmente: $InstallPath" -ForegroundColor Yellow
        }
    } catch {
        Write-Warning "Erro ao remover instalacao: $_"
    }
} else {
    Write-Warning "Diretorio de instalacao nao encontrado"
}

if ($RemoveData) {
    Write-Step "Removendo dados..."
    if (Test-Path $DataPath) {
        try {
            Remove-Item -Path $DataPath -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $DataPath)) {
                Write-Success "Dados removidos"
            } else {
                Write-Warning "Alguns dados nao puderam ser removidos"
                Write-Host "   Tente remover manualmente: $DataPath" -ForegroundColor Yellow
            }
        } catch {
            Write-Warning "Erro ao remover dados: $_"
        }
    } else {
        Write-Warning "Diretorio de dados nao encontrado"
    }
} else {
    Write-Success "Dados preservados em: $DataPath"
}

Write-Step "Removendo regras de firewall..."
try {
    $firewallRules = Get-NetFirewallRule -DisplayName "*Solis*" -ErrorAction SilentlyContinue
    if ($firewallRules) {
        foreach ($rule in $firewallRules) {
            Remove-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue
        }
        Write-Success "Regras de firewall removidas"
    } else {
        Write-Success "Nenhuma regra de firewall encontrada"
    }
} catch {
    Write-Warning "Erro ao remover regras de firewall: $_"
}

Write-Step "Limpando variaveis de ambiente..."
try {
    $envVars = @("CORS__AllowedDomain", "SolisApi__BaseUrl")
    foreach ($var in $envVars) {
        $value = [System.Environment]::GetEnvironmentVariable($var, [System.EnvironmentVariableTarget]::Machine)
        if ($value) {
            [System.Environment]::SetEnvironmentVariable($var, $null, [System.EnvironmentVariableTarget]::Machine)
            Write-Success "Variavel removida: $var"
        }
    }
} catch {
    Write-Warning "Erro ao limpar variaveis: $_"
}

Write-Step "Verificando remocao..."
$serviceFinal = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
$installExists = Test-Path $InstallPath
$dataExists = Test-Path $DataPath

$tudo_removido = $true

if ($serviceFinal) {
    Write-Warning "Servico ainda existe"
    $tudo_removido = $false
} else {
    Write-Success "Servico removido"
}

if ($installExists) {
    Write-Warning "Arquivos de instalacao ainda existem"
    $tudo_removido = $false
} else {
    Write-Success "Arquivos de instalacao removidos"
}

if ($RemoveData) {
    if ($dataExists) {
        Write-Warning "Dados ainda existem"
        $tudo_removido = $false
    } else {
        Write-Success "Dados removidos"
    }
}

Write-Host "`n===============================================" -ForegroundColor Green
if ($tudo_removido) {
    Write-Host "  DESINSTALACAO CONCLUIDA!" -ForegroundColor Green
} else {
    Write-Host "  DESINSTALACAO PARCIAL" -ForegroundColor Yellow
}
Write-Host "===============================================" -ForegroundColor Green

Write-Host "`nResumo:" -ForegroundColor Cyan
Write-Host "   Servico: $(if ($serviceFinal) { 'Ainda existe' } else { 'Removido' })" -ForegroundColor $(if ($serviceFinal) { 'Yellow' } else { 'Green' })
Write-Host "   Instalacao: $(if ($installExists) { 'Ainda existe' } else { 'Removida' })" -ForegroundColor $(if ($installExists) { 'Yellow' } else { 'Green' })
if ($RemoveData) {
    Write-Host "   Dados: $(if ($dataExists) { 'Ainda existem' } else { 'Removidos' })" -ForegroundColor $(if ($dataExists) { 'Yellow' } else { 'Green' })
    if ($KeepBackup -and (Test-Path (Join-Path $env:USERPROFILE "Desktop\Solis_Backup_*"))) {
        Write-Host "   Backup: Salvo na Area de Trabalho" -ForegroundColor Green
    }
} else {
    Write-Host "   Dados: Preservados em $DataPath" -ForegroundColor Green
}

if (-not $tudo_removido) {
    Write-Host "`nAcoes necessarias:" -ForegroundColor Yellow
    if ($serviceFinal) {
        Write-Host "   - Remover servico manualmente: sc.exe delete $ServiceName" -ForegroundColor Gray
    }
    if ($installExists) {
        Write-Host "   - Remover pasta: Remove-Item '$InstallPath' -Recurse -Force" -ForegroundColor Gray
    }
    if ($RemoveData -and $dataExists) {
        Write-Host "   - Remover dados: Remove-Item '$DataPath' -Recurse -Force" -ForegroundColor Gray
    }
}

Write-Host ""
