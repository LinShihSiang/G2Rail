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