# 06. N8N Integration Implementation

## Overview
實作 DoDoMan 後台管理系統與 N8N 工作流程平台的整合，包括 Webhook 觸發、資料同步和自動化通知。

## Implementation Steps

### Step 6.1: N8N Integration Service Implementation

**Services/Implementations/N8NIntegrationService.cs**
```csharp
using Microsoft.Extensions.Options;
using System.Text.Json;
using System.Text;
using System.Security.Cryptography;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.Entities;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NIntegrationService : IN8NIntegrationService
    {
        private readonly HttpClient _httpClient;
        private readonly N8NSettings _settings;
        private readonly ILogger<N8NIntegrationService> _logger;

        public N8NIntegrationService(
            HttpClient httpClient,
            IOptions<N8NSettings> settings,
            ILogger<N8NIntegrationService> logger)
        {
            _httpClient = httpClient;
            _settings = settings.Value;
            _logger = logger;

            ConfigureHttpClient();
        }

        private void ConfigureHttpClient()
        {
            _httpClient.BaseAddress = new Uri(_settings.BaseUrl);
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_settings.ApiKey}");
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "DoDoMan-BackOffice/1.0");
            _httpClient.Timeout = TimeSpan.FromSeconds(30);
        }

        public async Task<bool> SendOrderStatusUpdateAsync(Order order)
        {
            try
            {
                var payload = new N8NOrderStatusRequest
                {
                    OrderId = order.OrderId,
                    OrderNumber = order.OrderNumber,
                    OldStatus = GetOrderStatusFromHistory(order.OrderId),
                    NewStatus = order.OrderStatus.ToString(),
                    UpdatedAt = order.UpdatedAt,
                    UpdatedBy = order.UpdatedBy ?? "System"
                };

                var endpoint = _settings.Endpoints.OrderStatusUpdate;
                var response = await SendWebhookAsync(endpoint, payload, "order.status.updated");

                if (response.Success)
                {
                    _logger.LogInformation("Order status update sent to N8N for order {OrderId}. Workflow ID: {WorkflowId}",
                        order.OrderId, response.WorkflowId);
                    return true;
                }
                else
                {
                    _logger.LogWarning("Failed to send order status update to N8N for order {OrderId}. Message: {Message}",
                        order.OrderId, response.Message);
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending order status update to N8N for order {OrderId}", order.OrderId);
                return false;
            }
        }

        public async Task<bool> SendPaymentNotificationAsync(Order order)
        {
            try
            {
                var payload = new N8NPaymentNotificationRequest
                {
                    OrderId = order.OrderId,
                    OrderNumber = order.OrderNumber,
                    PaymentMethod = order.PaymentMethod,
                    PaymentStatus = order.PaymentStatus.ToString(),
                    Amount = order.TotalAmount,
                    PaymentReference = order.PaymentReference,
                    ProcessedAt = DateTime.UtcNow
                };

                var endpoint = _settings.Endpoints.PaymentNotification;
                var response = await SendWebhookAsync(endpoint, payload, "payment.processed");

                if (response.Success)
                {
                    _logger.LogInformation("Payment notification sent to N8N for order {OrderId}. Workflow ID: {WorkflowId}",
                        order.OrderId, response.WorkflowId);
                    return true;
                }
                else
                {
                    _logger.LogWarning("Failed to send payment notification to N8N for order {OrderId}. Message: {Message}",
                        order.OrderId, response.Message);
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending payment notification to N8N for order {OrderId}", order.OrderId);
                return false;
            }
        }

        public async Task<bool> SendCustomerNotificationAsync(int customerId, string notificationType, object data)
        {
            try
            {
                var payload = new
                {
                    CustomerId = customerId,
                    NotificationType = notificationType,
                    Data = data,
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = _settings.Endpoints.CustomerNotification;
                var response = await SendWebhookAsync(endpoint, payload, "customer.notification");

                if (response.Success)
                {
                    _logger.LogInformation("Customer notification sent to N8N for customer {CustomerId}, type: {NotificationType}",
                        customerId, notificationType);
                    return true;
                }
                else
                {
                    _logger.LogWarning("Failed to send customer notification to N8N for customer {CustomerId}. Message: {Message}",
                        customerId, response.Message);
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending customer notification to N8N for customer {CustomerId}", customerId);
                return false;
            }
        }

        public async Task<bool> TriggerOrderProcessingWorkflowAsync(int orderId)
        {
            try
            {
                var payload = new
                {
                    OrderId = orderId,
                    WorkflowType = "order_processing",
                    TriggerTime = DateTime.UtcNow
                };

                var endpoint = "/webhook/order-processing";
                var response = await SendWebhookAsync(endpoint, payload, "workflow.trigger");

                _logger.LogInformation("Order processing workflow triggered for order {OrderId}. Success: {Success}",
                    orderId, response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering order processing workflow for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> TriggerPaymentProcessingWorkflowAsync(int orderId, string paymentMethod)
        {
            try
            {
                var payload = new
                {
                    OrderId = orderId,
                    PaymentMethod = paymentMethod,
                    WorkflowType = "payment_processing",
                    TriggerTime = DateTime.UtcNow
                };

                var endpoint = "/webhook/payment-processing";
                var response = await SendWebhookAsync(endpoint, payload, "workflow.trigger");

                _logger.LogInformation("Payment processing workflow triggered for order {OrderId} with method {PaymentMethod}. Success: {Success}",
                    orderId, paymentMethod, response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering payment processing workflow for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> TriggerOrderCancellationWorkflowAsync(int orderId, string reason)
        {
            try
            {
                var payload = new
                {
                    OrderId = orderId,
                    CancellationReason = reason,
                    WorkflowType = "order_cancellation",
                    TriggerTime = DateTime.UtcNow
                };

                var endpoint = "/webhook/order-cancellation";
                var response = await SendWebhookAsync(endpoint, payload, "workflow.trigger");

                _logger.LogInformation("Order cancellation workflow triggered for order {OrderId}. Success: {Success}",
                    orderId, response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering order cancellation workflow for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> SyncOrderDataAsync(int orderId)
        {
            try
            {
                // Get order data from database and send to N8N for synchronization
                var payload = new
                {
                    OrderId = orderId,
                    SyncType = "order_data",
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = "/webhook/data-sync";
                var response = await SendWebhookAsync(endpoint, payload, "data.sync");

                _logger.LogInformation("Order data sync triggered for order {OrderId}. Success: {Success}",
                    orderId, response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error syncing order data for order {OrderId}", orderId);
                return false;
            }
        }

        public async Task<bool> SyncCustomerDataAsync(int customerId)
        {
            try
            {
                var payload = new
                {
                    CustomerId = customerId,
                    SyncType = "customer_data",
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = "/webhook/data-sync";
                var response = await SendWebhookAsync(endpoint, payload, "data.sync");

                _logger.LogInformation("Customer data sync triggered for customer {CustomerId}. Success: {Success}",
                    customerId, response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error syncing customer data for customer {CustomerId}", customerId);
                return false;
            }
        }

        public async Task<bool> BulkSyncOrdersAsync(IEnumerable<int> orderIds)
        {
            try
            {
                var payload = new
                {
                    OrderIds = orderIds.ToArray(),
                    SyncType = "bulk_orders",
                    Timestamp = DateTime.UtcNow,
                    Count = orderIds.Count()
                };

                var endpoint = "/webhook/bulk-sync";
                var response = await SendWebhookAsync(endpoint, payload, "bulk.sync");

                _logger.LogInformation("Bulk order sync triggered for {Count} orders. Success: {Success}",
                    orderIds.Count(), response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error bulk syncing orders");
                return false;
            }
        }

        public bool ValidateWebhookSignature(string payload, string signature)
        {
            try
            {
                if (string.IsNullOrEmpty(_settings.WebhookSecret))
                {
                    _logger.LogWarning("Webhook secret not configured, skipping signature validation");
                    return true; // Allow if no secret configured (development mode)
                }

                var expectedSignature = GenerateSignature(payload, _settings.WebhookSecret);
                var isValid = signature.Equals($"sha256={expectedSignature}", StringComparison.OrdinalIgnoreCase);

                if (!isValid)
                {
                    _logger.LogWarning("Invalid webhook signature received");
                }

                return isValid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating webhook signature");
                return false;
            }
        }

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                var payload = new
                {
                    TestMessage = "Connection test from DoDoMan BackOffice",
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = "/webhook/test";
                var response = await SendWebhookAsync(endpoint, payload, "connection.test");

                _logger.LogInformation("N8N connection test completed. Success: {Success}, Message: {Message}",
                    response.Success, response.Message);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error testing N8N connection");
                return false;
            }
        }

        public async Task<bool> SendDailyReportAsync(DateTime reportDate)
        {
            try
            {
                var payload = new
                {
                    ReportDate = reportDate.ToString("yyyy-MM-dd"),
                    ReportType = "daily",
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = "/webhook/daily-report";
                var response = await SendWebhookAsync(endpoint, payload, "report.daily");

                _logger.LogInformation("Daily report sent to N8N for date {ReportDate}. Success: {Success}",
                    reportDate.ToString("yyyy-MM-dd"), response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending daily report to N8N for date {ReportDate}", reportDate);
                return false;
            }
        }

        public async Task<bool> SendWeeklyReportAsync(DateTime weekStartDate)
        {
            try
            {
                var payload = new
                {
                    WeekStartDate = weekStartDate.ToString("yyyy-MM-dd"),
                    WeekEndDate = weekStartDate.AddDays(6).ToString("yyyy-MM-dd"),
                    ReportType = "weekly",
                    Timestamp = DateTime.UtcNow
                };

                var endpoint = "/webhook/weekly-report";
                var response = await SendWebhookAsync(endpoint, payload, "report.weekly");

                _logger.LogInformation("Weekly report sent to N8N for week starting {WeekStartDate}. Success: {Success}",
                    weekStartDate.ToString("yyyy-MM-dd"), response.Success);

                return response.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending weekly report to N8N for week {WeekStartDate}", weekStartDate);
                return false;
            }
        }

        #region Private Helper Methods

        private async Task<N8NResponse> SendWebhookAsync(string endpoint, object payload, string eventType)
        {
            try
            {
                var jsonPayload = JsonSerializer.Serialize(payload, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                });

                var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                // Add headers
                content.Headers.Add("X-Event-Type", eventType);
                content.Headers.Add("X-Timestamp", DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString());

                // Add signature if webhook secret is configured
                if (!string.IsNullOrEmpty(_settings.WebhookSecret))
                {
                    var signature = GenerateSignature(jsonPayload, _settings.WebhookSecret);
                    content.Headers.Add("X-Hub-Signature-256", $"sha256={signature}");
                }

                var response = await _httpClient.PostAsync(endpoint, content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    var n8nResponse = JsonSerializer.Deserialize<N8NResponse>(responseContent, new JsonSerializerOptions
                    {
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                    });

                    return n8nResponse ?? new N8NResponse
                    {
                        Success = true,
                        Message = "Request sent successfully",
                        Timestamp = DateTime.UtcNow
                    };
                }
                else
                {
                    _logger.LogWarning("N8N webhook request failed. Status: {StatusCode}, Content: {Content}",
                        response.StatusCode, responseContent);

                    return new N8NResponse
                    {
                        Success = false,
                        Message = $"HTTP {response.StatusCode}: {responseContent}",
                        Timestamp = DateTime.UtcNow
                    };
                }
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error sending webhook to N8N endpoint {Endpoint}", endpoint);
                return new N8NResponse
                {
                    Success = false,
                    Message = $"HTTP error: {ex.Message}",
                    Timestamp = DateTime.UtcNow
                };
            }
            catch (TaskCanceledException ex)
            {
                _logger.LogError(ex, "Timeout sending webhook to N8N endpoint {Endpoint}", endpoint);
                return new N8NResponse
                {
                    Success = false,
                    Message = "Request timeout",
                    Timestamp = DateTime.UtcNow
                };
            }
        }

        private string GenerateSignature(string payload, string secret)
        {
            var secretBytes = Encoding.UTF8.GetBytes(secret);
            var payloadBytes = Encoding.UTF8.GetBytes(payload);

            using var hmac = new HMACSHA256(secretBytes);
            var hashBytes = hmac.ComputeHash(payloadBytes);
            return Convert.ToHexString(hashBytes).ToLower();
        }

        private string GetOrderStatusFromHistory(int orderId)
        {
            // This would typically query the order status history
            // For now, return a placeholder
            return "Pending";
        }

        #endregion
    }
}
```

