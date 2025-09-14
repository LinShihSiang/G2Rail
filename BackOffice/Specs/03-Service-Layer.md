# 03. Service Layer Implementation

## Overview
實作 DoDoMan 後台管理系統的業務邏輯層，專注於 N8N API 整合、訂單資料處理和業務邏輯。系統不使用本地資料庫，所有資料來源為 N8N API。

## Implementation Steps

### Step 3.1: Service Interfaces

**Services/Interfaces/IOrderService.cs**
```csharp
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IOrderService
    {
        // Query Methods (N8N API Based)
        Task<OrderListViewModel> GetOrdersAsync(FilterViewModel filter);
        Task<OrderViewModel?> GetOrderByNumberAsync(int orderNumber);
        Task<IEnumerable<OrderViewModel>> GetOrdersByCustomerAsync(string customerName);

        // N8N API Integration
        Task<IEnumerable<N8NOrderResponseDto>> GetOrdersFromN8NAsync();
        Task<IEnumerable<N8NOrderResponseDto>> GetOrdersFromN8NAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus);

        // Data Transformation
        Task<IEnumerable<OrderViewModel>> TransformN8NDataAsync(IEnumerable<N8NOrderResponseDto> n8nData);
        OrderViewModel TransformSingleOrder(N8NOrderResponseDto n8nOrder);

        // Business Logic (Read-Only Operations)
        Task<bool> ValidateOrderNumberAsync(int orderNumber);
        Task<OrderSummaryDto> GetOrderSummaryAsync(DateTime? startDate = null, DateTime? endDate = null);

        // Reporting and Analytics
        Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusCountsAsync();
        Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodSummaryAsync();
        Task<OrderSummaryDto> GetDashboardSummaryAsync();

        // Search and Filter (Client-side processing)
        Task<IEnumerable<OrderViewModel>> SearchOrdersAsync(string searchTerm);
        Task<IEnumerable<int>> GetOrderNumberSuggestionsAsync(string partialOrderNumber);
    }

    // Supporting DTOs
    public class OrderSummaryDto
    {
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int SuccessfulOrders { get; set; }
        public int FailedOrders { get; set; }
        public int RefundedOrders { get; set; }
        public int CancelledOrders { get; set; }
    }

    public class OrderStatusCountDto
    {
        public PaymentStatus Status { get; set; }
        public int Count { get; set; }
        public string DisplayName { get; set; } = string.Empty;
    }

    public class PaymentMethodSummaryDto
    {
        public string PaymentMethod { get; set; } = string.Empty;
        public int Count { get; set; }
        public decimal Percentage { get; set; }
        public string DisplayName { get; set; } = string.Empty;
    }
}
```

**Services/Interfaces/ICacheService.cs**
```csharp
namespace DoDoManBackOffice.Services.Interfaces
{
    public interface ICacheService
    {
        Task<T?> GetAsync<T>(string key) where T : class;
        Task SetAsync<T>(string key, T value, TimeSpan? expiration = null) where T : class;
        Task RemoveAsync(string key);
        Task RemoveByPatternAsync(string pattern);
        Task<bool> ExistsAsync(string key);
    }
}
```

