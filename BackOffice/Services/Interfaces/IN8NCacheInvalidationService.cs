namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IN8NCacheInvalidationService
    {
        Task InvalidateOrderCacheAsync();
        Task InvalidateOrderCacheAsync(string orderNumber);
        Task HandleN8NWebhookAsync(string webhookType, object data);
    }
}