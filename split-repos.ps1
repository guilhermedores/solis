# Script para separar monorepo Solis
param()

$ErrorActionPreference = "Stop"
$baseDir = "C:\Users\Guilherme Batista"
$reposDir = Join-Path $baseDir "solis-repos"

Write-Host "Separando Monorepo Solis" -ForegroundColor Cyan

if (Test-Path $reposDir) {
    Remove-Item -Recurse -Force $reposDir
}
New-Item -ItemType Directory -Path $reposDir | Out-Null

# Copiar solis-api
Write-Host "Criando solis-api..." -ForegroundColor Yellow
$apiPath = Join-Path $reposDir "solis-api"
Copy-Item -Path "solis-api" -Destination $apiPath -Recurse -Force
Copy-Item -Path "database" -Destination $apiPath -Recurse -Force
Copy-Item -Path ".gitignore" -Destination $apiPath -Force
Push-Location $apiPath
git init | Out-Null
Pop-Location

# Copiar solis-pwa
Write-Host "Criando solis-pwa..." -ForegroundColor Yellow
$pwaPath = Join-Path $reposDir "solis-pwa"
Copy-Item -Path "solis-pwa" -Destination $pwaPath -Recurse -Force
Copy-Item -Path ".gitignore" -Destination $pwaPath -Force
Push-Location $pwaPath
git init | Out-Null
Pop-Location

# Copiar solis-admin
Write-Host "Criando solis-admin..." -ForegroundColor Yellow
$adminPath = Join-Path $reposDir "solis-admin"
Copy-Item -Path "solis-admin" -Destination $adminPath -Recurse -Force
Copy-Item -Path ".gitignore" -Destination $adminPath -Force
Push-Location $adminPath
git init | Out-Null
Pop-Location

# Copiar solis-agente
Write-Host "Criando solis-agente..." -ForegroundColor Yellow
$agentePath = Join-Path $reposDir "solis-agente"
Copy-Item -Path "agente-pdv" -Destination $agentePath -Recurse -Force
Copy-Item -Path ".gitignore" -Destination $agentePath -Force
Push-Location $agentePath
git init | Out-Null
Pop-Location

Write-Host ""
Write-Host "Concluído! Repositórios criados em: $reposDir" -ForegroundColor Green