**Services/Interfaces/IReportingService.cs**
```csharp
using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Models.ViewModels;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IReportingService
    {
        // Dashboard Analytics
        Task<DashboardSummaryDto> GetDashboardSummaryAsync();
        Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodBreakdownAsync();
        Task<IEnumerable<DailyOrderCountDto>> GetDailyOrderTrendsAsync(DateTime startDate, DateTime endDate);

        // Order Reports
        Task<OrderReportDto> GenerateOrderReportAsync(DateTime? startDate, DateTime? endDate);
        Task<byte[]> ExportOrdersToExcelAsync(FilterViewModel filter);
        Task<byte[]> ExportOrdersToPdfAsync(FilterViewModel filter);

        // Analytics
        Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusDistributionAsync();
        Task<CustomerAnalyticsDto> GetCustomerAnalyticsAsync();
    }

    // Reporting DTOs
    public class DashboardSummaryDto
    {
        public int TotalOrders { get; set; }
        public int TodayOrders { get; set; }
        public int PendingOrders { get; set; }
        public int SuccessfulOrders { get; set; }
        public decimal SuccessRate { get; set; }
        public IEnumerable<PaymentMethodSummaryDto> PaymentMethods { get; set; } = new List<PaymentMethodSummaryDto>();
        public IEnumerable<DailyOrderCountDto> RecentTrends { get; set; } = new List<DailyOrderCountDto>();
    }

    public class DailyOrderCountDto
    {
        public DateTime Date { get; set; }
        public int Count { get; set; }
        public int SuccessfulCount { get; set; }
    }

    public class OrderReportDto
    {
        public DateTime GeneratedAt { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int TotalOrders { get; set; }
        public IEnumerable<OrderViewModel> Orders { get; set; } = new List<OrderViewModel>();
        public OrderSummaryDto Summary { get; set; } = new();
    }

    public class CustomerAnalyticsDto
    {
        public int TotalCustomers { get; set; }
        public int NewCustomersThisMonth { get; set; }
        public IEnumerable<TopCustomerDto> TopCustomers { get; set; } = new List<TopCustomerDto>();
    }

    public class TopCustomerDto
    {
        public string CustomerName { get; set; } = string.Empty;
        public int OrderCount { get; set; }
    }
}
```

### Step 3.2: Order Service Implementation

