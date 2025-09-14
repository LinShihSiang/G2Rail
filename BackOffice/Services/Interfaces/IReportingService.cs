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