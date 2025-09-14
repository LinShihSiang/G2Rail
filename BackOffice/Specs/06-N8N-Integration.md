# 06. N8N Integration Implementation

## Overview
實作 DoDoMan 後台管理系統與 N8N 工作流程平台的整合，專注於直接從 N8N API 獲取訂單資料的無資料庫架構。系統作為 N8N 資料的展示和管理介面。

## Architecture Changes from Database Approach

### Key Architectural Shifts
1. **No Local Database Storage**: 完全移除本地資料庫，所有資料來自 N8N API
2. **Read-Only System**: 系統變為純展示和報表介面，不進行資料修改
3. **Real-time Data**: 每次查詢都直接從 N8N API 獲取最新資料
4. **Simplified Integration**: 移除複雜的資料同步邏輯，專注於資料展示

### N8N Get Order API Integration

The N8N get order API (https://howardmei.app.n8n.cloud/webhook/get-order) returns order data in the following format:

```json
[
  {
    "row_number": 2,
    "訂單編號": 1,
    "訂單日期": "9/14/2025 17:04:03",
    "客戶名稱": "Howard Mei",
    "支付方式": "credit card",
    "支付狀態": "success"
  }
]
```

**Key API Response Fields**:
- `row_number` (int): Sequential row identifier
- `訂單編號` (int): Order number (integer format)
- `訂單日期` (string): Order date in "M/D/YYYY HH:MM:SS" format
- `客戶名稱` (string): Customer full name
- `支付方式` (string): Payment method (lowercase format)
- `支付狀態` (string): Payment status

## Implementation Steps

### Step 6.1: N8N API Service (已在 Step 2.2 實作)

N8N API service 已在 02-Database-Models.md 中定義：
- `N8NApiService` 處理 HTTP 請求到 N8N API
- `N8NOrderResponseDto` 定義 API 回應格式
- 支援篩選和分頁的客戶端處理

### Step 6.2: Cache Invalidation Service

**Services/Implementations/N8NCacheInvalidationService.cs**
```csharp
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public interface IN8NCacheInvalidationService
    {
        Task InvalidateOrderCacheAsync();
        Task InvalidateOrderCacheAsync(int orderNumber);
        Task HandleN8NWebhookAsync(string webhookType, object data);
    }

    public class N8NCacheInvalidationService : IN8NCacheInvalidationService
    {
        private readonly ICacheService _cacheService;
        private readonly ILogger<N8NCacheInvalidationService> _logger;

        public N8NCacheInvalidationService(
            ICacheService cacheService,
            ILogger<N8NCacheInvalidationService> logger)
        {
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task InvalidateOrderCacheAsync()
        {
            try
            {
                // Remove all order-related cache entries
                await _cacheService.RemoveByPatternAsync("orders_*");
                _logger.LogInformation("Invalidated all order cache entries");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error invalidating order cache");
            }
        }

        public async Task InvalidateOrderCacheAsync(int orderNumber)
        {
            try
            {
                await _cacheService.RemoveAsync($"order_{orderNumber}");
                await InvalidateOrderCacheAsync(); // Also clear list cache
                _logger.LogInformation("Invalidated cache for order {OrderNumber}", orderNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error invalidating cache for order {OrderNumber}", orderNumber);
            }
        }

        public async Task HandleN8NWebhookAsync(string webhookType, object data)
        {
            try
            {
                switch (webhookType.ToLower())
                {
                    case "order.created":
                    case "order.updated":
                    case "order.status.changed":
                    case "payment.status.changed":
                        await InvalidateOrderCacheAsync();
                        break;
                    default:
                        _logger.LogDebug("Unhandled webhook type: {WebhookType}", webhookType);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling N8N webhook: {WebhookType}", webhookType);
            }
        }
    }
}
```

### Step 6.3: Webhook Controller for Cache Invalidation

**Controllers/N8NWebhookController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class N8NWebhookController : ControllerBase
    {
        private readonly IN8NCacheInvalidationService _cacheInvalidationService;
        private readonly ILogger<N8NWebhookController> _logger;

        public N8NWebhookController(
            IN8NCacheInvalidationService cacheInvalidationService,
            ILogger<N8NWebhookController> logger)
        {
            _cacheInvalidationService = cacheInvalidationService;
            _logger = logger;
        }

        [HttpPost("order-updated")]
        public async Task<IActionResult> OrderUpdated([FromBody] N8NOrderUpdateWebhook webhook)
        {
            try
            {
                _logger.LogInformation("Received order update webhook for order {OrderNumber}", webhook.OrderNumber);

                await _cacheInvalidationService.InvalidateOrderCacheAsync(webhook.OrderNumber);

                return Ok(new { success = true, message = "Cache invalidated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing order update webhook");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost("data-changed")]
        public async Task<IActionResult> DataChanged([FromBody] N8NDataChangeWebhook webhook)
        {
            try
            {
                _logger.LogInformation("Received data change webhook: {ChangeType}", webhook.ChangeType);

                await _cacheInvalidationService.HandleN8NWebhookAsync(webhook.ChangeType, webhook.Data);

                return Ok(new { success = true, message = "Webhook processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing data change webhook");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                service = "DoDoMan BackOffice N8N Webhook Endpoint"
            });
        }
    }

    public class N8NOrderUpdateWebhook
    {
        public int OrderNumber { get; set; }
        public string ChangeType { get; set; } = string.Empty;
        public DateTime UpdatedAt { get; set; }
    }

    public class N8NDataChangeWebhook
    {
        public string ChangeType { get; set; } = string.Empty;
        public object Data { get; set; } = new();
        public DateTime Timestamp { get; set; }
    }
}
```

### Step 6.4: N8N Health Check Service

**Services/Implementations/N8NHealthService.cs**
```csharp
using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public interface IN8NHealthService
    {
        Task<N8NHealthStatus> CheckHealthAsync();
        Task<bool> TestApiConnectionAsync();
    }

    public class N8NHealthService : IN8NHealthService
    {
        private readonly IN8NApiService _n8nApiService;
        private readonly ILogger<N8NHealthService> _logger;

        public N8NHealthService(
            IN8NApiService n8nApiService,
            ILogger<N8NHealthService> logger)
        {
            _n8nApiService = n8nApiService;
            _logger = logger;
        }

        public async Task<N8NHealthStatus> CheckHealthAsync()
        {
            var healthStatus = new N8NHealthStatus
            {
                CheckTime = DateTime.UtcNow
            };

            try
            {
                // Test basic connection by trying to get orders
                var orders = await _n8nApiService.GetOrdersAsync();

                healthStatus.IsConnected = true;
                healthStatus.Status = "Healthy";
                healthStatus.Message = $"N8N API is responding normally. Retrieved {orders.Count()} orders.";
                healthStatus.OrderCount = orders.Count();

                return healthStatus;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "N8N health check failed");
                healthStatus.IsConnected = false;
                healthStatus.Status = "Unhealthy";
                healthStatus.Message = $"N8N API connection failed: {ex.Message}";
                return healthStatus;
            }
        }

        public async Task<bool> TestApiConnectionAsync()
        {
            try
            {
                var orders = await _n8nApiService.GetOrdersAsync();
                _logger.LogInformation("N8N API connection test successful. Retrieved {Count} orders", orders.Count());
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "N8N API connection test failed");
                return false;
            }
        }
    }

    public class N8NHealthStatus
    {
        public DateTime CheckTime { get; set; }
        public bool IsConnected { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int OrderCount { get; set; }
    }
}
```

### Step 6.5: Service Registration and Configuration

**Program.cs (Additional Configuration)**
```csharp
// N8N Integration Services (add after existing service registrations)

