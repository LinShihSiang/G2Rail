# 03. Service Layer Implementation

## Overview
實作 DoDoMan 後台管理系統的業務邏輯層，包括訂單管理服務、N8N 整合服務和支付服務。

## Implementation Steps

### Step 3.1: Service Interfaces

**Services/Interfaces/IOrderService.cs**
```csharp
using DoDoManBackOffice.Models.Entities;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IOrderService
    {
        // Query Methods
        Task<OrderListViewModel> GetOrdersAsync(FilterViewModel filter);
        Task<OrderDto?> GetOrderByIdAsync(int orderId);
        Task<OrderDto?> GetOrderByNumberAsync(string orderNumber);
        Task<IEnumerable<OrderDto>> GetOrdersByCustomerAsync(int customerId);

        // CRUD Operations
        Task<int> CreateOrderAsync(OrderDto orderDto);
        Task<bool> UpdateOrderAsync(OrderDto orderDto);
        Task<bool> DeleteOrderAsync(int orderId);

        // Status Management
        Task<bool> UpdateOrderStatusAsync(int orderId, OrderStatus newStatus, string updatedBy, string? reason = null);
        Task<bool> UpdatePaymentStatusAsync(int orderId, PaymentStatus newStatus, string updatedBy, string? paymentReference = null);

        // Business Logic
        Task<string> GenerateOrderNumberAsync();
        Task<bool> CanCancelOrderAsync(int orderId);
        Task<bool> CancelOrderAsync(int orderId, string cancelledBy, string reason);
        Task<decimal> CalculateOrderTotalAsync(int orderId);

        // Reporting
        Task<OrderSummaryDto> GetOrderSummaryAsync(DateTime? startDate = null, DateTime? endDate = null);
        Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusCountsAsync();
        Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodSummaryAsync();

        // Search and Filter
        Task<IEnumerable<OrderDto>> SearchOrdersAsync(string searchTerm);
        Task<IEnumerable<string>> GetOrderNumberSuggestionsAsync(string partialOrderNumber);
    }

    // Supporting DTOs
    public class OrderSummaryDto
    {
        public int TotalOrders { get; set; }
        public decimal TotalRevenue { get; set; }
        public int PendingOrders { get; set; }
        public int CompletedOrders { get; set; }
        public int CancelledOrders { get; set; }
        public decimal AverageOrderValue { get; set; }
    }

    public class OrderStatusCountDto
    {
        public OrderStatus Status { get; set; }
        public int Count { get; set; }
        public string DisplayName { get; set; } = string.Empty;
    }

    public class PaymentMethodSummaryDto
    {
        public string PaymentMethod { get; set; } = string.Empty;
        public int Count { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal Percentage { get; set; }
    }
}
```

**Services/Interfaces/IN8NIntegrationService.cs**
```csharp
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IN8NIntegrationService
    {
        // Webhook Methods
        Task<bool> SendOrderStatusUpdateAsync(Order order);
        Task<bool> SendPaymentNotificationAsync(Order order);
        Task<bool> SendCustomerNotificationAsync(int customerId, string notificationType, object data);

        // Workflow Triggers
        Task<bool> TriggerOrderProcessingWorkflowAsync(int orderId);
        Task<bool> TriggerPaymentProcessingWorkflowAsync(int orderId, string paymentMethod);
        Task<bool> TriggerOrderCancellationWorkflowAsync(int orderId, string reason);

        // Data Synchronization
        Task<bool> SyncOrderDataAsync(int orderId);
        Task<bool> SyncCustomerDataAsync(int customerId);
        Task<bool> BulkSyncOrdersAsync(IEnumerable<int> orderIds);

        // Webhook Validation
        bool ValidateWebhookSignature(string payload, string signature);
        Task<bool> TestConnectionAsync();

        // Analytics and Reporting
        Task<bool> SendDailyReportAsync(DateTime reportDate);
        Task<bool> SendWeeklyReportAsync(DateTime weekStartDate);
    }

    // N8N Request/Response Models
    public class N8NOrderStatusRequest
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public string OldStatus { get; set; } = string.Empty;
        public string NewStatus { get; set; } = string.Empty;
        public DateTime UpdatedAt { get; set; }
        public string UpdatedBy { get; set; } = string.Empty;
    }

    public class N8NPaymentNotificationRequest
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = string.Empty;
        public string PaymentStatus { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string? PaymentReference { get; set; }
        public DateTime ProcessedAt { get; set; }
    }

    public class N8NResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? WorkflowId { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
```