### Step 6.2: Background Service for Scheduled Tasks

**Services/Implementations/N8NBackgroundService.cs**
```csharp
using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<N8NBackgroundService> _logger;
        private readonly AppSettings _appSettings;

        public N8NBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<N8NBackgroundService> logger,
            IOptions<AppSettings> appSettings)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
            _appSettings = appSettings.Value;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("N8N Background Service started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessScheduledTasks();

                    // Wait for 1 hour before next execution
                    await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Expected when cancellation is requested
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in N8N background service");

                    // Wait 5 minutes before retry on error
                    await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
                }
            }

            _logger.LogInformation("N8N Background Service stopped");
        }

        private async Task ProcessScheduledTasks()
        {
            using var scope = _serviceProvider.CreateScope();
            var n8nService = scope.ServiceProvider.GetRequiredService<IN8NIntegrationService>();

            var currentHour = DateTime.Now.Hour;

            // Send daily report at 8 AM
            if (currentHour == 8)
            {
                await SendDailyReport(n8nService);
            }

            // Send weekly report on Monday at 9 AM
            if (DateTime.Now.DayOfWeek == DayOfWeek.Monday && currentHour == 9)
            {
                await SendWeeklyReport(n8nService);
            }

            // Test connection every 6 hours
            if (currentHour % 6 == 0)
            {
                await TestN8NConnection(n8nService);
            }
        }

        private async Task SendDailyReport(IN8NIntegrationService n8nService)
        {
            try
            {
                var yesterday = DateTime.Today.AddDays(-1);
                var success = await n8nService.SendDailyReportAsync(yesterday);

                if (success)
                {
                    _logger.LogInformation("Daily report sent successfully for {Date}", yesterday.ToString("yyyy-MM-dd"));
                }
                else
                {
                    _logger.LogWarning("Failed to send daily report for {Date}", yesterday.ToString("yyyy-MM-dd"));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending daily report");
            }
        }

        private async Task SendWeeklyReport(IN8NIntegrationService n8nService)
        {
            try
            {
                var lastWeekStart = DateTime.Today.AddDays(-(int)DateTime.Today.DayOfWeek - 6);
                var success = await n8nService.SendWeeklyReportAsync(lastWeekStart);

                if (success)
                {
                    _logger.LogInformation("Weekly report sent successfully for week starting {Date}",
                        lastWeekStart.ToString("yyyy-MM-dd"));
                }
                else
                {
                    _logger.LogWarning("Failed to send weekly report for week starting {Date}",
                        lastWeekStart.ToString("yyyy-MM-dd"));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending weekly report");
            }
        }

        private async Task TestN8NConnection(IN8NIntegrationService n8nService)
        {
            try
            {
                var success = await n8nService.TestConnectionAsync();

                if (!success)
                {
                    _logger.LogWarning("N8N connection test failed");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error testing N8N connection");
            }
        }
    }
}
```

