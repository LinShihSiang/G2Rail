using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NCacheInvalidationService : IN8NCacheInvalidationService
    {
        private readonly ICacheService _cacheService;
        private readonly ILogger<N8NCacheInvalidationService> _logger;

        public N8NCacheInvalidationService(
            ICacheService cacheService,
            ILogger<N8NCacheInvalidationService> logger)
        {
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task InvalidateOrderCacheAsync()
        {
            try
            {
                // Remove all order-related cache entries
                await _cacheService.RemoveByPatternAsync("orders_*");
                _logger.LogInformation("Invalidated all order cache entries");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error invalidating order cache");
            }
        }

        public async Task InvalidateOrderCacheAsync(int orderNumber)
        {
            try
            {
                await _cacheService.RemoveAsync($"order_{orderNumber}");
                await InvalidateOrderCacheAsync(); // Also clear list cache
                _logger.LogInformation("Invalidated cache for order {OrderNumber}", orderNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error invalidating cache for order {OrderNumber}", orderNumber);
            }
        }

        public async Task HandleN8NWebhookAsync(string webhookType, object data)
        {
            try
            {
                switch (webhookType.ToLower())
                {
                    case "order.created":
                    case "order.updated":
                    case "order.status.changed":
                    case "payment.status.changed":
                        await InvalidateOrderCacheAsync();
                        break;
                    default:
                        _logger.LogDebug("Unhandled webhook type: {WebhookType}", webhookType);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling N8N webhook: {WebhookType}", webhookType);
            }
        }
    }
}