# Push de repositórios para GitHub
$ErrorActionPreference = "Continue"
$reposDir = "C:\Users\Guilherme Batista\solis-repos"
$githubUser = "guilhermedores"
$repos = @("solis-api", "solis-pwa", "solis-admin", "solis-agente")

Write-Host "Push de Repositórios para GitHub" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "Deseja continuar? (S/N)"
if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host "Operação cancelada." -ForegroundColor Red
    exit 0
}

foreach ($repo in $repos) {
    Write-Host ""
    Write-Host "Processando: $repo" -ForegroundColor Yellow
    
    $repoPath = Join-Path $reposDir $repo
    Push-Location $repoPath
    
    git add .
    git commit -m "Initial commit - separated from monorepo"
    git branch -M main
    git remote add origin "https://github.com/$githubUser/$repo.git"
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " $repo enviado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host " Erro ao enviar $repo" -ForegroundColor Red
    }
    
    Pop-Location
}

Write-Host ""
Write-Host "Concluído!" -ForegroundColor Green
