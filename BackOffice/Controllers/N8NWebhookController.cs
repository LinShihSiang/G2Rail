using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Services.Implementations;

namespace DoDoManBackOffice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class N8NWebhookController : ControllerBase
    {
        private readonly IN8NCacheInvalidationService _cacheInvalidationService;
        private readonly ILogger<N8NWebhookController> _logger;

        public N8NWebhookController(
            IN8NCacheInvalidationService cacheInvalidationService,
            ILogger<N8NWebhookController> logger)
        {
            _cacheInvalidationService = cacheInvalidationService;
            _logger = logger;
        }

        [HttpPost("order-updated")]
        public async Task<IActionResult> OrderUpdated([FromBody] N8NOrderUpdateWebhook webhook)
        {
            try
            {
                _logger.LogInformation("Received order update webhook for order {OrderNumber}", webhook.OrderNumber);

                await _cacheInvalidationService.InvalidateOrderCacheAsync(webhook.OrderNumber);

                return Ok(new { success = true, message = "Cache invalidated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing order update webhook");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost("data-changed")]
        public async Task<IActionResult> DataChanged([FromBody] N8NDataChangeWebhook webhook)
        {
            try
            {
                _logger.LogInformation("Received data change webhook: {ChangeType}", webhook.ChangeType);

                await _cacheInvalidationService.HandleN8NWebhookAsync(webhook.ChangeType, webhook.Data);

                return Ok(new { success = true, message = "Webhook processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing data change webhook");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                service = "DoDoMan BackOffice N8N Webhook Endpoint"
            });
        }
    }

    public class N8NOrderUpdateWebhook
    {
        public string OrderNumber { get; set; } = string.Empty;
        public string ChangeType { get; set; } = string.Empty;
        public DateTime UpdatedAt { get; set; }
    }

    public class N8NDataChangeWebhook
    {
        public string ChangeType { get; set; } = string.Empty;
        public object Data { get; set; } = new();
        public DateTime Timestamp { get; set; }
    }
}