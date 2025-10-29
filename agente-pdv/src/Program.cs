using Solis.AgentePDV;
using Solis.AgentePDV.Data;
using Solis.AgentePDV.Services;
using Solis.AgentePDV.Extensions;
using Microsoft.EntityFrameworkCore;
using Serilog;

// Configurar Serilog com caminho absoluto para logs
var logPath = Path.Combine(AppContext.BaseDirectory, "logs", "agente-pdv-.txt");
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File(logPath, rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Iniciando Agente PDV...");

    var builder = WebApplication.CreateBuilder(args);

    // Configurar para rodar como Windows Service
    builder.Host.UseWindowsService();

    // Configurar Serilog
    builder.Host.UseSerilog();

    // Configuração de CORS para multi-tenant
    builder.Services.AddSolisCors(builder.Configuration, builder.Environment);

    // Adicionar controllers com configuração JSON para evitar ciclos
    builder.Services.AddControllers()
        .AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        });
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    // Configurar banco de dados local (SQLite)
    var sqliteConnection = builder.Configuration.GetConnectionString("LocalDb") 
        ?? "Data Source=agente-pdv.db";
    
    builder.Services.AddDbContext<LocalDbContext>(options =>
        options.UseSqlite(sqliteConnection));
    
    // Adicionar DbContextFactory para o OutboxService
    builder.Services.AddDbContextFactory<LocalDbContext>(options =>
        options.UseSqlite(sqliteConnection));

    // Configurar HttpClient para comunicação com Solis API
    builder.Services.AddHttpClient("SolisApi", client =>
    {
        var apiUrl = builder.Configuration["SolisApi:BaseUrl"] ?? "http://solis-api:3000";
        client.BaseAddress = new Uri(apiUrl);
        client.Timeout = TimeSpan.FromSeconds(30);
    });

    // Registrar serviços
    builder.Services.AddScoped<IVendaService, VendaService>();
    builder.Services.AddScoped<IProdutoService, ProdutoService>();
    builder.Services.AddScoped<IPrecoService, PrecoService>();
    builder.Services.AddScoped<IOutboxService, OutboxService>();
    builder.Services.AddScoped<ICaixaService, CaixaService>();
    builder.Services.AddScoped<IFormaPagamentoService, FormaPagamentoService>();
    builder.Services.AddScoped<IStatusVendaService, StatusVendaService>();
    builder.Services.AddScoped<SincronizacaoFiscalService>();
    builder.Services.AddSingleton<IImpressoraService, ImpressoraService>();
    builder.Services.AddSingleton<IGavetaService, GavetaService>();
    builder.Services.AddSingleton<IPerifericoService, PerifericoService>();
    
    // Background Services
    builder.Services.AddHostedService<OutboxProcessorService>();
    builder.Services.AddHostedService<HealthCheckService>();
    builder.Services.AddHostedService<SyncService>();

    var app = builder.Build();

    // Garantir que o banco de dados local está criado e configurado
    app.EnsureLocalDatabaseCreated();

    // Configure the HTTP request pipeline
    // Habilitar Swagger em todos os ambientes (útil para desenvolvimento e testes locais)
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Solis Agente PDV API v1");
        c.RoutePrefix = "swagger"; // Acesso em: http://localhost:5000/swagger
    });

    app.UseCors("AllowPWA");
    
    // Não usar HTTPS redirect em localhost
    // app.UseHttpsRedirection();

    app.UseAuthorization();

    app.MapControllers();

    // Endpoint de health check
    app.MapGet("/health", () => new
    {
        status = "healthy",
        timestamp = DateTime.UtcNow,
        service = "Agente PDV",
        version = "1.0.0"
    });

    Log.Information("Agente PDV iniciado com sucesso na porta 5000");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Erro fatal ao iniciar Agente PDV");
}
finally
{
    Log.CloseAndFlush();
}