# Script para transformar monorepo em repositório de documentação
# Execução: .\cleanup-monorepo.ps1
#
# IMPORTANTE: Execute DEPOIS de fazer push dos repositórios individuais

$ErrorActionPreference = "Stop"
$baseDir = "C:\Users\Guilherme Batista\Solis"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Limpeza do Monorepo Solis" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Confirmar antes de prosseguir
Write-Host "⚠️  ATENÇÃO: Este script irá:" -ForegroundColor Yellow
Write-Host "   • Remover pastas dos projetos (solis-api, solis-pwa, solis-admin, agente-pdv)" -ForegroundColor Gray
Write-Host "   • Remover arquivos de configuração do monorepo" -ForegroundColor Gray
Write-Host "   • Manter apenas documentação global" -ForegroundColor Gray
Write-Host "   • Atualizar README.md" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Certifique-se de que já fez push dos repositórios individuais!" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Deseja continuar? (S/N)"

if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host "❌ Operação cancelada." -ForegroundColor Red
    exit 0
}

Write-Host ""
Push-Location $baseDir

try {
    # 1. Remover pastas dos projetos
    Write-Host "1. Removendo pastas dos projetos..." -ForegroundColor Yellow
    
    $foldersToRemove = @(
        "solis-api",
        "solis-pwa",
        "solis-admin",
        "agente-pdv",
        "volumes",
        ".vs",
        "database"  # Vai para solis-api
    )
    
    foreach ($folder in $foldersToRemove) {
        $path = Join-Path $baseDir $folder
        if (Test-Path $path) {
            Write-Host "   Removendo: $folder" -ForegroundColor Gray
            Remove-Item -Path $path -Recurse -Force
            Write-Host "   ✓ $folder removido" -ForegroundColor Green
        } else {
            Write-Host "   ⏭️  $folder não existe" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    
    # 2. Remover arquivos específicos do monorepo
    Write-Host "2. Removendo arquivos de configuração do monorepo..." -ForegroundColor Yellow
    
    $filesToRemove = @(
        "docker-compose.yml",
        "docker-compose.dev.yml",
        "Makefile",
        "Solis.sln",
        ".env",
        "produto-teste.json"
    )
    
    foreach ($file in $filesToRemove) {
        $path = Join-Path $baseDir $file
        if (Test-Path $path) {
            Write-Host "   Removendo: $file" -ForegroundColor Gray
            Remove-Item -Path $path -Force
            Write-Host "   ✓ $file removido" -ForegroundColor Green
        } else {
            Write-Host "   ⏭️  $file não existe" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    
    # 3. Atualizar README.md
    Write-Host "3. Atualizando README.md..." -ForegroundColor Yellow
    
    $readmeNovo = Join-Path $baseDir "README-NOVO.md"
    $readmeAtual = Join-Path $baseDir "README.md"
    
    if (Test-Path $readmeNovo) {
        # Fazer backup do README atual
        if (Test-Path $readmeAtual) {
            $backupPath = Join-Path $baseDir "README-OLD-BACKUP.md"
            Write-Host "   Backup do README atual: README-OLD-BACKUP.md" -ForegroundColor Gray
            Copy-Item -Path $readmeAtual -Destination $backupPath -Force
        }
        
        # Substituir README
        Write-Host "   Substituindo README.md" -ForegroundColor Gray
        Copy-Item -Path $readmeNovo -Destination $readmeAtual -Force
        Remove-Item -Path $readmeNovo -Force
        Write-Host "   ✓ README.md atualizado" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  README-NOVO.md não encontrado" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # 4. Criar estrutura de documentação
    Write-Host "4. Organizando documentação..." -ForegroundColor Yellow
    
    # Criar pasta docs se não existir
    $docsDir = Join-Path $baseDir "docs"
    if (-not (Test-Path $docsDir)) {
        New-Item -ItemType Directory -Path $docsDir | Out-Null
        Write-Host "   ✓ Pasta docs/ criada" -ForegroundColor Green
    }
    
    # Mover documentos para pasta docs
    $docsToMove = @(
        "ARCHITECTURE.md",
        "TENANT_MANAGEMENT.md",
        "SECURITY_HTTPS_LOCAL.md",
        "INSTALACAO_TECNICO.md",
        "QUICKSTART.md",
        "PROJECT.md",
        "SUMMARY.md"
    )
    
    foreach ($doc in $docsToMove) {
        $sourcePath = Join-Path $baseDir $doc
        $destPath = Join-Path $docsDir $doc
        
        if (Test-Path $sourcePath) {
            Write-Host "   Movendo: $doc → docs/" -ForegroundColor Gray
            Move-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "   ✓ $doc movido" -ForegroundColor Green
        }
    }
    Write-Host ""
    
    # 5. Criar INDEX.md para documentação
    Write-Host "5. Criando índice de documentação..." -ForegroundColor Yellow
    
    $indexContent = @"
# Índice da Documentação Solis

Este repositório contém a documentação global do ecossistema Solis.

## 📚 Documentação por Categoria

### Arquitetura
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Visão geral da arquitetura do sistema
- [TENANT_MANAGEMENT.md](./TENANT_MANAGEMENT.md) - Gestão de multi-tenancy
- [PROJECT.md](./PROJECT.md) - Estrutura e organização do projeto

### Instalação e Configuração
- [INSTALACAO_TECNICO.md](./INSTALACAO_TECNICO.md) - Guia completo para técnicos de campo
- [QUICKSTART.md](./QUICKSTART.md) - Início rápido para desenvolvimento

### Segurança
- [SECURITY_HTTPS_LOCAL.md](./SECURITY_HTTPS_LOCAL.md) - Segurança em ambiente local

### Visão Geral
- [SUMMARY.md](./SUMMARY.md) - Resumo executivo do projeto

## 🔗 Repositórios do Projeto

- [solis-api](https://github.com/guilhermedores/solis-api) - API REST backend
- [solis-pwa](https://github.com/guilhermedores/solis-pwa) - Progressive Web App do PDV
- [solis-admin](https://github.com/guilhermedores/solis-admin) - Painel administrativo
- [solis-agente](https://github.com/guilhermedores/solis-agente) - Agente local Windows

## 🤝 Contribuindo

Para contribuir com a documentação, veja [CONTRIBUTING.md](../CONTRIBUTING.md).

## 📞 Suporte

Para questões específicas de código, abra issues nos repositórios correspondentes.
Para questões sobre documentação, abra issues neste repositório.
"@
    
    $indexPath = Join-Path $docsDir "INDEX.md"
    $indexContent | Out-File -FilePath $indexPath -Encoding UTF8
    Write-Host "   ✓ docs/INDEX.md criado" -ForegroundColor Green
    Write-Host ""
    
    # 6. Atualizar .gitignore
    Write-Host "6. Atualizando .gitignore..." -ForegroundColor Yellow
    
    $gitignoreContent = @"
# Editor
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Backups
*-BACKUP.md
*-OLD.md

# Temporary
temp/
tmp/
"@
    
    $gitignorePath = Join-Path $baseDir ".gitignore"
    $gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
    Write-Host "   ✓ .gitignore atualizado" -ForegroundColor Green
    Write-Host ""
    
    # 7. Criar commit das mudanças
    Write-Host "7. Preparando commit..." -ForegroundColor Yellow
    
    Write-Host "   → git add ." -ForegroundColor Gray
    git add .
    
    Write-Host "   → git commit" -ForegroundColor Gray
    git commit -m "docs: transform monorepo into documentation repository

- Remove project folders (moved to individual repos)
- Keep only global documentation
- Organize docs in docs/ folder
- Update README with links to new repositories"
    
    Write-Host "   ✓ Commit criado" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  Limpeza Concluída!" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Repositório transformado em documentação global" -ForegroundColor Green
    Write-Host ""
    Write-Host "Estrutura final:" -ForegroundColor Yellow
    Write-Host "  solis/" -ForegroundColor White
    Write-Host "  ├── docs/              (documentação organizada)" -ForegroundColor Gray
    Write-Host "  │   ├── INDEX.md" -ForegroundColor Gray
    Write-Host "  │   ├── ARCHITECTURE.md" -ForegroundColor Gray
    Write-Host "  │   └── ..." -ForegroundColor Gray
    Write-Host "  ├── README.md          (documentação principal)" -ForegroundColor Gray
    Write-Host "  └── CONTRIBUTING.md    (guia de contribuição)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Próximo passo:" -ForegroundColor Yellow
    Write-Host "  git push origin main" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "❌ Erro durante limpeza: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Se algo deu errado, você pode:" -ForegroundColor Yellow
    Write-Host "  1. Restaurar do backup: git reset --hard HEAD~1" -ForegroundColor Gray
    Write-Host "  2. Verificar README-OLD-BACKUP.md" -ForegroundColor Gray
}
finally {
    Pop-Location
}