### Step 3.2: Order Service Implementation

**Services/Implementations/OrderService.cs**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using DoDoManBackOffice.Data;
using DoDoManBackOffice.Models.Entities;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private readonly ApplicationDbContext _context;
        private readonly AppSettings _appSettings;
        private readonly IN8NIntegrationService _n8nService;
        private readonly ILogger<OrderService> _logger;

        public OrderService(
            ApplicationDbContext context,
            IOptions<AppSettings> appSettings,
            IN8NIntegrationService n8nService,
            ILogger<OrderService> logger)
        {
            _context = context;
            _appSettings = appSettings.Value;
            _n8nService = n8nService;
            _logger = logger;
        }

        public async Task<OrderListViewModel> GetOrdersAsync(FilterViewModel filter)
        {
            try
            {
                var query = _context.Orders
                    .Include(o => o.Customer)
                    .AsQueryable();

                // Apply filters
                query = ApplyFilters(query, filter);

                // Get total count for pagination
                var totalCount = await query.CountAsync();

                // Apply pagination
                var orders = await query
                    .OrderByDescending(o => o.OrderDate)
                    .Skip((filter.Page - 1) * filter.PageSize)
                    .Take(filter.PageSize)
                    .Select(o => new OrderViewModel
                    {
                        OrderId = o.OrderId,
                        OrderNumber = o.OrderNumber,
                        OrderDate = o.OrderDate,
                        CustomerName = o.Customer.FullName,
                        CustomerEmail = o.Customer.Email,
                        PaymentMethod = o.PaymentMethod,
                        PaymentStatus = o.PaymentStatus,
                        OrderStatus = o.OrderStatus,
                        TotalAmount = o.TotalAmount,
                        Notes = o.Notes
                    })
                    .ToListAsync();

                // Calculate summary statistics
                var summary = await CalculateSummaryAsync(query);

                return new OrderListViewModel
                {
                    Orders = orders,
                    Filter = filter,
                    Pagination = new PaginationViewModel
                    {
                        CurrentPage = filter.Page,
                        PageSize = filter.PageSize,
                        TotalItems = totalCount
                    },
                    TotalOrders = summary.TotalOrders,
                    TotalRevenue = summary.TotalRevenue,
                    PendingOrders = summary.PendingOrders,
                    CompletedOrders = summary.CompletedOrders
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving orders with filter");
                throw;
            }
        }

        public async Task<OrderDto?> GetOrderByIdAsync(int orderId)
        {
            try
            {
                var order = await _context.Orders
                    .Include(o => o.Customer)
                    .Include(o => o.OrderItems)
                    .FirstOrDefaultAsync(o => o.OrderId == orderId);

                if (order == null)
                    return null;

                return MapToOrderDto(order);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving order {OrderId}", orderId);
                throw;
            }
        }

        public async Task<string> GenerateOrderNumberAsync()
        {
            try
            {
                var year = DateTime.Now.Year;
                var prefix = $"DDM{year}";

                var lastOrder = await _context.Orders
                    .Where(o => o.OrderNumber.StartsWith(prefix))
                    .OrderByDescending(o => o.OrderNumber)
                    .FirstOrDefaultAsync();

                if (lastOrder == null)
                {
                    return $"{prefix}001";
                }

                var lastNumberStr = lastOrder.OrderNumber.Substring(prefix.Length);
                if (int.TryParse(lastNumberStr, out int lastNumber))
                {
                    return $"{prefix}{(lastNumber + 1):D3}";
                }

                return $"{prefix}001";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating order number");
                throw;
            }
        }

        public async Task<bool> UpdateOrderStatusAsync(int orderId, OrderStatus newStatus, string updatedBy, string? reason = null)
        {
            try
            {
                var order = await _context.Orders.FindAsync(orderId);
                if (order == null)
                    return false;

                var oldStatus = order.OrderStatus;
                order.OrderStatus = newStatus;
                order.UpdatedAt = DateTime.UtcNow;
                order.UpdatedBy = updatedBy;

                // Add status history
                var history = new OrderStatusHistory
                {
                    OrderId = orderId,
                    FromStatus = oldStatus,
                    ToStatus = newStatus,
                    ChangedAt = DateTime.UtcNow,
                    ChangedBy = updatedBy,
                    Reason = reason
                };

                _context.OrderStatusHistories.Add(history);

                await _context.SaveChangesAsync();

                // Trigger N8N workflow
                await _n8nService.SendOrderStatusUpdateAsync(order);

                _logger.LogInformation("Order {OrderId} status updated from {OldStatus} to {NewStatus} by {UpdatedBy}",
                    orderId, oldStatus, newStatus, updatedBy);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating order status for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> UpdatePaymentStatusAsync(int orderId, PaymentStatus newStatus, string updatedBy, string? paymentReference = null)
        {
            try
            {
                var order = await _context.Orders.FindAsync(orderId);
                if (order == null)
                    return false;

                order.PaymentStatus = newStatus;
                order.UpdatedAt = DateTime.UtcNow;
                order.UpdatedBy = updatedBy;

                if (!string.IsNullOrEmpty(paymentReference))
                    order.PaymentReference = paymentReference;

                await _context.SaveChangesAsync();

                // Trigger N8N workflow
                await _n8nService.SendPaymentNotificationAsync(order);

                _logger.LogInformation("Order {OrderId} payment status updated to {PaymentStatus} by {UpdatedBy}",
                    orderId, newStatus, updatedBy);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating payment status for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> CanCancelOrderAsync(int orderId)
        {
            var order = await _context.Orders.FindAsync(orderId);
            if (order == null)
                return false;

            // Business rules for cancellation
            return order.OrderStatus == OrderStatus.Pending ||
                   order.OrderStatus == OrderStatus.Confirmed;
        }

        public async Task<bool> CancelOrderAsync(int orderId, string cancelledBy, string reason)
        {
            try
            {
                if (!await CanCancelOrderAsync(orderId))
                    return false;

                var order = await _context.Orders.FindAsync(orderId);
                if (order == null)
                    return false;

                var oldStatus = order.OrderStatus;
                order.OrderStatus = OrderStatus.Cancelled;
                order.PaymentStatus = PaymentStatus.Cancelled;
                order.UpdatedAt = DateTime.UtcNow;
                order.UpdatedBy = cancelledBy;
                order.Notes = $"Cancelled: {reason}";

                // Add status history
                var history = new OrderStatusHistory
                {
                    OrderId = orderId,
                    FromStatus = oldStatus,
                    ToStatus = OrderStatus.Cancelled,
                    ChangedAt = DateTime.UtcNow,
                    ChangedBy = cancelledBy,
                    Reason = reason
                };

                _context.OrderStatusHistories.Add(history);

                await _context.SaveChangesAsync();

                // Trigger N8N cancellation workflow
                await _n8nService.TriggerOrderCancellationWorkflowAsync(orderId, reason);

                _logger.LogInformation("Order {OrderId} cancelled by {CancelledBy}. Reason: {Reason}",
                    orderId, cancelledBy, reason);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<OrderSummaryDto> GetOrderSummaryAsync(DateTime? startDate = null, DateTime? endDate = null)
        {
            try
            {
                var query = _context.Orders.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(o => o.OrderDate >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(o => o.OrderDate <= endDate.Value);

                var summary = await query
                    .GroupBy(o => 1)
                    .Select(g => new OrderSummaryDto
                    {
                        TotalOrders = g.Count(),
                        TotalRevenue = g.Sum(o => o.TotalAmount),
                        PendingOrders = g.Count(o => o.OrderStatus == OrderStatus.Pending),
                        CompletedOrders = g.Count(o => o.OrderStatus == OrderStatus.Completed),
                        CancelledOrders = g.Count(o => o.OrderStatus == OrderStatus.Cancelled),
                        AverageOrderValue = g.Average(o => o.TotalAmount)
                    })
                    .FirstOrDefaultAsync();

                return summary ?? new OrderSummaryDto();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating order summary");
                throw;
            }
        }

        public async Task<IEnumerable<string>> GetOrderNumberSuggestionsAsync(string partialOrderNumber)
        {
            try
            {
                return await _context.Orders
                    .Where(o => o.OrderNumber.Contains(partialOrderNumber))
                    .Select(o => o.OrderNumber)
                    .Take(10)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting order number suggestions");
                return new List<string>();
            }
        }

        #region Private Helper Methods

        private IQueryable<Order> ApplyFilters(IQueryable<Order> query, FilterViewModel filter)
        {
            if (filter.StartDate.HasValue)
                query = query.Where(o => o.OrderDate >= filter.StartDate.Value);

            if (filter.EndDate.HasValue)
                query = query.Where(o => o.OrderDate <= filter.EndDate.Value.AddDays(1));

            if (!string.IsNullOrEmpty(filter.OrderNumber))
                query = query.Where(o => o.OrderNumber.Contains(filter.OrderNumber));

            if (!string.IsNullOrEmpty(filter.CustomerName))
                query = query.Where(o => (o.Customer.FirstName + " " + o.Customer.LastName).Contains(filter.CustomerName));

            if (!string.IsNullOrEmpty(filter.PaymentMethod))
                query = query.Where(o => o.PaymentMethod == filter.PaymentMethod);

            if (filter.PaymentStatus.HasValue)
                query = query.Where(o => o.PaymentStatus == filter.PaymentStatus.Value);

            if (filter.OrderStatus.HasValue)
                query = query.Where(o => o.OrderStatus == filter.OrderStatus.Value);

            return query;
        }

        private async Task<OrderSummaryDto> CalculateSummaryAsync(IQueryable<Order> query)
        {
            return await query
                .GroupBy(o => 1)
                .Select(g => new OrderSummaryDto
                {
                    TotalOrders = g.Count(),
                    TotalRevenue = g.Sum(o => o.TotalAmount),
                    PendingOrders = g.Count(o => o.OrderStatus == OrderStatus.Pending),
                    CompletedOrders = g.Count(o => o.OrderStatus == OrderStatus.Completed)
                })
                .FirstOrDefaultAsync() ?? new OrderSummaryDto();
        }

        private OrderDto MapToOrderDto(Order order)
        {
            return new OrderDto
            {
                OrderId = order.OrderId,
                OrderNumber = order.OrderNumber,
                OrderDate = order.OrderDate,
                CustomerName = order.Customer.FullName,
                CustomerEmail = order.Customer.Email,
                TotalAmount = order.TotalAmount,
                PaymentMethod = order.PaymentMethod,
                PaymentStatus = order.PaymentStatus,
                OrderStatus = order.OrderStatus,
                Notes = order.Notes,
                CreatedAt = order.CreatedAt,
                UpdatedAt = order.UpdatedAt,
                OrderItems = order.OrderItems.Select(oi => new OrderItemDto
                {
                    OrderItemId = oi.OrderItemId,
                    ProductName = oi.ProductName,
                    ProductType = oi.ProductType,
                    Quantity = oi.Quantity,
                    UnitPrice = oi.UnitPrice,
                    TotalPrice = oi.TotalPrice,
                    Description = oi.Description
                }).ToList()
            };
        }

        #endregion

        // Additional interface methods implementation...
        public async Task<OrderDto?> GetOrderByNumberAsync(string orderNumber)
        {
            var order = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderNumber == orderNumber);

            return order != null ? MapToOrderDto(order) : null;
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersByCustomerAsync(int customerId)
        {
            var orders = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.OrderItems)
                .Where(o => o.CustomerId == customerId)
                .ToListAsync();

            return orders.Select(MapToOrderDto);
        }

        public async Task<int> CreateOrderAsync(OrderDto orderDto)
        {
            // Implementation for creating orders
            throw new NotImplementedException("To be implemented based on business requirements");
        }

        public async Task<bool> UpdateOrderAsync(OrderDto orderDto)
        {
            // Implementation for updating orders
            throw new NotImplementedException("To be implemented based on business requirements");
        }

        public async Task<bool> DeleteOrderAsync(int orderId)
        {
            // Implementation for deleting orders (soft delete recommended)
            throw new NotImplementedException("To be implemented based on business requirements");
        }

        public async Task<decimal> CalculateOrderTotalAsync(int orderId)
        {
            var total = await _context.OrderItems
                .Where(oi => oi.OrderId == orderId)
                .SumAsync(oi => oi.TotalPrice);

            return total;
        }

        public async Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusCountsAsync()
        {
            var counts = await _context.Orders
                .GroupBy(o => o.OrderStatus)
                .Select(g => new OrderStatusCountDto
                {
                    Status = g.Key,
                    Count = g.Count(),
                    DisplayName = GetStatusDisplayName(g.Key)
                })
                .ToListAsync();

            return counts;
        }

        public async Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodSummaryAsync()
        {
            var totalAmount = await _context.Orders.SumAsync(o => o.TotalAmount);

            var summary = await _context.Orders
                .GroupBy(o => o.PaymentMethod)
                .Select(g => new PaymentMethodSummaryDto
                {
                    PaymentMethod = g.Key,
                    Count = g.Count(),
                    TotalAmount = g.Sum(o => o.TotalAmount),
                    Percentage = totalAmount > 0 ? (g.Sum(o => o.TotalAmount) / totalAmount) * 100 : 0
                })
                .ToListAsync();

            return summary;
        }

        public async Task<IEnumerable<OrderDto>> SearchOrdersAsync(string searchTerm)
        {
            var orders = await _context.Orders
                .Include(o => o.Customer)
                .Include(o => o.OrderItems)
                .Where(o => o.OrderNumber.Contains(searchTerm) ||
                           o.Customer.FirstName.Contains(searchTerm) ||
                           o.Customer.LastName.Contains(searchTerm) ||
                           o.Customer.Email.Contains(searchTerm))
                .Take(50)
                .ToListAsync();

            return orders.Select(MapToOrderDto);
        }

        private string GetStatusDisplayName(OrderStatus status)
        {
            return status switch
            {
                OrderStatus.Pending => "待處理",
                OrderStatus.Confirmed => "已確認",
                OrderStatus.InProgress => "進行中",
                OrderStatus.Completed => "已完成",
                OrderStatus.Cancelled => "已取消",
                _ => "未知"
            };
        }
    }
}
```

### Step 3.3: Validation Services

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
                .MaximumLength(20)
                .WithMessage("訂單編號不能超過20個字元");

            RuleFor(x => x.CustomerName)
                .MaximumLength(100)
                .WithMessage("客戶姓名不能超過100個字元");

            RuleFor(x => x.PageSize)
                .GreaterThan(0)
                .LessThanOrEqualTo(100)
                .WithMessage("每頁顯示筆數必須在1-100之間");
        }
    }

    public class OrderDtoValidator : AbstractValidator<OrderDto>
    {
        public OrderDtoValidator()
        {
            RuleFor(x => x.OrderNumber)
                .NotEmpty()
                .WithMessage("訂單編號不能為空")
                .MaximumLength(20)
                .WithMessage("訂單編號不能超過20個字元");

            RuleFor(x => x.CustomerName)
                .NotEmpty()
                .WithMessage("客戶姓名不能為空")
                .MaximumLength(200)
                .WithMessage("客戶姓名不能超過200個字元");

            RuleFor(x => x.CustomerEmail)
                .NotEmpty()
                .WithMessage("客戶Email不能為空")
                .EmailAddress()
                .WithMessage("Email格式不正確");

            RuleFor(x => x.TotalAmount)
                .GreaterThan(0)
                .WithMessage("總金額必須大於0");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty()
                .WithMessage("支付方式不能為空")
                .Must(BeValidPaymentMethod)
                .WithMessage("不支援的支付方式");
        }

        private bool BeValidPaymentMethod(string paymentMethod)
        {
            var validMethods = new[] { "CreditCard", "BankTransfer", "PayPal", "LinePay" };
            return validMethods.Contains(paymentMethod);
        }
    }
}
```

## Verification Steps
1. Build the service layer: `dotnet build`
2. Run unit tests for services: `dotnet test`
3. Verify dependency injection registration
4. Test service methods with mock data
5. Check logging output in development

## Next Steps
After completing the service layer, proceed to:
- 04-Controllers-API.md for MVC controllers and API endpoints
- 05-N8N-Integration.md for N8N workflow integration