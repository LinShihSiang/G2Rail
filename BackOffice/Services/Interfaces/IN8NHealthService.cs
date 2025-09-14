using DoDoManBackOffice.Services.Implementations;

namespace DoDoManBackOffice.Services.Interfaces
{
    public interface IN8NHealthService
    {
        Task<N8NHealthStatus> CheckHealthAsync();
        Task<bool> TestApiConnectionAsync();
    }
}