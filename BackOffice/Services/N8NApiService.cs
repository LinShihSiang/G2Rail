using DoDoManBackOffice.Models.DTOs;
using System.Text.Json;

namespace DoDoManBackOffice.Services
{
    public interface IN8NApiService
    {
        Task<List<N8NOrderResponseDto>> GetOrdersAsync();
        Task<List<N8NOrderResponseDto>> GetOrdersAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus);
    }

    public class N8NApiService : IN8NApiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<N8NApiService> _logger;

        public N8NApiService(HttpClient httpClient, IConfiguration configuration, ILogger<N8NApiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<List<N8NOrderResponseDto>> GetOrdersAsync()
        {
            try
            {
                var apiUrl = _configuration["N8NSettings:OrdersApiUrl"];
                var response = await _httpClient.GetAsync(apiUrl);
                response.EnsureSuccessStatusCode();

                var jsonContent = await response.Content.ReadAsStringAsync();
                var orders = JsonSerializer.Deserialize<List<N8NOrderResponseDto>>(jsonContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                return orders ?? new List<N8NOrderResponseDto>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching orders from N8N API");
                return new List<N8NOrderResponseDto>();
            }
        }

        public async Task<List<N8NOrderResponseDto>> GetOrdersAsync(DateTime? startDate, DateTime? endDate, int? orderNumber, string? customerName, string? paymentMethod, string? paymentStatus)
        {
            var allOrders = await GetOrdersAsync();

            // Apply client-side filtering using LINQ to Objects (not IQueryable)
            var filteredOrders = allOrders.AsEnumerable();

            if (orderNumber.HasValue)
            {
                filteredOrders = filteredOrders.Where(o => o.OrderNumber == orderNumber.Value);
            }

            if (!string.IsNullOrEmpty(customerName))
            {
                filteredOrders = filteredOrders.Where(o => o.CustomerName.Contains(customerName, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(paymentMethod))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentMethod.Equals(paymentMethod, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(paymentStatus))
            {
                filteredOrders = filteredOrders.Where(o => o.PaymentStatus.Equals(paymentStatus, StringComparison.OrdinalIgnoreCase));
            }

            if (startDate.HasValue || endDate.HasValue)
            {
                filteredOrders = filteredOrders.Where(o =>
                {
                    if (DateTime.TryParse(o.OrderDate, out var orderDate))
                    {
                        if (startDate.HasValue && orderDate.Date < startDate.Value.Date)
                        {
                            return false;
                        }
                        if (endDate.HasValue && orderDate.Date > endDate.Value.Date)
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
    }
}