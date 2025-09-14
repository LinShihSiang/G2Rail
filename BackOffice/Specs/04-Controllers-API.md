# 04. Controllers and API Implementation

## Overview
實作 DoDoMan 後台管理系統的 MVC Controllers 和 API 端點，包括訂單管理介面和外部整合 API。

## Implementation Steps

### Step 4.1: Order Management Controller

**Controllers/OrderController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Controllers
{
    [Authorize]
    public class OrderController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly ILogger<OrderController> _logger;

        public OrderController(IOrderService orderService, ILogger<OrderController> logger)
        {
            _orderService = orderService;
            _logger = logger;
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
        public async Task<IActionResult> Details(int id)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(id);
                if (order == null)
                {
                    return NotFound("找不到指定的訂單");
                }

                var viewModel = new OrderDetailsViewModel
                {
                    Order = order,
                    CanCancel = await _orderService.CanCancelOrderAsync(id)
                };

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading order details for order {OrderId}", id);
                TempData["Error"] = "載入訂單詳情時發生錯誤。";
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Order/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(id);
                if (order == null)
                {
                    return NotFound();
                }

                var viewModel = new OrderEditViewModel
                {
                    OrderId = order.OrderId,
                    OrderNumber = order.OrderNumber,
                    CustomerName = order.CustomerName,
                    CustomerEmail = order.CustomerEmail,
                    PaymentMethod = order.PaymentMethod,
                    PaymentStatus = order.PaymentStatus,
                    OrderStatus = order.OrderStatus,
                    TotalAmount = order.TotalAmount,
                    Notes = order.Notes
                };

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading edit form for order {OrderId}", id);
                TempData["Error"] = "載入編輯表單時發生錯誤。";
                return RedirectToAction(nameof(Index));
            }
        }

        // POST: Order/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, OrderEditViewModel model)
        {
            if (id != model.OrderId)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                var currentUser = User.Identity?.Name ?? "System";

                // Update order status if changed
                if (model.OriginalOrderStatus != model.OrderStatus)
                {
                    await _orderService.UpdateOrderStatusAsync(
                        model.OrderId,
                        model.OrderStatus,
                        currentUser,
                        model.StatusChangeReason);
                }

                // Update payment status if changed
                if (model.OriginalPaymentStatus != model.PaymentStatus)
                {
                    await _orderService.UpdatePaymentStatusAsync(
                        model.OrderId,
                        model.PaymentStatus,
                        currentUser,
                        model.PaymentReference);
                }

                TempData["Success"] = "訂單更新成功！";
                return RedirectToAction(nameof(Details), new { id = model.OrderId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating order {OrderId}", id);
                ModelState.AddModelError("", "更新訂單時發生錯誤，請稍後再試。");
                return View(model);
            }
        }

        // POST: Order/UpdateStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateStatus(int orderId, OrderStatus newStatus, string? reason)
        {
            try
            {
                var currentUser = User.Identity?.Name ?? "System";
                var result = await _orderService.UpdateOrderStatusAsync(orderId, newStatus, currentUser, reason);

                if (result)
                {
                    return Json(new { success = true, message = "訂單狀態更新成功" });
                }
                else
                {
                    return Json(new { success = false, message = "訂單狀態更新失敗" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating order status for order {OrderId}", orderId);
                return Json(new { success = false, message = "更新訂單狀態時發生錯誤" });
            }
        }

        // POST: Order/Cancel
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Cancel(int orderId, string reason)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(reason))
                {
                    return Json(new { success = false, message = "取消原因不能為空" });
                }

                var currentUser = User.Identity?.Name ?? "System";
                var result = await _orderService.CancelOrderAsync(orderId, currentUser, reason);

                if (result)
                {
                    return Json(new { success = true, message = "訂單取消成功" });
                }
                else
                {
                    return Json(new { success = false, message = "無法取消此訂單" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling order {OrderId}", orderId);
                return Json(new { success = false, message = "取消訂單時發生錯誤" });
            }
        }

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
                var results = suggestions.Select(s => new { value = s, label = s }).ToList();

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
            csv.AppendLine("訂單編號,訂單日期,客戶姓名,客戶Email,支付方式,支付狀態,訂單狀態,總金額,備註");

            foreach (var order in orders)
            {
                csv.AppendLine($"\"{order.OrderNumber}\"," +
                              $"\"{order.OrderDate:yyyy-MM-dd HH:mm}\"," +
                              $"\"{order.CustomerName}\"," +
                              $"\"{order.CustomerEmail}\"," +
                              $"\"{order.PaymentMethod}\"," +
                              $"\"{order.PaymentStatusDisplay}\"," +
                              $"\"{order.OrderStatusDisplay}\"," +
                              $"\"{order.TotalAmount:N2}\"," +
                              $"\"{order.Notes?.Replace("\"", "\"\"")}\"");
            }

            return csv.ToString();
        }
    }

    // Supporting ViewModels
    public class OrderDetailsViewModel
    {
        public OrderDto Order { get; set; } = null!;
        public bool CanCancel { get; set; }
        public List<OrderStatusHistory> StatusHistory { get; set; } = new();
    }

    public class OrderEditViewModel
    {
        public int OrderId { get; set; }

        [Display(Name = "訂單編號")]
        public string OrderNumber { get; set; } = string.Empty;

        [Display(Name = "客戶姓名")]
        public string CustomerName { get; set; } = string.Empty;

        [Display(Name = "客戶Email")]
        public string CustomerEmail { get; set; } = string.Empty;

        [Display(Name = "支付方式")]
        public string PaymentMethod { get; set; } = string.Empty;

        [Display(Name = "支付狀態")]
        public PaymentStatus PaymentStatus { get; set; }

        [Display(Name = "訂單狀態")]
        public OrderStatus OrderStatus { get; set; }

        [Display(Name = "總金額")]
        public decimal TotalAmount { get; set; }

        [Display(Name = "備註")]
        public string? Notes { get; set; }

        // Hidden fields for tracking changes
        public PaymentStatus OriginalPaymentStatus { get; set; }
        public OrderStatus OriginalOrderStatus { get; set; }

        [Display(Name = "狀態變更原因")]
        public string? StatusChangeReason { get; set; }

        [Display(Name = "付款參考編號")]
        public string? PaymentReference { get; set; }
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
                viewModel.TodayRevenue = todaySummary.TotalRevenue;
                viewModel.MonthOrderCount = monthSummary.TotalOrders;
                viewModel.MonthRevenue = monthSummary.TotalRevenue;
                viewModel.PendingOrderCount = todaySummary.PendingOrders;
                viewModel.CompletedOrderCount = todaySummary.CompletedOrders;

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
                        orders = g.Count(),
                        revenue = g.Sum(o => o.TotalAmount)
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
        public decimal TodayRevenue { get; set; }

        // This Month's Stats
        public int MonthOrderCount { get; set; }
        public decimal MonthRevenue { get; set; }

        // Status Counts
        public int PendingOrderCount { get; set; }
        public int CompletedOrderCount { get; set; }

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
using DoDoManBackOffice.Models.Entities;
using System.ComponentModel.DataAnnotations;

namespace DoDoManBackOffice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ApiController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly IN8NIntegrationService _n8nService;
        private readonly ILogger<ApiController> _logger;

        public ApiController(
            IOrderService orderService,
            IN8NIntegrationService n8nService,
            ILogger<ApiController> logger)
        {
            _orderService = orderService;
            _n8nService = n8nService;
            _logger = logger;
        }

        // GET: api/Api/orders
        [HttpGet("orders")]
        [Authorize(Roles = "Admin,ApiUser")]
        public async Task<ActionResult<ApiResponse<IEnumerable<OrderDto>>>> GetOrders(
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
                    OrderStatus = request.OrderStatus,
                    Page = request.Page,
                    PageSize = Math.Min(request.PageSize, 100) // Limit max page size
                };

                var result = await _orderService.GetOrdersAsync(filter);
                var orders = result.Orders.Select(o => new OrderDto
                {
                    OrderId = o.OrderId,
                    OrderNumber = o.OrderNumber,
                    OrderDate = o.OrderDate,
                    CustomerName = o.CustomerName,
                    CustomerEmail = o.CustomerEmail,
                    TotalAmount = o.TotalAmount,
                    PaymentMethod = o.PaymentMethod,
                    PaymentStatus = o.PaymentStatus,
                    OrderStatus = o.OrderStatus,
                    Notes = o.Notes
                });

                return Ok(new ApiResponse<IEnumerable<OrderDto>>
                {
                    Success = true,
                    Data = orders,
                    TotalCount = result.Pagination.TotalItems,
                    Page = result.Pagination.CurrentPage,
                    PageSize = result.Pagination.PageSize,
                    Message = "Orders retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving orders via API");
                return StatusCode(500, new ApiResponse<IEnumerable<OrderDto>>
                {
                    Success = false,
                    Message = "Internal server error occurred while retrieving orders"
                });
            }
        }

        // GET: api/Api/orders/{id}
        [HttpGet("orders/{id}")]
        [Authorize(Roles = "Admin,ApiUser")]
        public async Task<ActionResult<ApiResponse<OrderDto>>> GetOrder(int id)
        {
            try
            {
                var order = await _orderService.GetOrderByIdAsync(id);
                if (order == null)
                {
                    return NotFound(new ApiResponse<OrderDto>
                    {
                        Success = false,
                        Message = $"Order with ID {id} not found"
                    });
                }

                return Ok(new ApiResponse<OrderDto>
                {
                    Success = true,
                    Data = order,
                    Message = "Order retrieved successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving order {OrderId} via API", id);
                return StatusCode(500, new ApiResponse<OrderDto>
                {
                    Success = false,
                    Message = "Internal server error occurred while retrieving order"
                });
            }
        }

        // PUT: api/Api/orders/{id}/status
        [HttpPut("orders/{id}/status")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<ApiResponse<object>>> UpdateOrderStatus(
            int id,
            [FromBody] UpdateOrderStatusRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Invalid request data",
                        Errors = ModelState.Values
                            .SelectMany(v => v.Errors)
                            .Select(e => e.ErrorMessage)
                            .ToList()
                    });
                }

                var result = await _orderService.UpdateOrderStatusAsync(
                    id,
                    request.NewStatus,
                    request.UpdatedBy ?? "API",
                    request.Reason);

                if (result)
                {
                    return Ok(new ApiResponse<object>
                    {
                        Success = true,
                        Message = "Order status updated successfully"
                    });
                }
                else
                {
                    return BadRequest(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Failed to update order status"
                    });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating order status for order {OrderId} via API", id);
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = "Internal server error occurred while updating order status"
                });
            }
        }

        // POST: api/Api/webhook/n8n
        [HttpPost("webhook/n8n")]
        [AllowAnonymous] // Validate via webhook signature instead
        public async Task<IActionResult> N8NWebhook([FromBody] N8NWebhookRequest request)
        {
            try
            {
                // Validate webhook signature
                var signature = Request.Headers["X-N8N-Signature"].FirstOrDefault();
                if (string.IsNullOrEmpty(signature))
                {
                    return BadRequest("Missing webhook signature");
                }

                var payload = await new StreamReader(Request.Body).ReadToEndAsync();
                if (!_n8nService.ValidateWebhookSignature(payload, signature))
                {
                    return Unauthorized("Invalid webhook signature");
                }

                // Process webhook based on type
                var result = request.Type switch
                {
                    "order.status.updated" => await ProcessOrderStatusWebhook(request),
                    "payment.processed" => await ProcessPaymentWebhook(request),
                    "customer.notification.sent" => await ProcessNotificationWebhook(request),
                    _ => false
                };

                if (result)
                {
                    return Ok(new { success = true, message = "Webhook processed successfully" });
                }
                else
                {
                    return BadRequest(new { success = false, message = "Failed to process webhook" });
                }
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

        #region Private Helper Methods

        private async Task<bool> ProcessOrderStatusWebhook(N8NWebhookRequest request)
        {
            // Process order status update from N8N
            // Implementation depends on specific N8N workflow requirements
            return await Task.FromResult(true);
        }

        private async Task<bool> ProcessPaymentWebhook(N8NWebhookRequest request)
        {
            // Process payment notification from N8N
            // Implementation depends on specific payment processing workflow
            return await Task.FromResult(true);
        }

        private async Task<bool> ProcessNotificationWebhook(N8NWebhookRequest request)
        {
            // Process notification confirmation from N8N
            // Implementation depends on specific notification workflow
            return await Task.FromResult(true);
        }

        #endregion
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
        public string? OrderNumber { get; set; }
        public string? PaymentMethod { get; set; }
        public PaymentStatus? PaymentStatus { get; set; }
        public OrderStatus? OrderStatus { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }

    public class UpdateOrderStatusRequest
    {
        [Required]
        public OrderStatus NewStatus { get; set; }

        public string? UpdatedBy { get; set; }

        [StringLength(500)]
        public string? Reason { get; set; }
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
2. Test web interface navigation
3. Test API endpoints with Postman/curl
4. Verify authentication and authorization
5. Test error handling and logging
6. Validate model binding and validation

## Next Steps
After completing the controllers, proceed to:
- 05-UI-Views.md for Razor views and frontend implementation
- 06-N8N-Integration.md for detailed N8N workflow integration