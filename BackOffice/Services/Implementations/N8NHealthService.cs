using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NHealthService : IN8NHealthService
    {
        private readonly IN8NApiService _n8nApiService;
        private readonly ILogger<N8NHealthService> _logger;

        public N8NHealthService(
            IN8NApiService n8nApiService,
            ILogger<N8NHealthService> logger)
        {
            _n8nApiService = n8nApiService;
            _logger = logger;
        }

        public async Task<N8NHealthStatus> CheckHealthAsync()
        {
            var healthStatus = new N8NHealthStatus
            {
                CheckTime = DateTime.UtcNow
            };

            try
            {
                // Test basic connection by trying to get orders
                var orders = await _n8nApiService.GetOrdersAsync();

                healthStatus.IsConnected = true;
                healthStatus.Status = "Healthy";
                healthStatus.Message = $"N8N API is responding normally. Retrieved {orders.Count()} orders.";
                healthStatus.OrderCount = orders.Count();

                return healthStatus;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "N8N health check failed");
                healthStatus.IsConnected = false;
                healthStatus.Status = "Unhealthy";
                healthStatus.Message = $"N8N API connection failed: {ex.Message}";
                return healthStatus;
            }
        }

        public async Task<bool> TestApiConnectionAsync()
        {
            try
            {
                var orders = await _n8nApiService.GetOrdersAsync();
                _logger.LogInformation("N8N API connection test successful. Retrieved {Count} orders", orders.Count());
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "N8N API connection test failed");
                return false;
            }
        }
    }

    public class N8NHealthStatus
    {
        public DateTime CheckTime { get; set; }
        public bool IsConnected { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int OrderCount { get; set; }
    }
}