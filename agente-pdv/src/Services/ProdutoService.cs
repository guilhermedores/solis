using Solis.AgentePDV.Data;
using Solis.AgentePDV.Models;
using Microsoft.EntityFrameworkCore;

namespace Solis.AgentePDV.Services;

public class ProdutoService : IProdutoService
{
    private readonly LocalDbContext _context;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<ProdutoService> _logger;

    public ProdutoService(LocalDbContext context, IHttpClientFactory httpClientFactory, ILogger<ProdutoService> logger)
    {
        _context = context;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<Produto?> BuscarPorCodigoBarrasAsync(string codigoBarras)
    {
        var produto = await _context.Produtos.Include(p => p.PrecoAtual).FirstOrDefaultAsync(p => p.CodigoBarras == codigoBarras && p.Ativo);
        if (produto != null) _logger.LogInformation("Produto encontrado: {CodigoBarras} - {Nome}", codigoBarras, produto.Nome);
        else _logger.LogWarning("Produto nao encontrado: {CodigoBarras}", codigoBarras);
        return produto;
    }

    public async Task<Produto?> BuscarPorIdAsync(Guid id)
    {
        return await _context.Produtos.Include(p => p.PrecoAtual).FirstOrDefaultAsync(p => p.Id == id && p.Ativo);
    }

    public async Task<IEnumerable<Produto>> BuscarPorNomeAsync(string termo)
    {
        return await _context.Produtos.Include(p => p.PrecoAtual).Where(p => EF.Functions.Like(p.Nome, $"%{termo}%") && p.Ativo).OrderBy(p => p.Nome).Take(20).ToListAsync();
    }

    public async Task<IEnumerable<Produto>> ListarProdutosAsync(int skip, int take)
    {
        return await _context.Produtos.Include(p => p.PrecoAtual).Where(p => p.Ativo).OrderBy(p => p.Nome).Skip(skip).Take(take).ToListAsync();
    }

    public async Task<bool> VerificarDisponibilidadeAsync(Guid produtoId, decimal quantidade)
    {
        var produto = await BuscarPorIdAsync(produtoId);
        if (produto == null || !produto.Ativo) return false;
        return true;
    }

    public async Task SincronizarProdutosAsync()
    {
        var client = _httpClientFactory.CreateClient("SolisApi");
        try
        {
            _logger.LogInformation("Iniciando sincronizacao de produtos...");
            var response = await client.GetAsync("/api/produtos/sincronizacao");
            if (!response.IsSuccessStatusCode) throw new Exception($"Erro ao obter produtos da nuvem: {response.StatusCode}");
            var dadosSincronizacao = await response.Content.ReadFromJsonAsync<SincronizacaoProdutos>();
            if (dadosSincronizacao == null)
            {
                _logger.LogWarning("Nenhum dado retornado da nuvem");
                return;
            }
            if (dadosSincronizacao.Produtos != null)
            {
                foreach (var produtoNuvem in dadosSincronizacao.Produtos)
                {
                    var produtoLocal = await _context.Produtos.FirstOrDefaultAsync(p => p.Id == produtoNuvem.Id);
                    if (produtoLocal == null) _context.Produtos.Add(produtoNuvem);
                    else
                    {
                        produtoLocal.Nome = produtoNuvem.Nome;
                        produtoLocal.Descricao = produtoNuvem.Descricao;
                        produtoLocal.CodigoBarras = produtoNuvem.CodigoBarras;
                        produtoLocal.CodigoInterno = produtoNuvem.CodigoInterno;
                        produtoLocal.NCM = produtoNuvem.NCM;
                        produtoLocal.CEST = produtoNuvem.CEST;
                        produtoLocal.UnidadeMedida = produtoNuvem.UnidadeMedida;
                        produtoLocal.Ativo = produtoNuvem.Ativo;
                        produtoLocal.AtualizadoEm = DateTime.UtcNow;
                        produtoLocal.SincronizadoEm = DateTime.UtcNow;
                    }
                }
            }
            if (dadosSincronizacao.Precos != null)
            {
                foreach (var precoNuvem in dadosSincronizacao.Precos)
                {
                    var precoLocal = await _context.ProdutoPrecos.FirstOrDefaultAsync(p => p.ProdutoId == precoNuvem.ProdutoId);
                    if (precoLocal == null) _context.ProdutoPrecos.Add(precoNuvem);
                    else
                    {
                        precoLocal.PrecoVenda = precoNuvem.PrecoVenda;
                        precoLocal.Ativo = precoNuvem.Ativo;
                        precoLocal.AtualizadoEm = DateTime.UtcNow;
                        precoLocal.SincronizadoEm = DateTime.UtcNow;
                    }
                }
            }
            await _context.SaveChangesAsync();
            _logger.LogInformation("Sincronizacao concluida: {Produtos} produtos, {Precos} precos", dadosSincronizacao.Produtos?.Count ?? 0, dadosSincronizacao.Precos?.Count ?? 0);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao sincronizar produtos");
            throw;
        }
    }
}

public class SincronizacaoProdutos
{
    public List<Produto>? Produtos { get; set; }
    public List<ProdutoPreco>? Precos { get; set; }
}