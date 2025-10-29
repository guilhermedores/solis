#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Menu interativo para gerenciar o Solis Agente PDV

.DESCRIPTION
    Interface de linha de comando para facilitar operações comuns
#>

param(
    [string]$ServiceName = "SolisAgentePDV"
)

$installPath = "C:\Solis\AgentePDV"
$apiUrl = "http://localhost:5000"

function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                            ║" -ForegroundColor Cyan
    Write-Host "║      SOLIS - GERENCIADOR DO AGENTE         ║" -ForegroundColor Cyan
    Write-Host "║                                            ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Mostrar status
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        $statusColor = if ($service.Status -eq "Running") { "Green" } else { "Red" }
        Write-Host "Status: " -NoNewline
        Write-Host $service.Status -ForegroundColor $statusColor
        Write-Host ""
    } else {
        Write-Host "Status: " -NoNewline
        Write-Host "NÃO INSTALADO" -ForegroundColor Red
        Write-Host ""
    }
}

function Show-Menu {
    Write-Host "OPERAÇÕES:" -ForegroundColor Yellow
    Write-Host "  1. Iniciar serviço" -ForegroundColor White
    Write-Host "  2. Parar serviço" -ForegroundColor White
    Write-Host "  3. Reiniciar serviço" -ForegroundColor White
    Write-Host "  4. Ver logs ao vivo" -ForegroundColor White
    Write-Host "  5. Ver status detalhado" -ForegroundColor White
    Write-Host "  6. Testar API (Health Check)" -ForegroundColor White
    Write-Host "  7. Testar impressora" -ForegroundColor White
    Write-Host "  8. Abrir gaveta" -ForegroundColor White
    Write-Host "  9. Ver últimos eventos" -ForegroundColor White
    Write-Host " 10. Editar configuração" -ForegroundColor White
    Write-Host " 11. Backup do banco de dados" -ForegroundColor White
    Write-Host " 12. Executar diagnóstico completo" -ForegroundColor White
    Write-Host "  0. Sair" -ForegroundColor Gray
    Write-Host ""
}

function Start-AgentService {
    Write-Host "`n▶️  Iniciando serviço..." -ForegroundColor Cyan
    try {
        Start-Service -Name $ServiceName -ErrorAction Stop
        Start-Sleep -Seconds 2
        Write-Host "✅ Serviço iniciado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao iniciar: $_" -ForegroundColor Red
    }
    Pause
}

function Stop-AgentService {
    Write-Host "`n⏸️  Parando serviço..." -ForegroundColor Yellow
    try {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Host "✅ Serviço parado!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao parar: $_" -ForegroundColor Red
    }
    Pause
}

function Restart-AgentService {
    Write-Host "`n🔄 Reiniciando serviço..." -ForegroundColor Cyan
    try {
        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Write-Host "✅ Serviço reiniciado!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao reiniciar: $_" -ForegroundColor Red
    }
    Pause
}

function Show-Logs {
    Write-Host "`n📄 Mostrando logs ao vivo (Ctrl+C para sair)..." -ForegroundColor Cyan
    $logFile = "$installPath\logs\agente-pdv-$(Get-Date -Format 'yyyyMMdd').txt"
    if (Test-Path $logFile) {
        Get-Content $logFile -Wait
    } else {
        Write-Host "❌ Arquivo de log não encontrado: $logFile" -ForegroundColor Red
        Pause
    }
}

function Show-DetailedStatus {
    Write-Host "`n📊 Status Detalhado:" -ForegroundColor Cyan
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        $service | Format-List Name, DisplayName, Status, StartType, ServiceType
        
        Write-Host "`nProcesso:" -ForegroundColor Cyan
        $process = Get-Process | Where-Object { $_.ProcessName -eq "Solis.AgentePDV" }
        if ($process) {
            $process | Format-Table ProcessName, Id, CPU, WorkingSet, StartTime -AutoSize
        } else {
            Write-Host "Processo não encontrado" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Serviço não instalado" -ForegroundColor Red
    }
    Pause
}