**Services/Implementations/OrderService.cs**
```csharp
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private readonly IN8NApiService _n8nApiService;
        private readonly ICacheService _cacheService;
        private readonly ILogger<OrderService> _logger;

        public OrderService(
            IN8NApiService n8nApiService,
            ICacheService cacheService,
            ILogger<OrderService> logger)
        {
            _n8nApiService = n8nApiService;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<OrderListViewModel> GetOrdersAsync(FilterViewModel filter)
        {
            try
            {
                _logger.LogInformation("Fetching orders with filter: {@Filter}", filter);

                // Get cached data first
                var cacheKey = $"orders_{DateTime.Now:yyyy-MM-dd-HH}";
                var cachedOrders = await _cacheService.GetAsync<List<N8NOrderResponseDto>>(cacheKey);

                List<N8NOrderResponseDto> n8nOrders;
                if (cachedOrders != null)
                {
                    n8nOrders = cachedOrders;
                }
                else
                {
                    // Fetch from N8N API with filters
                    n8nOrders = (await _n8nApiService.GetOrdersAsync(
                        filter.StartDate,
                        filter.EndDate,
                        filter.OrderNumber,
                        filter.CustomerName,
                        filter.PaymentMethod,
                        filter.PaymentStatus
                    )).ToList();

                    // Cache for 30 minutes
                    await _cacheService.SetAsync(cacheKey, n8nOrders, TimeSpan.FromMinutes(30));
                }

                // Transform to ViewModels
                var orderViewModels = await TransformN8NDataAsync(n8nOrders);
                var ordersArray = orderViewModels.ToArray();

                // Apply pagination
                var totalCount = ordersArray.Length;
                var paginatedOrders = ordersArray
                    .Skip((filter.Page - 1) * filter.PageSize)
                    .Take(filter.PageSize)
                    .ToList();

                // Calculate summary
                var summary = CalculateSummary(ordersArray);

                return new OrderListViewModel
                {
                    Orders = paginatedOrders,
                    Filter = filter,
                    Pagination = new PaginationViewModel
                    {
                        CurrentPage = filter.Page,
                        PageSize = filter.PageSize,
                        TotalItems = totalCount
                    },
                    TotalOrders = summary.TotalOrders,
                    PendingOrders = summary.PendingOrders,
                    SuccessfulOrders = summary.SuccessfulOrders
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving orders from N8N API");
                throw;
            }
        }

        public async Task<OrderViewModel?> GetOrderByNumberAsync(int orderNumber)
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var order = orders.FirstOrDefault(o => o.OrderNumber == orderNumber);

                return order != null ? TransformSingleOrder(order) : null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving order {OrderNumber}", orderNumber);
                throw;
            }
        }

        public async Task<IEnumerable<N8NOrderResponseDto>> GetOrdersFromN8NAsync()
        {
            try
            {
                return await _n8nApiService.GetOrdersAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching orders from N8N API");
                throw;
            }
        }

        public async Task<IEnumerable<N8NOrderResponseDto>> GetOrdersFromN8NAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus)
        {
            try
            {
                return await _n8nApiService.GetOrdersAsync(startDate, endDate, orderNumber, customerName, paymentMethod, paymentStatus);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching filtered orders from N8N API");
                throw;
            }
        }

        public async Task<IEnumerable<OrderViewModel>> TransformN8NDataAsync(IEnumerable<N8NOrderResponseDto> n8nData)
        {
            return await Task.FromResult(n8nData.Select(TransformSingleOrder));
        }

        public OrderViewModel TransformSingleOrder(N8NOrderResponseDto n8nOrder)
        {
            return OrderViewModel.FromN8NDto(n8nOrder);
        }

        public async Task<bool> ValidateOrderNumberAsync(int orderNumber)
        {
            try
            {
                var order = await GetOrderByNumberAsync(orderNumber);
                return order != null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error validating order number {OrderNumber}\", orderNumber);
                return false;
            }
        }

        public async Task<IEnumerable<OrderViewModel>> GetOrdersByCustomerAsync(string customerName)
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var customerOrders = orders.Where(o => o.CustomerName.Contains(customerName, StringComparison.OrdinalIgnoreCase));
                return await TransformN8NDataAsync(customerOrders);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error retrieving orders for customer {CustomerName}\", customerName);
                return new List<OrderViewModel>();
            }
        }

        public async Task<OrderSummaryDto> GetOrderSummaryAsync(DateTime? startDate = null, DateTime? endDate = null)
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync(startDate, endDate, null, null, null, null);
                var orderViewModels = await TransformN8NDataAsync(orders);

                return CalculateSummary(orderViewModels);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error calculating order summary\");
                return new OrderSummaryDto();
            }
        }

        public async Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusCountsAsync()
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var orderViewModels = await TransformN8NDataAsync(orders);

                var counts = orderViewModels
                    .GroupBy(o => o.PaymentStatus)
                    .Select(g => new OrderStatusCountDto
                    {
                        Status = g.Key,
                        Count = g.Count(),
                        DisplayName = GetStatusDisplayName(g.Key)
                    });

                return counts;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error getting order status counts\");
                return new List<OrderStatusCountDto>();
            }
        }

        public async Task<IEnumerable<int>> GetOrderNumberSuggestionsAsync(string partialOrderNumber)
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();

                if (int.TryParse(partialOrderNumber, out int partialNumber))
                {
                    return orders
                        .Where(o => o.OrderNumber.ToString().Contains(partialOrderNumber))
                        .Select(o => o.OrderNumber)
                        .Take(10)
                        .ToList();
                }

                return new List<int>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting order number suggestions");
                return new List<int>();
            }
        }

        public async Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodSummaryAsync()
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var orderViewModels = await TransformN8NDataAsync(orders);
                var totalOrders = orderViewModels.Count();

                var summary = orderViewModels
                    .GroupBy(o => o.PaymentMethod)
                    .Select(g => new PaymentMethodSummaryDto
                    {
                        PaymentMethod = g.Key,
                        Count = g.Count(),
                        Percentage = totalOrders > 0 ? (decimal)g.Count() / totalOrders * 100 : 0,
                        DisplayName = g.Key
                    })
                    .ToList();

                return summary;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting payment method summary");
                return new List<PaymentMethodSummaryDto>();
            }
        }

        public async Task<OrderSummaryDto> GetDashboardSummaryAsync()
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var orderViewModels = await TransformN8NDataAsync(orders);

                return CalculateSummary(orderViewModels);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting dashboard summary");
                return new OrderSummaryDto();
            }
        }

        public async Task<IEnumerable<OrderViewModel>> SearchOrdersAsync(string searchTerm)
        {
            try
            {
                var orders = await GetOrdersFromN8NAsync();
                var orderViewModels = await TransformN8NDataAsync(orders);

                var searchResults = orderViewModels.Where(o =>
                    o.OrderNumber.ToString().Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                    o.CustomerName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase))
                    .Take(50);

                return searchResults;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching orders");
                return new List<OrderViewModel>();
            }
        }

        #region Private Helper Methods

        private OrderSummaryDto CalculateSummary(IEnumerable<OrderViewModel> orders)
        {
            var ordersList = orders.ToList();

            return new OrderSummaryDto
            {
                TotalOrders = ordersList.Count,
                PendingOrders = ordersList.Count(o => o.PaymentStatus == PaymentStatus.Pending),
                SuccessfulOrders = ordersList.Count(o => o.PaymentStatus == PaymentStatus.Success),
                FailedOrders = ordersList.Count(o => o.PaymentStatus == PaymentStatus.Failed),
                RefundedOrders = ordersList.Count(o => o.PaymentStatus == PaymentStatus.Refunded),
                CancelledOrders = ordersList.Count(o => o.PaymentStatus == PaymentStatus.Cancelled)
            };
        }

        private string GetStatusDisplayName(PaymentStatus status)
        {
            return status switch
            {
                PaymentStatus.Pending => "待付款",
                PaymentStatus.Success => "已付款",
                PaymentStatus.Failed => "付款失敗",
                PaymentStatus.Refunded => "已退款",
                PaymentStatus.Cancelled => "已取消",
                _ => "未知"
            };
        }

        #endregion
    }
}
```

