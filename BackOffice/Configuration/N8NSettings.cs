namespace DoDoManBackOffice.Configuration
{
    public class N8NSettings
    {
        public string BaseUrl { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string WebhookSecret { get; set; } = string.Empty;
        public N8NEndpoints Endpoints { get; set; } = new();
    }

    public class N8NEndpoints
    {
        public string OrderStatusUpdate { get; set; } = string.Empty;
        public string PaymentNotification { get; set; } = string.Empty;
        public string CustomerNotification { get; set; } = string.Empty;
    }
}