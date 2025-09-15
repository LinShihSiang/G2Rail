using Microsoft.AspNetCore.Mvc;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Services;

namespace DoDoManBackOffice.Controllers
{
    public class DashboardController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly IN8NApiService _n8nApiService;
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(
            IOrderService orderService,
            IN8NApiService n8nApiService,
            ILogger<DashboardController> logger)
        {
            _orderService = orderService;
            _n8nApiService = n8nApiService;
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

                // Get subscriber count from N8N API
                var subscribers = await _n8nApiService.GetSubscribersAsync();

                viewModel.TodayOrderCount = todaySummary.TotalOrders;
                viewModel.MonthOrderCount = monthSummary.TotalOrders;
                viewModel.PendingOrderCount = todaySummary.PendingOrders;
                viewModel.SuccessfulOrderCount = todaySummary.SuccessfulOrders;
                viewModel.SubscriberCount = subscribers.Count;

                viewModel.StatusCounts = statusCounts.ToList();
                viewModel.PaymentMethodSummary = paymentSummary.ToList();
                viewModel.RecentOrders = recentOrders.Orders.Take(10).ToList();

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading dashboard");
                TempData["Error"] = "An error occurred while loading the dashboard.";
                return View(new DashboardViewModel());
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

        // Subscriber Count from N8N API
        public int SubscriberCount { get; set; }

        // Detailed Statistics
        public List<OrderStatusCountDto> StatusCounts { get; set; } = new();
        public List<PaymentMethodSummaryDto> PaymentMethodSummary { get; set; } = new();

        // Recent Orders
        public List<OrderViewModel> RecentOrders { get; set; } = new();
    }
}