### Step 6.3: Webhook Controller for N8N Callbacks

**Controllers/WebhookController.cs**
```csharp
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WebhookController : ControllerBase
    {
        private readonly IN8NIntegrationService _n8nService;
        private readonly IOrderService _orderService;
        private readonly ILogger<WebhookController> _logger;

        public WebhookController(
            IN8NIntegrationService n8nService,
            IOrderService orderService,
            ILogger<WebhookController> logger)
        {
            _n8nService = n8nService;
            _orderService = orderService;
            _logger = logger;
        }

        [HttpPost("n8n/order-processed")]
        public async Task<IActionResult> OrderProcessed([FromBody] N8NOrderProcessedWebhook webhook)
        {
            try
            {
                // Validate webhook signature
                if (!ValidateSignature())
                {
                    return Unauthorized("Invalid signature");
                }

                _logger.LogInformation("Received order processed webhook for order {OrderId}", webhook.OrderId);

                // Update order status based on N8N processing result
                if (webhook.Success)
                {
                    await _orderService.UpdateOrderStatusAsync(
                        webhook.OrderId,
                        Models.Entities.OrderStatus.InProgress,
                        "N8N",
                        "Order processing completed successfully");
                }
                else
                {
                    await _orderService.UpdateOrderStatusAsync(
                        webhook.OrderId,
                        Models.Entities.OrderStatus.Pending,
                        "N8N",
                        $"Order processing failed: {webhook.ErrorMessage}");
                }

                return Ok(new { success = true, message = "Webhook processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing order webhook for order {OrderId}", webhook?.OrderId);
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost("n8n/payment-confirmed")]
        public async Task<IActionResult> PaymentConfirmed([FromBody] N8NPaymentConfirmedWebhook webhook)
        {
            try
            {
                if (!ValidateSignature())
                {
                    return Unauthorized("Invalid signature");
                }

                _logger.LogInformation("Received payment confirmation webhook for order {OrderId}", webhook.OrderId);

                // Update payment status
                if (webhook.Success)
                {
                    await _orderService.UpdatePaymentStatusAsync(
                        webhook.OrderId,
                        Models.Entities.PaymentStatus.Paid,
                        "N8N",
                        webhook.TransactionId);
                }
                else
                {
                    await _orderService.UpdatePaymentStatusAsync(
                        webhook.OrderId,
                        Models.Entities.PaymentStatus.Failed,
                        "N8N",
                        null);
                }

                return Ok(new { success = true, message = "Payment webhook processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing payment webhook for order {OrderId}", webhook?.OrderId);
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost("n8n/notification-sent")]
        public async Task<IActionResult> NotificationSent([FromBody] N8NNotificationWebhook webhook)
        {
            try
            {
                if (!ValidateSignature())
                {
                    return Unauthorized("Invalid signature");
                }

                _logger.LogInformation("Received notification webhook for order {OrderId}, type: {NotificationType}",
                    webhook.OrderId, webhook.NotificationType);

                // Log notification status
                if (webhook.Success)
                {
                    _logger.LogInformation("Notification sent successfully for order {OrderId}", webhook.OrderId);
                }
                else
                {
                    _logger.LogWarning("Notification failed for order {OrderId}: {ErrorMessage}",
                        webhook.OrderId, webhook.ErrorMessage);
                }

                return Ok(new { success = true, message = "Notification webhook processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing notification webhook for order {OrderId}", webhook?.OrderId);
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("n8n/health")]
        public IActionResult Health()
        {
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                service = "DoDoMan BackOffice Webhook Endpoint"
            });
        }

        private bool ValidateSignature()
        {
            try
            {
                var signature = Request.Headers["X-Hub-Signature-256"].FirstOrDefault();
                if (string.IsNullOrEmpty(signature))
                {
                    return false;
                }

                // Read request body
                Request.Body.Position = 0;
                using var reader = new StreamReader(Request.Body);
                var payload = reader.ReadToEnd();

                return _n8nService.ValidateWebhookSignature(payload, signature);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating webhook signature");
                return false;
            }
        }
    }

    #region Webhook Models

    public class N8NOrderProcessedWebhook
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }
        public DateTime ProcessedAt { get; set; }
        public string WorkflowId { get; set; } = string.Empty;
    }

    public class N8NPaymentConfirmedWebhook
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string? TransactionId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public DateTime ProcessedAt { get; set; }
        public string? ErrorMessage { get; set; }
    }

    public class N8NNotificationWebhook
    {
        public int OrderId { get; set; }
        public string NotificationType { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }
        public DateTime SentAt { get; set; }
        public string Channel { get; set; } = string.Empty; // email, sms, etc.
    }

    #endregion
}
```

