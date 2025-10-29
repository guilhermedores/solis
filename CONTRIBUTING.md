# 🤝 Guia de Contribuição - Sistema Solis PDV

Obrigado por considerar contribuir com o Sistema Solis PDV! Este documento fornece diretrizes para contribuir com o projeto.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Estrutura de Branches](#estrutura-de-branches)
- [Padrões de Commit](#padrões-de-commit)
- [Padrões de Código](#padrões-de-código)
- [Testes](#testes)
- [Pull Requests](#pull-requests)

## 📜 Código de Conduta

### Nossos Compromissos

- Ser respeitoso e inclusivo
- Aceitar críticas construtivas
- Focar no que é melhor para a comunidade
- Mostrar empatia com outros membros

### Comportamentos Inaceitáveis

- Linguagem ou imagens sexualizadas
- Trolling, insultos ou comentários depreciativos
- Assédio público ou privado
- Publicar informações privadas de terceiros

## 🚀 Como Contribuir

### 1. Reportar Bugs

Antes de reportar um bug, verifique se já não existe uma issue aberta.

**Template de Bug Report**:
```markdown
**Descrição do Bug**
Uma descrição clara e concisa do bug.

**Como Reproduzir**
Passos para reproduzir:
1. Vá para '...'
2. Clique em '...'
3. Role até '...'
4. Veja o erro

**Comportamento Esperado**
O que você esperava que acontecesse.

**Screenshots**
Se aplicável, adicione screenshots.

**Ambiente**
- OS: [ex: Windows 11]
- Browser: [ex: Chrome 118]
- Versão: [ex: 1.0.0]
```

### 2. Sugerir Melhorias

Use o template de Feature Request:

```markdown
**Sua sugestão está relacionada a um problema?**
Uma descrição clara do problema.

**Descreva a solução que você gostaria**
Uma descrição clara da solução.

**Descreva alternativas consideradas**
Outras soluções ou features consideradas.

**Contexto adicional**
Qualquer outro contexto sobre a feature.
```

### 3. Implementar Features/Fixes

1. Fork o repositório
2. Crie uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 🌿 Estrutura de Branches

### Branch Principal

- `main` - Código em produção, sempre estável

### Branches de Desenvolvimento

- `develop` - Branch de desenvolvimento principal
- `feature/*` - Novas features
- `bugfix/*` - Correções de bugs
- `hotfix/*` - Correções urgentes para produção
- `release/*` - Preparação de releases

### Exemplo

```bash
# Nova feature
git checkout develop
git checkout -b feature/cadastro-clientes

# Bugfix
git checkout develop
git checkout -b bugfix/correcao-calculo-desconto

# Hotfix
git checkout main
git checkout -b hotfix/erro-critico-pagamento
```

## 📝 Padrões de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/).

### Formato

```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos

- `feat`: Nova feature
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação (não afeta código)
- `refactor`: Refatoração
- `perf`: Melhoria de performance
- `test`: Adiciona/corrige testes
- `chore`: Manutenção, configs

### Exemplos

```bash
# Feature
git commit -m "feat(produtos): adiciona busca por código de barras"

# Fix
git commit -m "fix(vendas): corrige cálculo de desconto em %"

# Docs
git commit -m "docs(readme): atualiza instruções de instalação"

# Refactor
git commit -m "refactor(api): simplifica lógica de autenticação"

# Breaking change
git commit -m "feat(api)!: altera estrutura de resposta de produtos

BREAKING CHANGE: campo 'valor' renomeado para 'preco_venda'"
```

## 💻 Padrões de Código

### JavaScript/Node.js

```javascript
// ✅ Bom
const calcularTotal = (itens) => {
  return itens.reduce((total, item) => total + item.valor, 0);
};

// ❌ Ruim
function calcular(i) {
  var t = 0;
  for(var x=0;x<i.length;x++) {
    t = t + i[x].valor;
  }
  return t;
}
```

**Diretrizes**:
- Use `const` e `let`, evite `var`
- Arrow functions quando possível
- Nomes descritivos
- Funções pequenas e focadas
- Evite comentários óbvios

### C# / .NET

```csharp
// ✅ Bom
public decimal CalcularTotal(List<ItemVenda> itens)
{
    return itens.Sum(item => item.Valor);
}

// ❌ Ruim
public decimal calc(List<ItemVenda> i)
{
    decimal t = 0;
    foreach(var x in i) {
        t += x.Valor;
    }
    return t;
}
```

**Diretrizes**:
- PascalCase para métodos e classes
- camelCase para variáveis locais
- Async/await quando apropriado
- LINQ quando possível
- XML comments em métodos públicos

### React/JSX

```jsx
// ✅ Bom
const ProdutoCard = ({ produto }) => {
  const { nome, preco, imagem } = produto;
  
  return (
    <div className="produto-card">
      <img src={imagem} alt={nome} />
      <h3>{nome}</h3>
      <span>R$ {preco.toFixed(2)}</span>
    </div>
  );
};

// ❌ Ruim
function ProdutoCard(props) {
  return (
    <div>
      <img src={props.produto.imagem} />
      <h3>{props.produto.nome}</h3>
      <span>{props.produto.preco}</span>
    </div>
  );
}
```

**Diretrizes**:
- Componentes funcionais
- Hooks ao invés de classes
- Props destructuring
- PropTypes ou TypeScript
- Componentes pequenos e reutilizáveis

### SQL

```sql
-- ✅ Bom
SELECT 
    p.id,
    p.nome,
    p.preco_venda,
    c.nome AS categoria
FROM produtos p
INNER JOIN categorias c ON c.id = p.categoria_id
WHERE p.ativo = true
ORDER BY p.nome;

-- ❌ Ruim
select * from produtos where ativo=true
```

**Diretrizes**:
- Palavras-chave em UPPERCASE
- Indentação consistente
- Aliases descritivos
- Evite SELECT *
- Use JOIN explícito

## 🧪 Testes

### Estrutura de Testes

```javascript
describe('calcularTotal', () => {
  it('deve calcular total de itens corretamente', () => {
    // Arrange
    const itens = [
      { valor: 10.50 },
      { valor: 20.00 },
      { valor: 15.75 }
    ];
    
    // Act
    const total = calcularTotal(itens);
    
    // Assert
    expect(total).toBe(46.25);
  });
  
  it('deve retornar 0 para array vazio', () => {
    const itens = [];
    const total = calcularTotal(itens);
    expect(total).toBe(0);
  });
});
```

### Cobertura de Testes

- Mínimo de 80% de cobertura
- Testes unitários obrigatórios
- Testes de integração para APIs
- Testes E2E para fluxos críticos

### Executar Testes

```bash
# API
docker-compose exec solis-api npm test

# Com cobertura
docker-compose exec solis-api npm run test:coverage

# Watch mode
docker-compose exec solis-api npm run test:watch
```

## 🔍 Pull Requests

### Checklist

Antes de abrir um PR, verifique:

- [ ] Código segue os padrões do projeto
- [ ] Commits seguem Conventional Commits
- [ ] Testes passando
- [ ] Documentação atualizada
- [ ] Sem conflitos com `develop`
- [ ] PR com descrição clara

### Template de PR

```markdown
## Descrição
Breve descrição das mudanças.

## Tipo de Mudança
- [ ] Bug fix
- [ ] Nova feature
- [ ] Breaking change
- [ ] Documentação

## Como Testar
Passos para testar as mudanças:
1. ...
2. ...

## Screenshots
Se aplicável.

## Checklist
- [ ] Código testado localmente
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] Sem warnings no build
```

### Code Review

Todos os PRs passam por code review:

- Pelo menos 1 aprovação necessária
- CI/CD deve passar
- Sem conflitos
- Discussões devem ser resolvidas

### Mesclando PRs

- Use "Squash and merge" para features
- Use "Rebase and merge" para hotfixes
- Delete a branch após merge

## 📚 Recursos

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [JavaScript Style Guide](https://github.com/airbnb/javascript)
- [React Best Practices](https://react.dev/learn)

## 💬 Comunicação

- **Issues**: Para bugs e features
- **Discussions**: Para perguntas gerais
- **Email**: suporte@solis.com

## 🎉 Reconhecimento

Contribuidores serão listados no README.md e terão seus commits reconhecidos.

---

**Obrigado por contribuir! 🚀**
