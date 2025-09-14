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

                // Get all orders from cache or API (without filter-specific caching)
                var cacheKey = $"all_orders_{DateTime.Now:yyyy-MM-dd-HH}";
                var cachedOrders = await _cacheService.GetAsync<List<N8NOrderResponseDto>>(cacheKey);

                List<N8NOrderResponseDto> allOrders;
                if (cachedOrders != null)
                {
                    allOrders = cachedOrders;
                }
                else
                {
                    // Fetch all orders from N8N API (without filters first to cache raw data)
                    allOrders = (await _n8nApiService.GetOrdersAsync()).ToList();

                    // Cache all orders for 30 minutes
                    await _cacheService.SetAsync(cacheKey, allOrders, TimeSpan.FromMinutes(30));
                }

                // Apply filters to all orders (whether from cache or API)
                var n8nOrders = ApplyFilters(allOrders, filter);

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
                _logger.LogError(ex, "Error validating order number {OrderNumber}", orderNumber);
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
                _logger.LogError(ex, "Error retrieving orders for customer {CustomerName}", customerName);
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
                _logger.LogError(ex, "Error calculating order summary");
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
                _logger.LogError(ex, "Error getting order status counts");
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

        private List<N8NOrderResponseDto> ApplyFilters(List<N8NOrderResponseDto> orders, FilterViewModel filter)
        {
            var filteredOrders = orders.AsEnumerable();

            if (filter.OrderNumber.HasValue)
            {
                filteredOrders = filteredOrders.Where(o => o.OrderNumber == filter.OrderNumber.Value);
            }

            if (!string.IsNullOrEmpty(filter.CustomerName))
            {
                filteredOrders = filteredOrders.Where(o => o.CustomerName.Contains(filter.CustomerName, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(filter.PaymentMethod))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentMethod.Equals(filter.PaymentMethod, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(filter.PaymentStatus))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentStatus.Equals(filter.PaymentStatus, StringComparison.OrdinalIgnoreCase));
            }

            if (filter.StartDate.HasValue || filter.EndDate.HasValue)
            {
                filteredOrders = filteredOrders.Where(o =>
                {
                    if (DateTime.TryParse(o.OrderDate, out var orderDate))
                    {
                        if (filter.StartDate.HasValue && orderDate.Date < filter.StartDate.Value.Date)
                        {
                            return false;
                        }
                        if (filter.EndDate.HasValue && orderDate.Date > filter.EndDate.Value.Date)
                        {
                            return false;
                        }
                        return true;
                    }
                    return false;
                });
            }

            return filteredOrders.ToList();
        }

        private string GetStatusDisplayName(PaymentStatus status)
        {
            return status switch
            {
                PaymentStatus.Pending => "Pending",
                PaymentStatus.Success => "Paid",
                PaymentStatus.Failed => "Failed",
                PaymentStatus.Refunded => "Refunded",
                PaymentStatus.Cancelled => "Cancelled",
                _ => "Unknown"
            };
        }

        #endregion
    }
}