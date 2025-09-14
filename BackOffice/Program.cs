using Microsoft.AspNetCore.Identity;
using DoDoManBackOffice.Services;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Services.Implementations;
using DoDoManBackOffice.Configuration;
using Serilog;
using FluentValidation.AspNetCore;
using FluentValidation;

var builder = WebApplication.CreateBuilder(args);

// Serilog Configuration
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .WriteTo.Console()
    .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container.

// Identity Configuration (using in-memory store for demo)
builder.Services.AddDefaultIdentity<IdentityUser>(options =>
{
    options.SignIn.RequireConfirmedAccount = false;
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
})
.AddInMemoryStores();

// Configuration Objects
builder.Services.Configure<N8NSettings>(builder.Configuration.GetSection("N8NSettings"));
builder.Services.Configure<AppSettings>(builder.Configuration.GetSection("ApplicationSettings"));

// Service Registration
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IN8NIntegrationService, N8NIntegrationService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

// Add HTTP client for N8N API
builder.Services.AddHttpClient<IN8NApiService, N8NApiService>(client =>
{
    var n8nSettings = builder.Configuration.GetSection("N8NSettings");
    var baseUrl = n8nSettings["BaseUrl"];
    if (!string.IsNullOrEmpty(baseUrl))
    {
        client.BaseAddress = new Uri(baseUrl);
    }
    client.Timeout = TimeSpan.FromSeconds(int.Parse(n8nSettings["Timeout"] ?? "30"));

    // Add API key if configured
    var apiKey = n8nSettings["ApiKey"];
    if (!string.IsNullOrEmpty(apiKey))
    {
        client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
    }
});

// Register N8N API service
builder.Services.AddScoped<IN8NApiService, N8NApiService>();

// HTTP Client for N8N Integration (existing service)
builder.Services.AddHttpClient<IN8NIntegrationService>();

// FluentValidation
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Dashboard}/{action=Index}/{id?}");

app.MapRazorPages();

// N8N API connectivity check (optional)
try
{
    Log.Information("N8N API configuration loaded successfully");
}
catch (Exception ex)
{
    Log.Error(ex, "An error occurred while configuring N8N API");
}

Log.Information("DoDoMan BackOffice application starting up");

app.Run();