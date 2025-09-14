using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NHealthCheckBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<N8NHealthCheckBackgroundService> _logger;
        private readonly N8NSettings _n8nSettings;

        public N8NHealthCheckBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<N8NHealthCheckBackgroundService> logger,
            IOptions<N8NSettings> n8nSettings)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
            _n8nSettings = n8nSettings.Value;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            if (!_n8nSettings.HealthCheckEnabled)
            {
                _logger.LogInformation("N8N health check is disabled");
                return;
            }

            _logger.LogInformation("N8N Health Check Background Service started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await PerformHealthCheck();

                    var delayMinutes = _n8nSettings.HealthCheckIntervalMinutes;
                    await Task.Delay(TimeSpan.FromMinutes(delayMinutes), stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in N8N health check background service");
                    await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
                }
            }

            _logger.LogInformation("N8N Health Check Background Service stopped");
        }

        private async Task PerformHealthCheck()
        {
            using var scope = _serviceProvider.CreateScope();
            var healthService = scope.ServiceProvider.GetRequiredService<IN8NHealthService>();

            try
            {
                var healthStatus = await healthService.CheckHealthAsync();

                if (healthStatus.IsConnected)
                {
                    _logger.LogInformation("N8N health check passed: {Message}", healthStatus.Message);
                }
                else
                {
                    _logger.LogWarning("N8N health check failed: {Message}", healthStatus.Message);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during N8N health check");
            }
        }
    }
}