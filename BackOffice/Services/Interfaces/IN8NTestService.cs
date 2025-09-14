using DoDoManBackOffice.Services.Implementations;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IN8NTestService
    {
        Task<N8NTestResult> RunIntegrationTestAsync();
        Task<N8NTestResult> TestOrderRetrievalAsync();
        Task<N8NTestResult> TestCacheInvalidationAsync();
    }
}