# Limpeza do Monorepo
$baseDir = "C:\Users\Guilherme Batista\Solis"
cd $baseDir

Write-Host "Limpeza do Monorepo Solis" -ForegroundColor Cyan
Write-Host ""
$confirmation = Read-Host "Remover pastas dos projetos? (S/N)"
if ($confirmation -ne "S") { exit }

# Remover pastas
Write-Host "Removendo pastas..." -ForegroundColor Yellow
Remove-Item -Recurse -Force "solis-api", "solis-pwa", "solis-admin", "agente-pdv", "volumes", "database", ".vs" -ErrorAction SilentlyContinue

# Remover arquivos
Write-Host "Removendo arquivos..." -ForegroundColor Yellow
Remove-Item -Force "docker-compose.yml", "docker-compose.dev.yml", "Makefile", "Solis.sln", ".env", "produto-teste.json" -ErrorAction SilentlyContinue

# Atualizar README
Write-Host "Atualizando README..." -ForegroundColor Yellow
if (Test-Path "README-NOVO.md") {
    Copy-Item "README.md" "README-OLD.md"
    Copy-Item "README-NOVO.md" "README.md" -Force
    Remove-Item "README-NOVO.md"
}

# Criar pasta docs
New-Item -ItemType Directory -Force "docs" | Out-Null

# Commit
Write-Host "Criando commit..." -ForegroundColor Yellow
git add .
git commit -m "docs: transform monorepo into documentation repository"

Write-Host ""
Write-Host "Concluido!" -ForegroundColor Green
Write-Host "Execute: git push origin main" -ForegroundColor Yellow
