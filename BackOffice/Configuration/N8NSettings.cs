namespace DoDoManBackOffice.Configuration
{
    public class N8NSettings
    {
        public string BaseUrl { get; set; } = "https://howardmei.app.n8n.cloud";
        public string OrdersApiUrl { get; set; } = "https://howardmei.app.n8n.cloud/webhook/get-order";
        public string ApiKey { get; set; } = string.Empty;
        public string WebhookSecret { get; set; } = string.Empty;
        public int Timeout { get; set; } = 30;

        // Health Check Settings
        public int HealthCheckIntervalMinutes { get; set; } = 60;
        public bool HealthCheckEnabled { get; set; } = true;

        // Webhook Endpoints (for receiving callbacks from N8N)
        public N8NWebhookEndpoints WebhookEndpoints { get; set; } = new();
    }

    public class N8NWebhookEndpoints
    {
        public string OrderUpdated { get; set; } = "/api/n8nwebhook/order-updated";
        public string DataChanged { get; set; } = "/api/n8nwebhook/data-changed";
        public string Health { get; set; } = "/api/n8nwebhook/health";
    }
}