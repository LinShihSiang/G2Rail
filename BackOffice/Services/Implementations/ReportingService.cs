using DoDoManBackOffice.Models.DTOs;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public class ReportingService : IReportingService
    {
        private readonly IOrderService _orderService;
        private readonly ILogger<ReportingService> _logger;

        public ReportingService(IOrderService orderService, ILogger<ReportingService> logger)
        {
            _orderService = orderService;
            _logger = logger;
        }

        public async Task<DashboardSummaryDto> GetDashboardSummaryAsync()
        {
            try
            {
                var summary = await _orderService.GetDashboardSummaryAsync();
                var paymentMethods = await _orderService.GetPaymentMethodSummaryAsync();
                var today = DateTime.Today;
                var todayOrders = await _orderService.GetOrdersFromN8NAsync(today, today, null, null, null, null);

                return new DashboardSummaryDto
                {
                    TotalOrders = summary.TotalOrders,
                    TodayOrders = todayOrders.Count(),
                    PendingOrders = summary.PendingOrders,
                    SuccessfulOrders = summary.SuccessfulOrders,
                    SuccessRate = summary.TotalOrders > 0 ? (decimal)summary.SuccessfulOrders / summary.TotalOrders * 100 : 0,
                    PaymentMethods = paymentMethods,
                    RecentTrends = new List<DailyOrderCountDto>() // TODO: Implement trend calculation
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting dashboard summary");
                return new DashboardSummaryDto();
            }
        }

        public async Task<IEnumerable<PaymentMethodSummaryDto>> GetPaymentMethodBreakdownAsync()
        {
            return await _orderService.GetPaymentMethodSummaryAsync();
        }

        public async Task<IEnumerable<DailyOrderCountDto>> GetDailyOrderTrendsAsync(DateTime startDate, DateTime endDate)
        {
            // TODO: Implement daily order trends calculation
            return new List<DailyOrderCountDto>();
        }

        public async Task<OrderReportDto> GenerateOrderReportAsync(DateTime? startDate, DateTime? endDate)
        {
            try
            {
                var orders = await _orderService.GetOrdersFromN8NAsync(startDate, endDate, null, null, null, null);
                var orderViewModels = await _orderService.TransformN8NDataAsync(orders);
                var summary = await _orderService.GetOrderSummaryAsync(startDate, endDate);

                return new OrderReportDto
                {
                    GeneratedAt = DateTime.Now,
                    StartDate = startDate,
                    EndDate = endDate,
                    TotalOrders = orders.Count(),
                    Orders = orderViewModels,
                    Summary = summary
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating order report");
                return new OrderReportDto();
            }
        }

        public async Task<byte[]> ExportOrdersToExcelAsync(FilterViewModel filter)
        {
            // TODO: Implement Excel export
            throw new NotImplementedException("Excel export not yet implemented");
        }

        public async Task<byte[]> ExportOrdersToPdfAsync(FilterViewModel filter)
        {
            // TODO: Implement PDF export
            throw new NotImplementedException("PDF export not yet implemented");
        }

        public async Task<IEnumerable<OrderStatusCountDto>> GetOrderStatusDistributionAsync()
        {
            return await _orderService.GetOrderStatusCountsAsync();
        }

        public async Task<CustomerAnalyticsDto> GetCustomerAnalyticsAsync()
        {
            try
            {
                var orders = await _orderService.GetOrdersFromN8NAsync();
                var orderViewModels = await _orderService.TransformN8NDataAsync(orders);

                var uniqueCustomers = orderViewModels.Select(o => o.CustomerName).Distinct().Count();
                var topCustomers = orderViewModels
                    .GroupBy(o => o.CustomerName)
                    .Select(g => new TopCustomerDto
                    {
                        CustomerName = g.Key,
                        OrderCount = g.Count()
                    })
                    .OrderByDescending(c => c.OrderCount)
                    .Take(10);

                return new CustomerAnalyticsDto
                {
                    TotalCustomers = uniqueCustomers,
                    NewCustomersThisMonth = 0, // TODO: Calculate new customers
                    TopCustomers = topCustomers
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting customer analytics");
                return new CustomerAnalyticsDto();
            }
        }
    }
}