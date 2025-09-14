# 04. Controllers and API Implementation

## Overview
實作 DoDoMan 後台管理系統的 MVC Controllers 和 API 端點，基於 N8N API 整合的無資料庫架構，專注於訂單資料展示和管理介面。

## Implementation Steps

### Step 4.1: Order Management Controller

**Controllers/OrderController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;
using FluentValidation;

namespace DoDoManBackOffice.Controllers
{
    [Authorize]
    public class OrderController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly ILogger<OrderController> _logger;
        private readonly IValidator<FilterViewModel> _filterValidator;

        public OrderController(
            IOrderService orderService,
            ILogger<OrderController> logger,
            IValidator<FilterViewModel> filterValidator)
        {
            _orderService = orderService;
            _logger = logger;
            _filterValidator = filterValidator;
        }

        // GET: Order/Index
        public async Task<IActionResult> Index(FilterViewModel? filter)
        {
            try
            {
                filter ??= new FilterViewModel();

                // Set default date range if not provided
                if (!filter.StartDate.HasValue && !filter.EndDate.HasValue)
                {
                    filter.EndDate = DateTime.Today;
                    filter.StartDate = DateTime.Today.AddDays(-30);
                }

                // Validate filter
                var validationResult = await _filterValidator.ValidateAsync(filter);
                if (!validationResult.IsValid)
                {
                    foreach (var error in validationResult.Errors)
                    {
                        ModelState.AddModelError(error.PropertyName, error.ErrorMessage);
                    }
                    return View(new OrderListViewModel { Filter = filter });
                }

                var viewModel = await _orderService.GetOrdersAsync(filter);
                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading order index page");
                TempData["Error"] = "載入訂單列表時發生錯誤，請稍後再試。";
                return View(new OrderListViewModel());
            }
        }

        // GET: Order/Details/5
        public async Task<IActionResult> Details(int orderNumber)
        {
            try
            {
                var order = await _orderService.GetOrderByNumberAsync(orderNumber);
                if (order == null)
                {
                    return NotFound("找不到指定的訂單");
                }

                var viewModel = new OrderDetailsViewModel
                {
                    Order = order
                };

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading order details for order {OrderNumber}", orderNumber);
                TempData["Error"] = "載入訂單詳情時發生錯誤。";
                return RedirectToAction(nameof(Index));
            }
        }

        // Note: Read-Only System - No Edit/Update Operations
        // This is a reporting/view-only system for N8N data