### Step 3.3: Cache Service Implementation

**Services/Implementations/CacheService.cs**
```csharp
using Microsoft.Extensions.Caching.Memory;
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public class CacheService : ICacheService
    {
        private readonly IMemoryCache _memoryCache;
        private readonly ILogger<CacheService> _logger;

        public CacheService(IMemoryCache memoryCache, ILogger<CacheService> logger)
        {
            _memoryCache = memoryCache;
            _logger = logger;
        }

        public async Task<T?> GetAsync<T>(string key) where T : class
        {
            try
            {
                if (_memoryCache.TryGetValue(key, out T? cachedValue))
                {
                    _logger.LogDebug("Cache hit for key: {Key}", key);
                    return cachedValue;
                }

                _logger.LogDebug("Cache miss for key: {Key}", key);
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting cached value for key: {Key}", key);
                return null;
            }
        }

        public async Task SetAsync<T>(string key, T value, TimeSpan? expiration = null) where T : class
        {
            try
            {
                var options = new MemoryCacheEntryOptions();

                if (expiration.HasValue)
                {
                    options.AbsoluteExpirationRelativeToNow = expiration.Value;
                }
                else
                {
                    // Default expiration: 30 minutes
                    options.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30);
                }

                _memoryCache.Set(key, value, options);
                _logger.LogDebug("Cached value for key: {Key}, Expiration: {Expiration}", key, expiration);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting cached value for key: {Key}", key);
            }
        }

        public async Task RemoveAsync(string key)
        {
            try
            {
                _memoryCache.Remove(key);
                _logger.LogDebug("Removed cache entry for key: {Key}", key);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing cached value for key: {Key}", key);
            }
        }

        public async Task RemoveByPatternAsync(string pattern)
        {
            // Note: MemoryCache doesn't support pattern-based removal
            // This would require a more sophisticated caching solution like Redis
            _logger.LogWarning("Pattern-based cache removal not supported with MemoryCache: {Pattern}", pattern);
            await Task.CompletedTask;
        }

        public async Task<bool> ExistsAsync(string key)
        {
            try
            {
                return _memoryCache.TryGetValue(key, out _);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking cache existence for key: {Key}", key);
                return false;
            }
        }
    }
}
```

### Step 3.4: Validation Services

