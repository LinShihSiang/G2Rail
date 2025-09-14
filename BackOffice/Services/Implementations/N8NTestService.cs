using DoDoManBackOffice.Services.Interfaces;

namespace DoDoManBackOffice.Services.Implementations
{
    public class N8NTestService : IN8NTestService
    {
        private readonly IN8NApiService _n8nApiService;
        private readonly IN8NHealthService _healthService;
        private readonly IN8NCacheInvalidationService _cacheService;
        private readonly ILogger<N8NTestService> _logger;

        public N8NTestService(
            IN8NApiService n8nApiService,
            IN8NHealthService healthService,
            IN8NCacheInvalidationService cacheService,
            ILogger<N8NTestService> logger)
        {
            _n8nApiService = n8nApiService;
            _healthService = healthService;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<N8NTestResult> RunIntegrationTestAsync()
        {
            var testResult = new N8NTestResult
            {
                TestName = "N8N Integration Test",
                StartTime = DateTime.UtcNow
            };

            try
            {
                // Test 1: Health Check
                var healthCheck = await _healthService.CheckHealthAsync();
                testResult.AddTest("Health Check", healthCheck.IsConnected, healthCheck.Message);

                if (!healthCheck.IsConnected)
                {
                    testResult.Success = false;
                    testResult.EndTime = DateTime.UtcNow;
                    return testResult;
                }

                // Test 2: Order Retrieval
                var orderTest = await TestOrderRetrievalAsync();
                testResult.AddTest("Order Retrieval", orderTest.Success, orderTest.Message);

                // Test 3: Cache Invalidation
                var cacheTest = await TestCacheInvalidationAsync();
                testResult.AddTest("Cache Invalidation", cacheTest.Success, cacheTest.Message);

                testResult.Success = testResult.TestResults.All(t => t.Success);
                testResult.EndTime = DateTime.UtcNow;

                return testResult;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error running N8N integration test");
                testResult.Success = false;
                testResult.Message = $"Test failed with exception: {ex.Message}";
                testResult.EndTime = DateTime.UtcNow;
                return testResult;
            }
        }

        public async Task<N8NTestResult> TestOrderRetrievalAsync()
        {
            try
            {
                var orders = await _n8nApiService.GetOrdersAsync();
                return new N8NTestResult
                {
                    TestName = "Order Retrieval Test",
                    Success = true,
                    Message = $"Successfully retrieved {orders.Count()} orders from N8N API"
                };
            }
            catch (Exception ex)
            {
                return new N8NTestResult
                {
                    TestName = "Order Retrieval Test",
                    Success = false,
                    Message = $"Failed to retrieve orders: {ex.Message}"
                };
            }
        }

        public async Task<N8NTestResult> TestCacheInvalidationAsync()
        {
            try
            {
                await _cacheService.InvalidateOrderCacheAsync();
                return new N8NTestResult
                {
                    TestName = "Cache Invalidation Test",
                    Success = true,
                    Message = "Successfully invalidated order cache"
                };
            }
            catch (Exception ex)
            {
                return new N8NTestResult
                {
                    TestName = "Cache Invalidation Test",
                    Success = false,
                    Message = $"Failed to invalidate cache: {ex.Message}"
                };
            }
        }
    }

    public class N8NTestResult
    {
        public string TestName { get; set; } = string.Empty;
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public List<N8NTestResult> TestResults { get; set; } = new();

        public void AddTest(string testName, bool success, string message)
        {
            TestResults.Add(new N8NTestResult
            {
                TestName = testName,
                Success = success,
                Message = message,
                StartTime = DateTime.UtcNow,
                EndTime = DateTime.UtcNow
            });
        }

        public TimeSpan Duration => EndTime - StartTime;
    }
}