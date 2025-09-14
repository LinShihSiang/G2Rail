namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IN8NCacheInvalidationService
    {
        Task InvalidateOrderCacheAsync();
        Task InvalidateOrderCacheAsync(int orderNumber);
        Task HandleN8NWebhookAsync(string webhookType, object data);
    }
}