// N8N API Service (already registered in Step 2.5)
// builder.Services.AddHttpClient<IN8NApiService, N8NApiService>(...);
// builder.Services.AddScoped<IN8NApiService, N8NApiService>();

// Additional N8N Services
builder.Services.AddScoped<IN8NCacheInvalidationService, N8NCacheInvalidationService>();
builder.Services.AddScoped<IN8NHealthService, N8NHealthService>();

// Background Services for N8N monitoring
builder.Services.AddHostedService<N8NHealthCheckBackgroundService>();
```

**Configuration/N8NSettings.cs (Updated)**
```csharp
namespace DoDoManBackOffice.Configuration
{
    public class N8NSettings
    {
        public string BaseUrl { get; set; } = "https://howardmei.app.n8n.cloud";
        public string OrdersApiUrl { get; set; } = "https://howardmei.app.n8n.cloud/webhook/get-order";
        public string ApiKey { get; set; } = string.Empty;
        public string WebhookSecret { get; set; } = string.Empty;
        public int Timeout { get; set; } = 30;

        // Health Check Settings
        public int HealthCheckIntervalMinutes { get; set; } = 60;
        public bool HealthCheckEnabled { get; set; } = true;

        // Webhook Endpoints (for receiving callbacks from N8N)
        public N8NWebhookEndpoints WebhookEndpoints { get; set; } = new();
    }

