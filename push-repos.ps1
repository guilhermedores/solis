# Script para fazer push dos repositórios separados para o GitHub
# Execução: .\push-repos.ps1
# 
# IMPORTANTE: Execute este script DEPOIS de:
# 1. Executar .\split-repos.ps1
# 2. Criar os 4 repositórios no GitHub manualmente

$ErrorActionPreference = "Stop"
$reposDir = "C:\Users\Guilherme Batista\solis-repos"
$githubUser = "guilhermedores"

# Lista de repositórios
$repos = @(
    "solis-api",
    "solis-pwa",
    "solis-admin",
    "solis-agente"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Push de Repositórios para GitHub" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o diretório existe
if (-not (Test-Path $reposDir)) {
    Write-Host "❌ Erro: Diretório $reposDir não encontrado!" -ForegroundColor Red
    Write-Host "   Execute primeiro: .\split-repos.ps1" -ForegroundColor Yellow
    exit 1
}

# Confirmar antes de prosseguir
Write-Host "⚠️  Este script irá fazer push dos seguintes repositórios:" -ForegroundColor Yellow
foreach ($repo in $repos) {
    Write-Host "   → https://github.com/$githubUser/$repo" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Certifique-se de que você já criou esses repositórios no GitHub!" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Deseja continuar? (S/N)"

if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host "❌ Operação cancelada." -ForegroundColor Red
    exit 0
}

Write-Host ""

# Função para processar cada repositório
function Push-Repository {
    param(
        [string]$RepoName
    )
    
    $repoPath = Join-Path $reposDir $RepoName
    
    Write-Host "Processando: $RepoName" -ForegroundColor Yellow
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "   ❌ Pasta não encontrada: $repoPath" -ForegroundColor Red
        return $false
    }
    
    Push-Location $repoPath
    
    try {
        # Verificar se já existe remote
        $remoteExists = git remote get-url origin 2>$null
        
        if ($remoteExists) {
            Write-Host "   ℹ️  Remote 'origin' já existe: $remoteExists" -ForegroundColor Cyan
            $overwrite = Read-Host "   Deseja sobrescrever? (S/N)"
            
            if ($overwrite -eq "S" -or $overwrite -eq "s") {
                git remote remove origin
                Write-Host "   ✓ Remote removido" -ForegroundColor Green
            } else {
                Write-Host "   ⏭️  Pulando $RepoName" -ForegroundColor Yellow
                Pop-Location
                return $true
            }
        }
        
        # Adicionar todos os arquivos
        Write-Host "   → Adicionando arquivos..." -ForegroundColor Gray
        git add .
        
        # Verificar se há algo para commitar
        $status = git status --porcelain
        if ($status) {
            Write-Host "   → Criando commit..." -ForegroundColor Gray
            git commit -m "Initial commit - separated from monorepo"
        } else {
            # Se não há mudanças, verificar se já existe commit
            $hasCommits = git rev-parse HEAD 2>$null
            if (-not $hasCommits) {
                Write-Host "   ❌ Nenhum arquivo para commitar e nenhum commit existente" -ForegroundColor Red
                Pop-Location
                return $false
            }
            Write-Host "   ℹ️  Sem mudanças para commitar (usando commit existente)" -ForegroundColor Cyan
        }
        
        # Configurar branch main
        Write-Host "   → Configurando branch main..." -ForegroundColor Gray
        git branch -M main
        
        # Adicionar remote
        $remoteUrl = "https://github.com/$githubUser/$RepoName.git"
        Write-Host "   → Adicionando remote: $remoteUrl" -ForegroundColor Gray
        git remote add origin $remoteUrl
        
        # Push
        Write-Host "   → Fazendo push..." -ForegroundColor Gray
        git push -u origin main
        
        Write-Host "   ✅ $RepoName enviado com sucesso!" -ForegroundColor Green
        Write-Host ""
        
        Pop-Location
        return $true
    }
    catch {
        Write-Host "   ❌ Erro ao processar $RepoName : $_" -ForegroundColor Red
        Write-Host ""
        Pop-Location
        return $false
    }
}

# Processar cada repositório
$successCount = 0
$failCount = 0

foreach ($repo in $repos) {
    $result = Push-Repository -RepoName $repo
    
    if ($result) {
        $successCount++
    } else {
        $failCount++
    }
}

# Resumo
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Resumo Final" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Sucesso: $successCount repositório(s)" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "❌ Falha: $failCount repositório(s)" -ForegroundColor Red
}
Write-Host ""

if ($successCount -eq $repos.Count) {
    Write-Host "🎉 Todos os repositórios foram enviados com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "1. Verificar no GitHub se todos os repos estão ok" -ForegroundColor White
    Write-Host "2. Atualizar repositório 'solis' para documentação global:" -ForegroundColor White
    Write-Host "   cd 'C:\Users\Guilherme Batista\Solis'" -ForegroundColor Gray
    Write-Host "   .\cleanup-monorepo.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Links dos repositórios:" -ForegroundColor Yellow
    foreach ($repo in $repos) {
        Write-Host "   → https://github.com/$githubUser/$repo" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️  Alguns repositórios falharam. Verifique os erros acima." -ForegroundColor Yellow
}

Write-Host ""