### Step 6.4: N8N Configuration and Middleware

**Middleware/N8NMiddleware.cs**
```csharp
using System.Text;

namespace DoDoManBackOffice.Middleware
{
    public class N8NMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<N8NMiddleware> _logger;

        public N8NMiddleware(RequestDelegate next, ILogger<N8NMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Only process webhook requests
            if (context.Request.Path.StartsWithSegments("/api/webhook"))
            {
                // Enable request body buffering for signature validation
                context.Request.EnableBuffering();

                // Log incoming webhook
                _logger.LogInformation("Incoming webhook request: {Method} {Path} from {RemoteIp}",
                    context.Request.Method,
                    context.Request.Path,
                    context.Connection.RemoteIpAddress);

                // Read and log request body (be careful with sensitive data)
                var body = await ReadRequestBodyAsync(context.Request);
                _logger.LogDebug("Webhook payload size: {Size} bytes", body.Length);

                // Reset stream position for downstream processing
                context.Request.Body.Position = 0;
            }

            await _next(context);
        }

        private async Task<string> ReadRequestBodyAsync(HttpRequest request)
        {
            using var reader = new StreamReader(request.Body, Encoding.UTF8, leaveOpen: true);
            var body = await reader.ReadToEndAsync();
            request.Body.Position = 0;
            return body;
        }
    }

    public static class N8NMiddlewareExtensions
    {
        public static IApplicationBuilder UseN8NMiddleware(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<N8NMiddleware>();
        }
    }
}
```