    public class N8NWebhookEndpoints
    {
        public string OrderUpdated { get; set; } = "/api/n8nwebhook/order-updated";
        public string DataChanged { get; set; } = "/api/n8nwebhook/data-changed";
        public string Health { get; set; } = "/api/n8nwebhook/health";
    }
}
```

### Step 6.6: Background Health Check Service

**Services/Implementations/N8NHealthCheckBackgroundService.cs**
```csharp
using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NHealthCheckBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<N8NHealthCheckBackgroundService> _logger;
        private readonly N8NSettings _n8nSettings;

        public N8NHealthCheckBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<N8NHealthCheckBackgroundService> logger,
            IOptions<N8NSettings> n8nSettings)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
            _n8nSettings = n8nSettings.Value;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            if (!_n8nSettings.HealthCheckEnabled)
            {
                _logger.LogInformation("N8N health check is disabled");
                return;
            }

            _logger.LogInformation("N8N Health Check Background Service started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await PerformHealthCheck();

                    var delayMinutes = _n8nSettings.HealthCheckIntervalMinutes;
                    await Task.Delay(TimeSpan.FromMinutes(delayMinutes), stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in N8N health check background service");
                    await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
                }
            }

            _logger.LogInformation("N8N Health Check Background Service stopped");
        }

        private async Task PerformHealthCheck()
        {
            using var scope = _serviceProvider.CreateScope();
            var healthService = scope.ServiceProvider.GetRequiredService<IN8NHealthService>();

            try
            {
                var healthStatus = await healthService.CheckHealthAsync();

                if (healthStatus.IsConnected)
                {
                    _logger.LogInformation("N8N health check passed: {Message}", healthStatus.Message);
                }
                else
                {
                    _logger.LogWarning("N8N health check failed: {Message}", healthStatus.Message);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during N8N health check");
            }
        }
    }
}
```

### Step 6.7: Integration Testing Support

**Services/Implementations/N8NTestService.cs**
```csharp
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;

namespace DoDoManBackOffice.Services.Implementations
{
    public interface IN8NTestService
    {
        Task<N8NTestResult> RunIntegrationTestAsync();
        Task<N8NTestResult> TestOrderRetrievalAsync();
        Task<N8NTestResult> TestCacheInvalidationAsync();
    }

    public class N8NTestService : IN8NTestService
    {
        private readonly IN8NApiService _n8nApiService;
        private readonly IN8NHealthService _healthService;
        private readonly IN8NCacheInvalidationService _cacheService;
        private readonly ILogger<N8NTestService> _logger;