        // GET: Order/Search (AJAX)
        [HttpGet]
        public async Task<IActionResult> Search(string term)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(term) || term.Length < 2)
                {
                    return Json(new List<object>());
                }

                var suggestions = await _orderService.GetOrderNumberSuggestionsAsync(term);
                var results = suggestions.Select(s => new { value = s, label = s.ToString() }).ToList();

                return Json(results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching orders with term {SearchTerm}", term);
                return Json(new List<object>());
            }
        }

        // GET: Order/Export (CSV/Excel export)
        public async Task<IActionResult> Export(FilterViewModel filter, string format = "csv")
        {
            try
            {
                filter ??= new FilterViewModel { PageSize = int.MaxValue };
                var orders = await _orderService.GetOrdersAsync(filter);

                if (format.ToLower() == "csv")
                {
                    var csv = GenerateCsv(orders.Orders);
                    var fileName = $"Orders_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                    return File(System.Text.Encoding.UTF8.GetBytes(csv), "text/csv", fileName);
                }

                // Default to CSV if format not supported
                var defaultCsv = GenerateCsv(orders.Orders);
                var defaultFileName = $"Orders_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                return File(System.Text.Encoding.UTF8.GetBytes(defaultCsv), "text/csv", defaultFileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exporting orders");
                TempData["Error"] = "匯出訂單時發生錯誤。";
                return RedirectToAction(nameof(Index));
            }
        }

        private string GenerateCsv(IEnumerable<OrderViewModel> orders)
        {
            var csv = new System.Text.StringBuilder();
            csv.AppendLine("訂單編號,訂單日期,客戶姓名,支付方式,支付狀態");

            foreach (var order in orders)
            {
                csv.AppendLine($"\"{order.OrderNumber}\"," +
                              $"\"{order.OrderDate:yyyy-MM-dd HH:mm}\"," +
                              $"\"{order.CustomerName}\"," +
                              $"\"{order.PaymentMethod}\"," +
                              $"\"{order.PaymentStatusDisplay}\"");
            }

            return csv.ToString();
        }
    }

    // Supporting ViewModels
    public class OrderDetailsViewModel
    {
        public OrderViewModel Order { get; set; } = null!;
    }
}
```

### Step 4.2: Dashboard Controller

**Controllers/DashboardController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;

namespace DoDoManBackOffice.Controllers
{
    [Authorize]
    public class DashboardController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(IOrderService orderService, ILogger<DashboardController> logger)
        {
            _orderService = orderService;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                var viewModel = new DashboardViewModel();

                // Get today's summary
                var todaySummary = await _orderService.GetOrderSummaryAsync(
                    DateTime.Today,
                    DateTime.Today.AddDays(1));

                // Get this month's summary
                var monthStart = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                var monthSummary = await _orderService.GetOrderSummaryAsync(monthStart, null);

                // Get status counts
                var statusCounts = await _orderService.GetOrderStatusCountsAsync();

                // Get payment method summary
                var paymentSummary = await _orderService.GetPaymentMethodSummaryAsync();

                // Get recent orders (last 10)
                var recentOrdersFilter = new FilterViewModel
                {
                    PageSize = 10,
                    Page = 1
                };
                var recentOrders = await _orderService.GetOrdersAsync(recentOrdersFilter);

                viewModel.TodayOrderCount = todaySummary.TotalOrders;
                viewModel.MonthOrderCount = monthSummary.TotalOrders;
                viewModel.PendingOrderCount = todaySummary.PendingOrders;
                viewModel.SuccessfulOrderCount = todaySummary.SuccessfulOrders;

                viewModel.StatusCounts = statusCounts.ToList();
                viewModel.PaymentMethodSummary = paymentSummary.ToList();
                viewModel.RecentOrders = recentOrders.Orders.Take(10).ToList();

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading dashboard");
                TempData["Error"] = "載入儀表板時發生錯誤。";
                return View(new DashboardViewModel());
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetOrderChartData(string period = "week")
        {
            try
            {
                var endDate = DateTime.Today;
                var startDate = period switch
                {
                    "week" => endDate.AddDays(-7),
                    "month" => endDate.AddDays(-30),
                    "quarter" => endDate.AddDays(-90),
                    _ => endDate.AddDays(-7)
                };

                var filter = new FilterViewModel
                {
                    StartDate = startDate,
                    EndDate = endDate,
                    PageSize = int.MaxValue
                };

                var orders = await _orderService.GetOrdersAsync(filter);

                var chartData = orders.Orders
                    .GroupBy(o => o.OrderDate.Date)
                    .OrderBy(g => g.Key)
                    .Select(g => new
                    {
                        date = g.Key.ToString("yyyy-MM-dd"),
                        orders = g.Count()
                    })
                    .ToList();

                return Json(chartData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chart data for period {Period}", period);
                return Json(new List<object>());
            }
        }
    }

    public class DashboardViewModel
    {
        // Today's Stats
        public int TodayOrderCount { get; set; }

        // This Month's Stats
        public int MonthOrderCount { get; set; }

        // Status Counts
        public int PendingOrderCount { get; set; }
        public int SuccessfulOrderCount { get; set; }

        // Detailed Statistics
        public List<OrderStatusCountDto> StatusCounts { get; set; } = new();
        public List<PaymentMethodSummaryDto> PaymentMethodSummary { get; set; } = new();

        // Recent Orders
        public List<OrderViewModel> RecentOrders { get; set; } = new();
    }
}
```

### Step 4.3: API Controller for External Integration

**Controllers/ApiController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Models.ViewModels;
using System.ComponentModel.DataAnnotations;