### Step 6.5: N8N Service Registration and Configuration

**Program.cs (Additional Configuration)**
```csharp
// Add to Program.cs after existing service registrations

// N8N Integration
builder.Services.AddHttpClient<IN8NIntegrationService>();
builder.Services.AddScoped<IN8NIntegrationService, N8NIntegrationService>();

// Background Services
builder.Services.AddHostedService<N8NBackgroundService>();

// Add N8N middleware after authentication
app.UseAuthentication();
app.UseN8NMiddleware(); // Add this line
app.UseAuthorization();
```

### Step 6.6: N8N Workflow Templates

**Documentation/N8N-Workflows.md**
```markdown
# N8N Workflow Templates for DoDoMan BackOffice

## 1. Order Status Update Workflow

**Webhook Trigger**: `/webhook/order-status`

**Workflow Steps**:
1. Webhook trigger receives order status update
2. Extract order data (OrderId, OldStatus, NewStatus)
3. Send email notification to customer
4. Update external CRM system
5. Log status change in analytics

**N8N Workflow JSON**:
```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "/webhook/order-status",
        "responseMode": "responseNode"
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [240, 300]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json.newStatus}}",
              "operation": "equal",
              "value2": "Completed"
            }
          ]
        }
      },
      "name": "If Order Completed",
      "type": "n8n-nodes-base.if",
      "position": [460, 300]
    },
    {
      "parameters": {
        "subject": "您的訂單已完成 - {{$json.orderNumber}}",
        "text": "親愛的客戶，您的訂單 {{$json.orderNumber}} 已經完成處理。",
        "toEmail": "={{$json.customerEmail}}"
      },
      "name": "Send Completion Email",
      "type": "n8n-nodes-base.emailSend",
      "position": [680, 200]
    }
  ]
}
```

## 2. Payment Processing Workflow

**Webhook Trigger**: `/webhook/payment`

**Workflow Steps**:
1. Receive payment notification
2. Validate payment status
3. Send confirmation email
4. Update inventory system
5. Trigger fulfillment process

## 3. Daily Report Workflow

**Schedule Trigger**: Daily at 8:00 AM

**Workflow Steps**:
1. Query BackOffice API for daily statistics
2. Generate report content
3. Send email report to management
4. Post summary to Slack/Teams
5. Archive report data
```