function Test-ApiHealth {
    Write-Host "`n🧪 Testando API..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/health" -TimeoutSec 5
        Write-Host "✅ API respondendo!" -ForegroundColor Green
        $response | ConvertTo-Json | Write-Host
    } catch {
        Write-Host "❌ API não está respondendo: $_" -ForegroundColor Red
    }
    Pause
}

function Test-Printer {
    Write-Host "`n🖨️  Enviando impressão de teste..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/api/perifericos/impressora/teste" -Method Post -TimeoutSec 10
        Write-Host "✅ Comando enviado!" -ForegroundColor Green
        Write-Host "Verifique se a impressora imprimiu o cupom de teste." -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erro ao testar impressora: $_" -ForegroundColor Red
    }
    Pause
}

function Open-CashDrawer {
    Write-Host "`n💰 Abrindo gaveta..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/api/perifericos/gaveta/abrir" -Method Post -TimeoutSec 10
        Write-Host "✅ Comando enviado!" -ForegroundColor Green
        Write-Host "Verifique se a gaveta abriu." -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erro ao abrir gaveta: $_" -ForegroundColor Red
    }
    Pause
}

function Show-Events {
    Write-Host "`n📋 Últimos 20 eventos:" -ForegroundColor Cyan
    try {
        $events = Get-EventLog -LogName Application -Source "Solis.AgentePDV" -Newest 20 -ErrorAction Stop
        $events | Format-Table TimeGenerated, EntryType, Message -AutoSize -Wrap
    } catch {
        Write-Host "Nenhum evento encontrado" -ForegroundColor Yellow
    }
    Pause
}

function Edit-Configuration {
    Write-Host "`n⚙️  Abrindo configuração no Notepad..." -ForegroundColor Cyan
    $configPath = "$installPath\appsettings.json"
    if (Test-Path $configPath) {
        notepad $configPath
        Write-Host "`n⚠️  Reinicie o serviço para aplicar as mudanças!" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Arquivo de configuração não encontrado: $configPath" -ForegroundColor Red
    }
    Pause
}

function Backup-Database {
    Write-Host "`n💾 Fazendo backup do banco de dados..." -ForegroundColor Cyan
    $dbPath = "C:\ProgramData\Solis\agente-pdv.db"
    $backupPath = "C:\ProgramData\Solis\Backups"
    
    if (Test-Path $dbPath) {
        New-Item -ItemType Directory -Force -Path $backupPath | Out-Null
        $backupFile = "$backupPath\agente-pdv-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').db"
        
        try {
            Copy-Item $dbPath $backupFile -ErrorAction Stop
            Write-Host "✅ Backup criado: $backupFile" -ForegroundColor Green
            $size = (Get-Item $backupFile).Length / 1KB
            Write-Host "   Tamanho: $([math]::Round($size, 2)) KB" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erro ao criar backup: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Banco de dados não encontrado: $dbPath" -ForegroundColor Red
    }
    Pause
}

function Run-Diagnostics {
    Write-Host "`n🔍 Executando diagnóstico completo..." -ForegroundColor Cyan
    $scriptPath = Join-Path (Split-Path -Parent $PSScriptRoot) "scripts\testar-agente.ps1"
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Host "❌ Script de diagnóstico não encontrado: $scriptPath" -ForegroundColor Red
    }
    Pause
}

# Loop principal
while ($true) {
    Show-Banner
    Show-Menu
    
    $choice = Read-Host "Escolha uma opção"
    
    switch ($choice) {
        "1" { Start-AgentService }
        "2" { Stop-AgentService }
        "3" { Restart-AgentService }
        "4" { Show-Logs }
        "5" { Show-DetailedStatus }
        "6" { Test-ApiHealth }
        "7" { Test-Printer }
        "8" { Open-CashDrawer }
        "9" { Show-Events }
        "10" { Edit-Configuration }
        "11" { Backup-Database }
        "12" { Run-Diagnostics }
        "0" {
            Write-Host "`nEncerrando..." -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host "`n❌ Opção inválida!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
