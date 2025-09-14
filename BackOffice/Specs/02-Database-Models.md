# 02. Data Models and N8N API Integration

## Overview
定義 DoDoMan 後台管理系統的資料模型、N8N API 整合和資料傳輸物件 (DTOs)。系統不使用本地資料庫，所有資料直接從 N8N API 取得。

## Implementation Steps

### Step 2.1: N8N API Response DTOs

**Models/DTOs/N8NOrderResponseDto.cs**
```csharp
using System.Text.Json.Serialization;

namespace DoDoManBackOffice.Models.DTOs
{
    public class N8NOrderResponseDto
    {
        [JsonPropertyName("row_number")]
        public int RowNumber { get; set; }

        [JsonPropertyName("訂單編號")]
        public int OrderNumber { get; set; }

        [JsonPropertyName("訂單日期")]
        public string OrderDate { get; set; } = string.Empty;

        [JsonPropertyName("客戶名稱")]
        public string CustomerName { get; set; } = string.Empty;

        [JsonPropertyName("支付方式")]
        public string PaymentMethod { get; set; } = string.Empty;

        [JsonPropertyName("支付狀態")]
        public string PaymentStatus { get; set; } = string.Empty;
    }

    public enum PaymentStatus
    {
        Pending = 0,      // pending
        Success = 1,      // success
        Failed = 2,       // failed
        Refunded = 3,     // refunded
        Cancelled = 4     // cancelled
    }

    public enum OrderStatus
    {
        Pending = 0,      // 待處理
        Confirmed = 1,    // 已確認
        InProgress = 2,   // 進行中
        Completed = 3,    // 已完成
        Cancelled = 4     // 已取消
    }
}
```

### Step 2.2: N8N API Service Configuration

**Services/N8NApiService.cs**
```csharp
using DoDoManBackOffice.Models.DTOs;
using System.Text.Json;

namespace DoDoManBackOffice.Services
{
    public interface IN8NApiService
    {
        Task<List<N8NOrderResponseDto>> GetOrdersAsync();
        Task<List<N8NOrderResponseDto>> GetOrdersAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus);
    }

    public class N8NApiService : IN8NApiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<N8NApiService> _logger;

        public N8NApiService(HttpClient httpClient, IConfiguration configuration, ILogger<N8NApiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<List<N8NOrderResponseDto>> GetOrdersAsync()
        {
            try
            {
                var apiUrl = _configuration["N8NSettings:OrdersApiUrl"];
                var response = await _httpClient.GetAsync(apiUrl);
                response.EnsureSuccessStatusCode();

                var jsonContent = await response.Content.ReadAsStringAsync();
                var orders = JsonSerializer.Deserialize<List<N8NOrderResponseDto>>(jsonContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                return orders ?? new List<N8NOrderResponseDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching orders from N8N API");
                return new List<N8NOrderResponseDto>();
            }
        }

        public async Task<List<N8NOrderResponseDto>> GetOrdersAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus)
        {
            var allOrders = await GetOrdersAsync();

            // Apply client-side filtering
            var filteredOrders = allOrders.AsQueryable();

            if (orderNumber.HasValue)
            {
                filteredOrders = filteredOrders.Where(o => o.OrderNumber == orderNumber.Value);
            }

            if (!string.IsNullOrEmpty(customerName))
            {
                filteredOrders = filteredOrders.Where(o => o.CustomerName.Contains(customerName, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(paymentMethod))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentMethod.Equals(paymentMethod, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(paymentStatus))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentStatus.Equals(paymentStatus, StringComparison.OrdinalIgnoreCase));
            }

            if (startDate.HasValue || endDate.HasValue)
            {
                filteredOrders = filteredOrders.Where(o =>
                {
                    if (DateTime.TryParse(o.OrderDate, out var orderDate))
                    {
                        if (startDate.HasValue && orderDate < startDate.Value) return false;
                        if (endDate.HasValue && orderDate > endDate.Value) return false;
                        return true;
                    }
                    return false;
                });
            }

            return filteredOrders.ToList();
        }
    }
}
```

### Step 2.3: View Models

