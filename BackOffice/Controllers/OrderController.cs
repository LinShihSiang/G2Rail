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
                TempData["Error"] = "An error occurred while loading the order list. Please try again later.";
                return View(new OrderListViewModel());
            }
        }

        // GET: Order/Details/5
        public async Task<IActionResult> Details(string orderNumber)
        {
            try
            {
                var order = await _orderService.GetOrderByNumberAsync(orderNumber);
                if (order == null)
                {
                    return NotFound("Order not found");
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
                TempData["Error"] = "An error occurred while loading order details.";
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
                TempData["Error"] = "An error occurred while exporting orders.";
                return RedirectToAction(nameof(Index));
            }
        }

        private string GenerateCsv(IEnumerable<OrderViewModel> orders)
        {
            var csv = new System.Text.StringBuilder();
            csv.AppendLine("Order Number,Order Date,Customer Name,Payment Method,Payment Status");

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