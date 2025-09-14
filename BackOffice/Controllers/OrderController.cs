using Microsoft.AspNetCore.Mvc;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.ViewModels;
using FluentValidation;

namespace DoDoManBackOffice.Controllers
{
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