**Models/ViewModels/OrderViewModel.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderViewModel
    {
        [Display(Name = "訂單編號")]
        public int OrderNumber { get; set; }

        [Display(Name = "訂單日期")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime OrderDate { get; set; }

        [Display(Name = "客戶姓名")]
        public string CustomerName { get; set; } = string.Empty;

        [Display(Name = "支付方式")]
        public string PaymentMethod { get; set; } = string.Empty;

        [Display(Name = "支付狀態")]
        public string PaymentStatusRaw { get; set; } = string.Empty;

        public PaymentStatus PaymentStatus => ParsePaymentStatus(PaymentStatusRaw);

        public string PaymentStatusDisplay => GetPaymentStatusDisplay();
        public string PaymentStatusCssClass => GetPaymentStatusCssClass();

        private PaymentStatus ParsePaymentStatus(string status)
        {
            return status?.ToLower() switch
            {
                "success" => PaymentStatus.Success,
                "pending" => PaymentStatus.Pending,
                "failed" => PaymentStatus.Failed,
                "refunded" => PaymentStatus.Refunded,
                "cancelled" => PaymentStatus.Cancelled,
                _ => PaymentStatus.Pending
            };
        }

        private string GetPaymentStatusDisplay()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "待付款",
                PaymentStatus.Success => "已付款",
                PaymentStatus.Failed => "付款失敗",
                PaymentStatus.Refunded => "已退款",
                PaymentStatus.Cancelled => "已取消",
                _ => "未知"
            };
        }

        private string GetPaymentStatusCssClass()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "badge bg-warning",
                PaymentStatus.Success => "badge bg-success",
                PaymentStatus.Failed => "badge bg-danger",
                PaymentStatus.Refunded => "badge bg-info",
                PaymentStatus.Cancelled => "badge bg-secondary",
                _ => "badge bg-light"
            };
        }

        public static OrderViewModel FromN8NDto(N8NOrderResponseDto dto)
        {
            return new OrderViewModel
            {
                OrderNumber = dto.OrderNumber,
                OrderDate = DateTime.TryParse(dto.OrderDate, out var orderDate) ? orderDate : DateTime.MinValue,
                CustomerName = dto.CustomerName,
                PaymentMethod = FormatPaymentMethod(dto.PaymentMethod),
                PaymentStatusRaw = dto.PaymentStatus
            };
        }

        private static string FormatPaymentMethod(string method)
        {
            return method?.ToLower() switch
            {
                "credit card" => "信用卡",
                "bank transfer" => "銀行轉帳",
                "paypal" => "PayPal",
                "line pay" => "Line Pay",
                _ => method ?? ""
            };
        }
    }
}
```

**Models/ViewModels/OrderListViewModel.cs**
```csharp
namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderListViewModel
    {
        public IEnumerable<OrderViewModel> Orders { get; set; } = new List<OrderViewModel>();
        public FilterViewModel Filter { get; set; } = new();
        public PaginationViewModel Pagination { get; set; } = new();

        // Summary Statistics (calculated from filtered results)
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int SuccessfulOrders { get; set; }
    }

    public class PaginationViewModel
    {
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 20;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);

        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;

        public int StartItem => (CurrentPage - 1) * PageSize + 1;
        public int EndItem => Math.Min(CurrentPage * PageSize, TotalItems);
    }
}
```

**Models/ViewModels/FilterViewModel.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class FilterViewModel
    {
        [Display(Name = "開始日期")]
        [DataType(DataType.Date)]
        public DateTime? StartDate { get; set; }

        [Display(Name = "結束日期")]
        [DataType(DataType.Date)]
        public DateTime? EndDate { get; set; }

        [Display(Name = "訂單編號")]
        public int? OrderNumber { get; set; }

        [Display(Name = "客戶姓名")]
        [StringLength(100)]
        public string? CustomerName { get; set; }

        [Display(Name = "支付方式")]
        public string? PaymentMethod { get; set; }

        [Display(Name = "支付狀態")]
        public string? PaymentStatus { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;

        // For dropdowns
        public List<SelectListItem> PaymentMethodOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "credit card", Text = "信用卡" },
            new SelectListItem { Value = "bank transfer", Text = "銀行轉帳" },
            new SelectListItem { Value = "paypal", Text = "PayPal" },
            new SelectListItem { Value = "line pay", Text = "Line Pay" }
        };

        public List<SelectListItem> PaymentStatusOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "pending", Text = "待付款" },
            new SelectListItem { Value = "success", Text = "已付款" },
            new SelectListItem { Value = "failed", Text = "付款失敗" },
            new SelectListItem { Value = "refunded", Text = "已退款" },
            new SelectListItem { Value = "cancelled", Text = "已取消" }
        };
    }
}
```

### Step 2.4: Configuration Settings

**appsettings.json**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "N8NSettings": {
    "BaseUrl": "https://your-n8n-instance.com",
    "OrdersApiUrl": "https://your-n8n-instance.com/webhook/orders",
    "ApiKey": "your-api-key-here",
    "Timeout": 30
  }
}
```

**appsettings.Development.json**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "DoDoManBackOffice": "Debug"
    }
  },
  "N8NSettings": {
    "BaseUrl": "http://localhost:5678",
    "OrdersApiUrl": "http://localhost:5678/webhook/orders",
    "ApiKey": "dev-api-key",
    "Timeout": 10
  }
}
```

### Step 2.5: Service Registration

**Program.cs** (add these registrations)
```csharp
// Add HTTP client for N8N API
builder.Services.AddHttpClient<IN8NApiService, N8NApiService>(client =>
{
    var n8nSettings = builder.Configuration.GetSection("N8NSettings");
    client.BaseAddress = new Uri(n8nSettings["BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(int.Parse(n8nSettings["Timeout"] ?? "30"));

    // Add API key if configured
    var apiKey = n8nSettings["ApiKey"];
    if (!string.IsNullOrEmpty(apiKey))
    {
        client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
    }
});

// Register services
builder.Services.AddScoped<IN8NApiService, N8NApiService>();
```

## Verification Steps
1. Configure N8N API endpoint in appsettings.json
2. Test N8N API connectivity
3. Verify data mapping from N8N response to ViewModels
4. Test filtering functionality with N8N data
5. Verify pagination works with API data

## Next Steps
After completing the N8N API integration setup, proceed to:
- 03-Service-Layer.md for business logic implementation
- 04-Controllers-API.md for API and controller development

## Key Changes from Original Database Approach

1. **No Local Database**: All data comes directly from N8N API calls
2. **Simplified Models**: DTOs map directly to N8N API response structure
3. **Client-side Filtering**: Filtering and pagination handled in-memory after API call
4. **Real-time Data**: Always displays current data from N8N system
5. **Configuration-based**: API endpoint and authentication configured via appsettings.json