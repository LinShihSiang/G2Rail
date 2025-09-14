# 01. Project Setup and Configuration

## Overview
設定 DoDoMan Travel BackOffice Management System 的基礎專案架構和開發環境。

## Implementation Steps

### Step 1.1: Create New .NET Core Web Application
```bash
# Create new ASP.NET Core MVC project
dotnet new mvc -n DoDoManBackOffice -f net8.0

# Navigate to project directory
cd DoDoManBackOffice

# Add required NuGet packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.0
dotnet add package Microsoft.AspNetCore.Identity.UI --version 8.0.0
dotnet add package Newtonsoft.Json --version 13.0.3
dotnet add package Serilog.AspNetCore --version 8.0.0
dotnet add package Serilog.Sinks.File --version 6.0.0
dotnet add package FluentValidation.AspNetCore --version 11.3.0
```

### Step 1.2: Project Structure Setup
```
DoDoManBackOffice/
├── Controllers/
│   ├── HomeController.cs
│   ├── OrderController.cs
│   ├── DashboardController.cs
│   └── ApiController.cs
├── Models/
│   ├── Entities/
│   │   ├── Order.cs
│   │   ├── Customer.cs
│   │   └── OrderStatus.cs
│   ├── ViewModels/
│   │   ├── OrderViewModel.cs
│   │   ├── OrderListViewModel.cs
│   │   └── FilterViewModel.cs
│   └── DTOs/
│       ├── OrderDto.cs
│       └── CustomerDto.cs
├── Services/
│   ├── Interfaces/
│   │   ├── IOrderService.cs
│   │   ├── IN8NIntegrationService.cs
│   │   └── IPaymentService.cs
│   └── Implementations/
│       ├── OrderService.cs
│       ├── N8NIntegrationService.cs
│       └── PaymentService.cs
├── Data/
│   ├── ApplicationDbContext.cs
│   ├── Configurations/
│   │   ├── OrderConfiguration.cs
│   │   └── CustomerConfiguration.cs
│   └── Migrations/
├── Views/
│   ├── Order/
│   ├── Dashboard/
│   └── Shared/
├── wwwroot/
│   ├── css/
│   ├── js/
│   └── images/
├── Utilities/
│   ├── Extensions/
│   └── Helpers/
└── Configuration/
    ├── AppSettings.cs
    └── N8NSettings.cs
```

### Step 1.3: appsettings.json Configuration
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=DoDoManBackOffice;Trusted_Connection=true;MultipleActiveResultSets=true;TrustServerCertificate=true"
  },
  "N8NSettings": {
    "BaseUrl": "https://your-n8n-instance.com",
    "ApiKey": "your-n8n-api-key",
    "WebhookSecret": "your-webhook-secret",
    "Endpoints": {
      "OrderStatusUpdate": "/webhook/order-status",
      "PaymentNotification": "/webhook/payment",
      "CustomerNotification": "/webhook/customer-notify"
    }
  },
  "PaymentSettings": {
    "SupportedMethods": [
      "CreditCard",
      "BankTransfer",
      "PayPal",
      "LinePay"
    ],
    "DefaultCurrency": "TWD"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  },
  "AllowedHosts": "*",
  "ApplicationSettings": {
    "PageSize": 20,
    "MaxPageSize": 100,
    "DateFormat": "yyyy-MM-dd",
    "TimeZone": "Asia/Taipei"
  }
}
```

### Step 1.4: Program.cs Configuration
```csharp
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
    context.Database.Migrate();
}

app.Run();
```

### Step 1.5: Configuration Classes
Create configuration classes for type-safe configuration access:

**Configuration/AppSettings.cs**
```csharp
namespace DoDoManBackOffice.Configuration
{
    public class AppSettings
    {
        public int PageSize { get; set; } = 20;
        public int MaxPageSize { get; set; } = 100;
        public string DateFormat { get; set; } = "yyyy-MM-dd";
        public string TimeZone { get; set; } = "Asia/Taipei";
    }
}
```

**Configuration/N8NSettings.cs**
```csharp
namespace DoDoManBackOffice.Configuration
{
    public class N8NSettings
    {
        public string BaseUrl { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string WebhookSecret { get; set; } = string.Empty;
        public N8NEndpoints Endpoints { get; set; } = new();
    }

    public class N8NEndpoints
    {
        public string OrderStatusUpdate { get; set; } = string.Empty;
        public string PaymentNotification { get; set; } = string.Empty;
        public string CustomerNotification { get; set; } = string.Empty;
    }
}
```

### Step 1.6: Development Environment Setup
1. **Visual Studio 2022** or **VS Code** with C# extension
2. **SQL Server LocalDB** or **SQL Server Express**
3. **Node.js** (for frontend tooling if needed)

## Verification Steps
1. Run `dotnet build` to ensure project compiles
2. Run `dotnet ef database update` to create database
3. Run `dotnet run` to start application
4. Verify application starts at https://localhost:7xxx
5. Check logs directory is created
6. Test database connection

## Next Steps
After completing this setup, proceed to:
- 02-Database-Models.md for entity and database configuration
- 03-Service-Layer.md for business logic implementation