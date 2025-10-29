param(
    [string]$ServiceName = "SolisAgentePDV",
    [string]$ApiUrl = "http://localhost:5000"
)

function Write-Section {
    param([string]$Title)
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
}

function Write-Test {
    param([string]$Name, [bool]$Passed, [string]$Details = "")
    $icon = if ($Passed) { "[OK]" } else { "[ERRO]" }
    $color = if ($Passed) { "Green" } else { "Red" }
    Write-Host "$icon $Name" -ForegroundColor $color
    if ($Details) {
        Write-Host "   $Details" -ForegroundColor Gray
    }
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  SOLIS - DIAGNOSTICO DO AGENTE PDV" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

Write-Section "1. Verificando .NET Runtime"
try {
    $dotnetVersion = dotnet --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Test ".NET Runtime instalado" $true $dotnetVersion
        $testsPassed++
    } else {
        Write-Test ".NET Runtime instalado" $false
        $testsFailed++
    }
} catch {
    Write-Test ".NET Runtime instalado" $false
    $testsFailed++
}

Write-Section "2. Verificando Servico do Windows"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Write-Test "Servico existe" $true "Nome: $ServiceName"
    $testsPassed++
    
    $running = $service.Status -eq "Running"
    Write-Test "Servico rodando" $running "Status: $($service.Status)"
    if ($running) { $testsPassed++ } else { $testsFailed++ }
} else {
    Write-Test "Servico existe" $false
    Write-Test "Servico rodando" $false
    $testsFailed += 2
}

Write-Section "3. Verificando Arquivos"
$installPath = "C:\Solis\AgentePDV"
$exePath = Join-Path $installPath "Solis.AgentePDV.exe"

$pathExists = Test-Path $installPath
Write-Test "Diretorio de instalacao" $pathExists $installPath
if ($pathExists) { $testsPassed++ } else { $testsFailed++ }

$exeExists = Test-Path $exePath
Write-Test "Executavel" $exeExists $exePath
if ($exeExists) { $testsPassed++ } else { $testsFailed++ }

Write-Section "4. Verificando Banco de Dados"
$dataPath = "C:\ProgramData\Solis"
$dbPath = Join-Path $dataPath "agente-pdv.db"

$dbExists = Test-Path $dbPath
Write-Test "Banco de dados SQLite" $dbExists $dbPath
if ($dbExists) { 
    $testsPassed++
    $dbSize = (Get-Item $dbPath).Length
    Write-Host "   Tamanho: $([math]::Round($dbSize/1KB, 2)) KB" -ForegroundColor Gray
} else { 
    $testsFailed++ 
}

Write-Section "5. Verificando Logs"
$logsPath = Join-Path $installPath "logs"
$logsExist = Test-Path $logsPath
Write-Test "Diretorio de logs" $logsExist $logsPath
if ($logsExist) {
    $testsPassed++
    $logFiles = Get-ChildItem $logsPath -Filter "*.txt" -ErrorAction SilentlyContinue
    if ($logFiles) {
        Write-Host "   Arquivos de log: $($logFiles.Count)" -ForegroundColor Gray
    }
} else {
    $testsFailed++
}

Write-Section "6. Verificando API REST"
if ($service -and $service.Status -eq "Running") {
    try {
        $response = Invoke-WebRequest -Uri "$ApiUrl/health" -TimeoutSec 5 -UseBasicParsing
        $apiOk = $response.StatusCode -eq 200
        Write-Test "API respondendo" $apiOk "$ApiUrl/health"
        if ($apiOk) { 
            $testsPassed++
            $content = $response.Content | ConvertFrom-Json
            Write-Host "   Status: $($content.status)" -ForegroundColor Gray
            Write-Host "   Versao: $($content.version)" -ForegroundColor Gray
        } else { 
            $testsFailed++ 
        }
    } catch {
        Write-Test "API respondendo" $false "$ApiUrl/health"
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
        $testsFailed++
    }
} else {
    Write-Test "API respondendo" $false "Servico nao esta rodando"
    $testsFailed++
}

Write-Section "7. Verificando Configuracao"
$configPath = Join-Path $installPath "src\appsettings.json"
$configExists = Test-Path $configPath
Write-Test "Arquivo de configuracao" $configExists $configPath
if ($configExists) {
    $testsPassed++
    try {
        $config = Get-Content $configPath | ConvertFrom-Json
        Write-Host "   API Nuvem: $($config.SolisApi.BaseUrl)" -ForegroundColor Gray
        Write-Host "   Sync Intervalo: $($config.Sync.IntervalSeconds)s" -ForegroundColor Gray
    } catch {
        Write-Host "   Aviso: Erro ao ler configuracao" -ForegroundColor Yellow
    }
} else {
    $testsFailed++
}

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  RESULTADO DO DIAGNOSTICO" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$total = $testsPassed + $testsFailed
$percentual = if ($total -gt 0) { [math]::Round(($testsPassed / $total) * 100, 0) } else { 0 }

Write-Host "`nTestes executados: $total" -ForegroundColor White
Write-Host "Passou: $testsPassed" -ForegroundColor Green
Write-Host "Falhou: $testsFailed" -ForegroundColor Red
Write-Host "Sucesso: $percentual%" -ForegroundColor $(if ($percentual -ge 80) { "Green" } elseif ($percentual -ge 50) { "Yellow" } else { "Red" })

if ($testsFailed -eq 0) {
    Write-Host "`n[OK] Sistema funcionando perfeitamente!" -ForegroundColor Green
} elseif ($percentual -ge 50) {
    Write-Host "`n[AVISO] Sistema com problemas, mas operacional" -ForegroundColor Yellow
} else {
    Write-Host "`n[ERRO] Sistema com problemas criticos!" -ForegroundColor Red
}

Write-Host ""