namespace DoDoManBackOffice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ApiController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly IN8NApiService _n8nApiService;
        private readonly ILogger<ApiController> _logger;

        public ApiController(
            IOrderService orderService,
            IN8NApiService n8nApiService,
            ILogger<ApiController> logger)
        {
            _orderService = orderService;
            _n8nApiService = n8nApiService;
            _logger = logger;
        }

        // GET: api/Api/orders
        [HttpGet("orders")]
        [Authorize(Roles = "Admin,ApiUser")]
        public async Task<ActionResult<ApiResponse<IEnumerable<OrderViewModel>>>> GetOrders(
            [FromQuery] ApiOrderFilterRequest request)
        {
            try
            {
                var filter = new FilterViewModel
                {
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    OrderNumber = request.OrderNumber,
                    PaymentMethod = request.PaymentMethod,
                    PaymentStatus = request.PaymentStatus,
                    Page = request.Page,
                    PageSize = Math.Min(request.PageSize, 100) // Limit max page size
                };

                var result = await _orderService.GetOrdersAsync(filter);

                return Ok(new ApiResponse<IEnumerable<OrderViewModel>>
                {
                    Success = true,
                    Data = result.Orders,
                    TotalCount = result.Pagination.TotalItems,
                    Page = result.Pagination.CurrentPage,
                    PageSize = result.Pagination.PageSize,
                    Message = "Orders retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving orders via API");
                return StatusCode(500, new ApiResponse<IEnumerable<OrderViewModel>>
                {
                    Success = false,
                    Message = "Internal server error occurred while retrieving orders"
                });
            }
        }

        // GET: api/Api/orders/{orderNumber}
        [HttpGet("orders/{orderNumber}")]
        [Authorize(Roles = "Admin,ApiUser")]
        public async Task<ActionResult<ApiResponse<OrderViewModel>>> GetOrder(int orderNumber)
        {
            try
            {
                var order = await _orderService.GetOrderByNumberAsync(orderNumber);
                if (order == null)
                {
                    return NotFound(new ApiResponse<OrderViewModel>
                    {
                        Success = false,
                        Message = $"Order with number {orderNumber} not found"
                    });
                }

                return Ok(new ApiResponse<OrderViewModel>
                {
                    Success = true,
                    Data = order,
                    Message = "Order retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving order {OrderNumber} via API", orderNumber);
                return StatusCode(500, new ApiResponse<OrderViewModel>
                {
                    Success = false,
                    Message = "Internal server error occurred while retrieving order"
                });
            }
        }

        // Note: Read-Only API - No status update operations
        // This system displays N8N data and does not modify source data

        // POST: api/Api/webhook/n8n
        [HttpPost("webhook/n8n")]
        [AllowAnonymous] // Optional: For cache invalidation notifications from N8N
        public async Task<IActionResult> N8NWebhook([FromBody] N8NWebhookRequest request)
        {
            try
            {
                // Simple webhook receiver for cache invalidation
                // When N8N data changes, clear relevant caches
                _logger.LogInformation("Received N8N webhook: {Type}", request.Type);

                // For a read-only system, we mainly use this to invalidate caches
                // Implementation would depend on specific caching strategy
                return Ok(new { success = true, message = "Webhook received" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing N8N webhook");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        // GET: api/Api/summary
        [HttpGet("summary")]
        [Authorize(Roles = "Admin,ApiUser")]
        public async Task<ActionResult<ApiResponse<OrderSummaryDto>>> GetSummary(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate)
        {
            try
            {
                var summary = await _orderService.GetOrderSummaryAsync(startDate, endDate);

                return Ok(new ApiResponse<OrderSummaryDto>
                {
                    Success = true,
                    Data = summary,
                    Message = "Summary retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving summary via API");
                return StatusCode(500, new ApiResponse<OrderSummaryDto>
                {
                    Success = false,
                    Message = "Internal server error occurred while retrieving summary"
                });
            }
        }

        // Additional API endpoints can be added here as needed
    }

    #region API Request/Response Models

    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public T? Data { get; set; }
        public string Message { get; set; } = string.Empty;
        public List<string>? Errors { get; set; }
        public int? TotalCount { get; set; }
        public int? Page { get; set; }
        public int? PageSize { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    public class ApiOrderFilterRequest
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? OrderNumber { get; set; }
        public string? CustomerName { get; set; }
        public string? PaymentMethod { get; set; }
        public string? PaymentStatus { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }

    public class N8NWebhookRequest
    {
        public string Type { get; set; } = string.Empty;
        public object Data { get; set; } = new();
        public DateTime Timestamp { get; set; }
        public string WorkflowId { get; set; } = string.Empty;
    }

    #endregion
}
```

### Step 4.4: Base Controller for Common Functionality

**Controllers/BaseController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace DoDoManBackOffice.Controllers
{
    public abstract class BaseController : Controller
    {
        protected readonly ILogger _logger;

        protected BaseController(ILogger logger)
        {
            _logger = logger;
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            // Log all controller actions
            _logger.LogInformation("Executing action {Action} in controller {Controller} by user {User}",
                context.ActionDescriptor.DisplayName,
                context.Controller.GetType().Name,
                User.Identity?.Name ?? "Anonymous");

            base.OnActionExecuting(context);
        }

        public override void OnActionExecuted(ActionExecutedContext context)
        {
            // Log action completion
            if (context.Exception != null)
            {
                _logger.LogError(context.Exception,
                    "Error in action {Action} in controller {Controller}",
                    context.ActionDescriptor.DisplayName,
                    context.Controller.GetType().Name);
            }

            base.OnActionExecuted(context);
        }

        protected IActionResult JsonSuccess(string message = "Operation completed successfully", object? data = null)
        {
            return Json(new
            {
                success = true,
                message,
                data
            });
        }

        protected IActionResult JsonError(string message = "An error occurred", object? errors = null)
        {
            return Json(new
            {
                success = false,
                message,
                errors
            });
        }

        protected void AddSuccessMessage(string message)
        {
            TempData["Success"] = message;
        }

        protected void AddErrorMessage(string message)
        {
            TempData["Error"] = message;
        }

        protected void AddWarningMessage(string message)
        {
            TempData["Warning"] = message;
        }

        protected void AddInfoMessage(string message)
        {
            TempData["Info"] = message;
        }
    }
}
```

### Step 4.5: Error Handling and Global Filters

**Filters/GlobalExceptionFilter.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace DoDoManBackOffice.Filters
{
    public class GlobalExceptionFilter : IExceptionFilter
    {
        private readonly ILogger<GlobalExceptionFilter> _logger;
        private readonly IWebHostEnvironment _environment;

        public GlobalExceptionFilter(ILogger<GlobalExceptionFilter> logger, IWebHostEnvironment environment)
        {
            _logger = logger;
            _environment = environment;
        }

        public void OnException(ExceptionContext context)
        {
            _logger.LogError(context.Exception,
                "Unhandled exception in {Controller}.{Action}",
                context.RouteData.Values["controller"],
                context.RouteData.Values["action"]);

            if (context.HttpContext.Request.Headers["Content-Type"].ToString().Contains("application/json") ||
                context.HttpContext.Request.Path.StartsWithSegments("/api"))
            {
                // API request - return JSON error
                context.Result = new JsonResult(new
                {
                    success = false,
                    message = _environment.IsDevelopment()
                        ? context.Exception.Message
                        : "An internal server error occurred",
                    timestamp = DateTime.UtcNow
                })
                {
                    StatusCode = 500
                };
            }
            else
            {
                // Web request - redirect to error page
                context.Result = new RedirectToActionResult("Error", "Home", null);
            }

            context.ExceptionHandled = true;
        }
    }
}
```

## Verification Steps
1. Build the controllers: `dotnet build`
2. Test web interface navigation with N8N data
3. Test API endpoints with Postman/curl
4. Verify authentication and authorization
5. Test error handling and logging
6. Validate N8N API integration
7. Test filtering and pagination with N8N data
8. Verify cache invalidation webhooks

## Key Changes from Original Database Approach

### Architecture Changes
1. **Read-Only Controllers**: Removed all CRUD operations, focusing on data display and filtering
2. **N8N Data Integration**: Controllers now work with `OrderViewModel` directly from N8N API responses
3. **Simplified API**: Removed status update endpoints since this is a reporting system
4. **Order Identification**: Changed from database IDs to N8N order numbers
5. **Validation Integration**: Added FluentValidation for request validation

### Controller Method Changes
1. **Index Method**: Uses `FilterViewModel` with N8N API service
2. **Details Method**: Uses order number instead of database ID
3. **Export Method**: Simplified CSV export with N8N data fields
4. **API Endpoints**: Return `OrderViewModel` instead of `OrderDto`
5. **Dashboard**: Displays N8N-based statistics and summaries

### Data Flow Changes
1. **Controller → Service → N8N API**: Direct data flow from N8N
2. **Caching Layer**: Controllers benefit from service-level caching
3. **Client-side Processing**: Filtering and pagination handled in-memory
4. **Webhook Support**: Optional cache invalidation from N8N updates

## Next Steps
After completing the controllers, proceed to:
- 05-UI-Views.md for Razor views and frontend implementation
- 06-N8N-Integration.md for detailed N8N workflow integration
- Implementation of the actual controller classes based on these specifications