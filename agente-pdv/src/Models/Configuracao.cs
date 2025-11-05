namespace Solis.AgentePDV.Models;

/// <summary>
/// Configuração do terminal/PDV
/// Armazena configurações locais do ponto de venda e autenticação com a API
/// </summary>
public class Configuracao
{
    public int Id { get; set; }
    
    // Configurações gerais (chave-valor)
    public string Chave { get; set; } = string.Empty;
    public string Valor { get; set; } = string.Empty;
    
    // Autenticação e vinculação com tenant
    /// <summary>
    /// Token JWT para autenticação com a API Solis
    /// </summary>
    public string? Token { get; set; }
    
    /// <summary>
    /// ID do tenant (cliente) ao qual este agente está vinculado
    /// </summary>
    public string? TenantId { get; set; }
    
    /// <summary>
    /// Data de expiração do token JWT
    /// </summary>
    public DateTime? TokenValidoAte { get; set; }
    
    /// <summary>
    /// URL base da API Solis (exemplo: http://localhost:3000)
    /// </summary>
    public string? ApiBaseUrl { get; set; }
    
    /// <summary>
    /// Nome do agente/PDV (exemplo: "PDV Loja Centro")
    /// </summary>
    public string? NomeAgente { get; set; }
    
    public DateTime CriadoEm { get; set; }
    public DateTime AtualizadoEm { get; set; }
}
