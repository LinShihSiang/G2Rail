using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using DoDoManBackOffice.Data;
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
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

// Identity Configuration
builder.Services.AddDefaultIdentity<IdentityUser>(options =>
{
    options.SignIn.RequireConfirmedAccount = false;
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
})
.AddEntityFrameworkStores<ApplicationDbContext>();

// Configuration Objects
builder.Services.Configure<N8NSettings>(builder.Configuration.GetSection("N8NSettings"));
builder.Services.Configure<AppSettings>(builder.Configuration.GetSection("ApplicationSettings"));

// Service Registration
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IN8NIntegrationService, N8NIntegrationService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

// HTTP Client for N8N Integration
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

// Database Migration
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    try
    {
        context.Database.EnsureCreated();
        Log.Information("Database ensured created successfully");
    }
    catch (Exception ex)
    {
        Log.Error(ex, "An error occurred while creating the database");
    }
}

Log.Information("DoDoMan BackOffice application starting up");

app.Run();