**Services/Implementations/ValidationService.cs**
```csharp
using FluentValidation;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Services.Implementations
{
    public class FilterViewModelValidator : AbstractValidator<FilterViewModel>
    {
        public FilterViewModelValidator()
        {
            RuleFor(x => x.StartDate)
                .LessThanOrEqualTo(x => x.EndDate)
                .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
                .WithMessage("開始日期不能晚於結束日期");

            RuleFor(x => x.EndDate)
                .LessThanOrEqualTo(DateTime.Today)
                .When(x => x.EndDate.HasValue)
                .WithMessage("結束日期不能超過今天");

            RuleFor(x => x.OrderNumber)
                .GreaterThan(0)
                .When(x => x.OrderNumber.HasValue)
                .WithMessage("訂單編號必須大於0");

            RuleFor(x => x.CustomerName)
                .MaximumLength(100)
                .WithMessage("客戶姓名不能超過100個字元");

            RuleFor(x => x.PageSize)
                .GreaterThan(0)
                .LessThanOrEqualTo(100)
                .WithMessage("每頁顯示筆數必須在1-100之間");
        }
    }

    public class N8NOrderResponseValidator : AbstractValidator<N8NOrderResponseDto>
    {
        public N8NOrderResponseValidator()
        {
            RuleFor(x => x.OrderNumber)
                .GreaterThan(0)
                .WithMessage("訂單編號必須大於0");

            RuleFor(x => x.CustomerName)
                .NotEmpty()
                .WithMessage("客戶姓名不能為空")
                .MaximumLength(200)
                .WithMessage("客戶姓名不能超過200個字元");

            RuleFor(x => x.OrderDate)
                .NotEmpty()
                .WithMessage("訂單日期不能為空");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty()
                .WithMessage("支付方式不能為空")
                .Must(BeValidPaymentMethod)
                .WithMessage("不支援的支付方式");

            RuleFor(x => x.PaymentStatus)
                .NotEmpty()
                .WithMessage("支付狀態不能為空")
                .Must(BeValidPaymentStatus)
                .WithMessage("不支援的支付狀態");
        }

        private bool BeValidPaymentMethod(string paymentMethod)
        {
            var validMethods = new[] { "credit card", "bank transfer", "paypal", "line pay" };
            return validMethods.Contains(paymentMethod?.ToLower());
        }

        private bool BeValidPaymentStatus(string paymentStatus)
        {
            var validStatuses = new[] { "pending", "success", "failed", "refunded", "cancelled" };
            return validStatuses.Contains(paymentStatus?.ToLower());
        }
    }
}
```

### Step 3.5: Service Registration

**Program.cs** (Service Registration Section)
```csharp
// Register N8N API Service (already added in Step 2.5)
builder.Services.AddHttpClient<IN8NApiService, N8NApiService>(client =>
{
    var n8nSettings = builder.Configuration.GetSection("N8NSettings");
    client.BaseAddress = new Uri(n8nSettings["BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(int.Parse(n8nSettings["Timeout"] ?? "30"));

    var apiKey = n8nSettings["ApiKey"];
    if (!string.IsNullOrEmpty(apiKey))
    {
        client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
    }
});

// Register application services
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddScoped<IReportingService, ReportingService>();

// Register memory caching
builder.Services.AddMemoryCache();

// Register validators
builder.Services.AddScoped<IValidator<FilterViewModel>, FilterViewModelValidator>();
builder.Services.AddScoped<IValidator<N8NOrderResponseDto>, N8NOrderResponseValidator>();
```

## Verification Steps
1. Configure N8N API settings in appsettings.json
2. Test N8N API connectivity: `await _n8nApiService.GetOrdersAsync()`
3. Verify service dependency injection registration
4. Test caching functionality with sample data
5. Validate data transformation from N8N DTOs to ViewModels
6. Check logging output in development environment
7. Build the service layer: `dotnet build`
8. Run integration tests with mock N8N responses

## Key Changes from Original Database Approach

### Architecture Changes
1. **Removed Entity Framework Dependencies**: No more `ApplicationDbContext`, `DbSet<Order>`, or database queries
2. **N8N API Integration**: All data retrieval through HTTP client calls to N8N endpoints
3. **In-Memory Processing**: Client-side filtering, sorting, and pagination of API data
4. **Caching Layer**: Added `ICacheService` to cache N8N API responses and improve performance
5. **Data Transformation**: Focus on transforming N8N API responses to application ViewModels

### Service Method Changes
1. **GetOrdersAsync()**: Now fetches from N8N API with client-side filtering
2. **Order Numbers**: Changed from string to integer to match N8N API response format
3. **No CRUD Operations**: Read-only operations since this is a reporting/admin interface
4. **Status Management**: Simplified to focus on payment status from N8N data
5. **Reporting**: Analytics calculated from in-memory N8N data instead of database aggregations

### Performance Optimizations
1. **Response Caching**: 30-minute cache for N8N API responses
2. **Batch Processing**: Single API call for multiple operations where possible
3. **Efficient Transformations**: LINQ-based data processing for filtering and calculations

## Next Steps
After completing the service layer, proceed to:
- 04-Controllers-API.md for MVC controllers and API endpoints
- 05-Views-UI.md for Razor views and user interface implementation