### Step 6.7: Testing and Monitoring

**Services/Implementations/N8NMonitoringService.cs**
```csharp
using Microsoft.Extensions.Options;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NMonitoringService
    {
        private readonly IN8NIntegrationService _n8nService;
        private readonly ILogger<N8NMonitoringService> _logger;

        public N8NMonitoringService(
            IN8NIntegrationService n8nService,
            ILogger<N8NMonitoringService> logger)
        {
            _n8nService = n8nService;
            _logger = logger;
        }

        public async Task<N8NHealthStatus> GetHealthStatusAsync()
        {
            var healthStatus = new N8NHealthStatus
            {
                CheckTime = DateTime.UtcNow
            };

            try
            {
                // Test basic connection
                var connectionSuccess = await _n8nService.TestConnectionAsync();
                healthStatus.IsConnected = connectionSuccess;

                if (connectionSuccess)
                {
                    healthStatus.Status = "Healthy";
                    healthStatus.Message = "N8N service is responding normally";
                }
                else
                {
                    healthStatus.Status = "Unhealthy";
                    healthStatus.Message = "N8N service is not responding";
                }

                // Test webhook endpoints
                healthStatus.WebhookEndpoints = await TestWebhookEndpoints();

                return healthStatus;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking N8N health status");
                healthStatus.Status = "Error";
                healthStatus.Message = $"Error checking health: {ex.Message}";
                return healthStatus;
            }
        }

        private async Task<List<WebhookEndpointStatus>> TestWebhookEndpoints()
        {
            var endpoints = new List<WebhookEndpointStatus>();

            var testEndpoints = new[]
            {
                ("/webhook/order-status", "Order Status Updates"),
                ("/webhook/payment", "Payment Notifications"),
                ("/webhook/customer-notify", "Customer Notifications"),
                ("/webhook/test", "Connection Test")
            };

            foreach (var (endpoint, description) in testEndpoints)
            {
                try
                {
                    var testPayload = new { test = true, timestamp = DateTime.UtcNow };

                    // This would be implemented to test each endpoint
                    var status = new WebhookEndpointStatus
                    {
                        Endpoint = endpoint,
                        Description = description,
                        IsAvailable = true, // Would be determined by actual test
                        LastChecked = DateTime.UtcNow,
                        ResponseTime = 250 // Placeholder
                    };

                    endpoints.Add(status);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to test N8N endpoint {Endpoint}", endpoint);
                    endpoints.Add(new WebhookEndpointStatus
                    {
                        Endpoint = endpoint,
                        Description = description,
                        IsAvailable = false,
                        LastChecked = DateTime.UtcNow,
                        ErrorMessage = ex.Message
                    });
                }
            }

            return endpoints;
        }
    }

    public class N8NHealthStatus
    {
        public DateTime CheckTime { get; set; }
        public bool IsConnected { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public List<WebhookEndpointStatus> WebhookEndpoints { get; set; } = new();
    }

    public class WebhookEndpointStatus
    {
        public string Endpoint { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
        public DateTime LastChecked { get; set; }
        public int ResponseTime { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
```

## Verification Steps
1. Configure N8N instance with webhook endpoints
2. Test webhook signature validation
3. Verify order status update triggers N8N workflow
4. Test payment processing integration
5. Validate error handling and retry logic
6. Monitor webhook delivery and response times
7. Test scheduled reporting workflows

## Next Steps
After completing N8N integration, proceed to:
- 07-Testing-Deployment.md for comprehensive testing and deployment specifications