        public N8NTestService(
            IN8NApiService n8nApiService,
            IN8NHealthService healthService,
            IN8NCacheInvalidationService cacheService,
            ILogger<N8NTestService> logger)
        {
            _n8nApiService = n8nApiService;
            _healthService = healthService;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<N8NTestResult> RunIntegrationTestAsync()
        {
            var testResult = new N8NTestResult
            {
                TestName = "N8N Integration Test",
                StartTime = DateTime.UtcNow
            };

            try
            {
                // Test 1: Health Check
                var healthCheck = await _healthService.CheckHealthAsync();
                testResult.AddTest("Health Check", healthCheck.IsConnected, healthCheck.Message);

                if (!healthCheck.IsConnected)
                {
                    testResult.Success = false;
                    testResult.EndTime = DateTime.UtcNow;
                    return testResult;
                }

                // Test 2: Order Retrieval
                var orderTest = await TestOrderRetrievalAsync();
                testResult.AddTest("Order Retrieval", orderTest.Success, orderTest.Message);

                // Test 3: Cache Invalidation
                var cacheTest = await TestCacheInvalidationAsync();
                testResult.AddTest("Cache Invalidation", cacheTest.Success, cacheTest.Message);

                testResult.Success = testResult.TestResults.All(t => t.Success);
                testResult.EndTime = DateTime.UtcNow;

                return testResult;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error running N8N integration test");
                testResult.Success = false;
                testResult.Message = $"Test failed with exception: {ex.Message}";
                testResult.EndTime = DateTime.UtcNow;
                return testResult;
            }
        }

        public async Task<N8NTestResult> TestOrderRetrievalAsync()
        {
            try
            {
                var orders = await _n8nApiService.GetOrdersAsync();
                return new N8NTestResult
                {
                    TestName = "Order Retrieval Test",
                    Success = true,
                    Message = $"Successfully retrieved {orders.Count()} orders from N8N API"
                };
            }
            catch (Exception ex)
            {
                return new N8NTestResult
                {
                    TestName = "Order Retrieval Test",
                    Success = false,
                    Message = $"Failed to retrieve orders: {ex.Message}"
                };
            }
        }

        public async Task<N8NTestResult> TestCacheInvalidationAsync()
        {
            try
            {
                await _cacheService.InvalidateOrderCacheAsync();
                return new N8NTestResult
                {
                    TestName = "Cache Invalidation Test",
                    Success = true,
                    Message = "Successfully invalidated order cache"
                };
            }
            catch (Exception ex)
            {
                return new N8NTestResult
                {
                    TestName = "Cache Invalidation Test",
                    Success = false,
                    Message = $"Failed to invalidate cache: {ex.Message}"
                };
            }
        }
    }

    public class N8NTestResult
    {
        public string TestName { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public List<N8NTestResult> TestResults { get; set; } = new();

        public void AddTest(string testName, bool success, string message)
        {
            TestResults.Add(new N8NTestResult
            {
                TestName = testName,
                Success = success,
                Message = message,
                StartTime = DateTime.UtcNow,
                EndTime = DateTime.UtcNow
            });
        }

        public TimeSpan Duration => EndTime - StartTime;
    }
}
```

## Verification Steps

1. **配置 N8N API 端點**: 更新 appsettings.json 中的 N8N 設定
2. **測試 API 連接**: 使用 N8N Health Service 驗證連接
3. **驗證資料擷取**: 確認能從 N8N API 獲取訂單資料
4. **測試快取失效**: 驗證 webhook 可以正確清除快取
5. **監控系統健康狀態**: 檢查背景服務運作狀況

## Key Changes from Original Database Approach

### Architecture Simplification
1. **移除複雜的資料同步**: 不再需要雙向資料同步邏輯
2. **簡化 Webhook 用途**: 主要用於快取失效而非資料更新
3. **即時資料展示**: 每次查詢都從 N8N API 獲取最新資料
4. **減少錯誤處理複雜度**: 不需要處理資料同步衝突

### Integration Points
1. **N8N Get Order API**: 主要資料來源
2. **Cache Invalidation Webhooks**: 當 N8N 資料變更時清除快取
3. **Health Check Monitoring**: 定期檢查 N8N API 可用性

### Performance Considerations
1. **智能快取策略**: 30分鐘快取以減少 API 呼叫
2. **失效驅動更新**: 只在資料變更時清除快取
3. **健康狀態監控**: 主動偵測 API 問題

## Next Steps
After completing N8N integration, proceed to:
- 07-Testing-Deployment.md for comprehensive testing and deployment specifications