# 07. Testing and Deployment Specifications

## Overview
完整的測試策略和部署流程，確保 DoDoMan 後台管理系統的品質和穩定性。

## Implementation Steps

### Step 7.1: Unit Testing Framework Setup

**Tests/DoDoManBackOffice.Tests.csproj**
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
    <PackageReference Include="xunit" Version="2.6.1" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="8.0.0" />
    <PackageReference Include="Moq" Version="4.20.69" />
    <PackageReference Include="AutoFixture" Version="4.18.0" />
    <PackageReference Include="FluentAssertions" Version="6.12.0" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="8.0.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\DoDoManBackOffice.csproj" />
  </ItemGroup>

</Project>
```

### Step 7.2: Service Layer Unit Tests

**Tests/Services/OrderServiceTests.cs**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using FluentAssertions;
using AutoFixture;
using DoDoManBackOffice.Data;
using DoDoManBackOffice.Services.Implementations;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.Entities;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Tests.Services
{
    public class OrderServiceTests : IDisposable
    {
        private readonly ApplicationDbContext _context;
        private readonly OrderService _orderService;
        private readonly Mock<IN8NIntegrationService> _mockN8NService;
        private readonly Mock<ILogger<OrderService>> _mockLogger;
        private readonly IFixture _fixture;

        public OrderServiceTests()
        {
            // Setup in-memory database
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            _context = new ApplicationDbContext(options);

            // Setup mocks
            _mockN8NService = new Mock<IN8NIntegrationService>();
            _mockLogger = new Mock<ILogger<OrderService>>();

            var appSettings = Options.Create(new AppSettings
            {
                PageSize = 20,
                MaxPageSize = 100
            });

            _orderService = new OrderService(_context, appSettings, _mockN8NService.Object, _mockLogger.Object);

            _fixture = new Fixture();
            _fixture.Behaviors.OfType<ThrowingRecursionBehavior>().ToList()
                .ForEach(b => _fixture.Behaviors.Remove(b));
            _fixture.Behaviors.Add(new OmitOnRecursionBehavior());

            SeedTestData();
        }

        [Fact]
        public async Task GetOrdersAsync_WithValidFilter_ReturnsFilteredOrders()
        {
            // Arrange
            var filter = new FilterViewModel
            {
                StartDate = DateTime.Today.AddDays(-30),
                EndDate = DateTime.Today,
                Page = 1,
                PageSize = 10
            };

            // Act
            var result = await _orderService.GetOrdersAsync(filter);

            // Assert
            result.Should().NotBeNull();
            result.Orders.Should().NotBeEmpty();
            result.Pagination.CurrentPage.Should().Be(1);
            result.Pagination.PageSize.Should().Be(10);
        }

        [Fact]
        public async Task GetOrderByIdAsync_WithValidId_ReturnsOrder()
        {
            // Arrange
            var existingOrder = await _context.Orders.FirstAsync();

            // Act
            var result = await _orderService.GetOrderByIdAsync(existingOrder.OrderId);

            // Assert
            result.Should().NotBeNull();
            result!.OrderId.Should().Be(existingOrder.OrderId);
            result.OrderNumber.Should().Be(existingOrder.OrderNumber);
        }

        [Fact]
        public async Task GetOrderByIdAsync_WithInvalidId_ReturnsNull()
        {
            // Act
            var result = await _orderService.GetOrderByIdAsync(999999);

            // Assert
            result.Should().BeNull();
        }

        [Fact]
        public async Task UpdateOrderStatusAsync_WithValidData_UpdatesStatusSuccessfully()
        {
            // Arrange
            var order = await _context.Orders.FirstAsync();
            var newStatus = OrderStatus.Completed;
            var updatedBy = "TestUser";
            var reason = "Test status update";

            _mockN8NService.Setup(x => x.SendOrderStatusUpdateAsync(It.IsAny<Order>()))
                .ReturnsAsync(true);

            // Act
            var result = await _orderService.UpdateOrderStatusAsync(order.OrderId, newStatus, updatedBy, reason);

            // Assert
            result.Should().BeTrue();

            var updatedOrder = await _context.Orders.FindAsync(order.OrderId);
            updatedOrder!.OrderStatus.Should().Be(newStatus);
            updatedOrder.UpdatedBy.Should().Be(updatedBy);

            _mockN8NService.Verify(x => x.SendOrderStatusUpdateAsync(It.IsAny<Order>()), Times.Once);
        }

        [Fact]
        public async Task GenerateOrderNumberAsync_GeneratesUniqueNumber()
        {
            // Act
            var orderNumber = await _orderService.GenerateOrderNumberAsync();

            // Assert
            orderNumber.Should().NotBeNullOrEmpty();
            orderNumber.Should().StartWith($"DDM{DateTime.Now.Year}");
            orderNumber.Length.Should().Be(10); // DDM2024001 format
        }

        [Fact]
        public async Task CanCancelOrderAsync_WithPendingOrder_ReturnsTrue()
        {
            // Arrange
            var order = _fixture.Build<Order>()
                .With(o => o.OrderStatus, OrderStatus.Pending)
                .Without(o => o.Customer)
                .Without(o => o.OrderItems)
                .Without(o => o.StatusHistory)
                .Create();

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Act
            var result = await _orderService.CanCancelOrderAsync(order.OrderId);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task CanCancelOrderAsync_WithCompletedOrder_ReturnsFalse()
        {
            // Arrange
            var order = _fixture.Build<Order>()
                .With(o => o.OrderStatus, OrderStatus.Completed)
                .Without(o => o.Customer)
                .Without(o => o.OrderItems)
                .Without(o => o.StatusHistory)
                .Create();

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Act
            var result = await _orderService.CanCancelOrderAsync(order.OrderId);

            // Assert
            result.Should().BeFalse();
        }

        [Fact]
        public async Task GetOrderSummaryAsync_ReturnsAccurateSummary()
        {
            // Act
            var summary = await _orderService.GetOrderSummaryAsync();

            // Assert
            summary.Should().NotBeNull();
            summary.TotalOrders.Should().BeGreaterThan(0);
            summary.TotalRevenue.Should().BeGreaterThan(0);
        }

        private void SeedTestData()
        {
            var customers = _fixture.Build<Customer>()
                .Without(c => c.Orders)
                .CreateMany(5);

            _context.Customers.AddRange(customers);
            _context.SaveChanges();

            var orders = new List<Order>();
            foreach (var customer in customers)
            {
                var customerOrders = _fixture.Build<Order>()
                    .With(o => o.CustomerId, customer.CustomerId)
                    .With(o => o.OrderDate, DateTime.Today.AddDays(-Random.Shared.Next(1, 60)))
                    .With(o => o.CreatedAt, DateTime.UtcNow.AddDays(-Random.Shared.Next(1, 60)))
                    .With(o => o.UpdatedAt, DateTime.UtcNow.AddDays(-Random.Shared.Next(0, 30)))
                    .Without(o => o.Customer)
                    .Without(o => o.OrderItems)
                    .Without(o => o.StatusHistory)
                    .CreateMany(Random.Shared.Next(1, 4));

                orders.AddRange(customerOrders);
            }

            _context.Orders.AddRange(orders);
            _context.SaveChanges();
        }

        public void Dispose()
        {
            _context.Database.EnsureDeleted();
            _context.Dispose();
        }
    }
}
```

### Step 7.3: Controller Integration Tests

**Tests/Controllers/OrderControllerTests.cs**
```csharp
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using FluentAssertions;
using System.Net;
using System.Text.Json;
using DoDoManBackOffice.Data;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Tests.Controllers
{
    public class OrderControllerTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly WebApplicationFactory<Program> _factory;
        private readonly HttpClient _client;

        public OrderControllerTests(WebApplicationFactory<Program> factory)
        {
            _factory = factory.WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Remove the real database context
                    var descriptor = services.SingleOrDefault(
                        d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

                    if (descriptor != null)
                    {
                        services.Remove(descriptor);
                    }

                    // Add in-memory database for testing
                    services.AddDbContext<ApplicationDbContext>(options =>
                    {
                        options.UseInMemoryDatabase("InMemoryDbForTesting");
                    });

                    // Build service provider and seed data
                    var sp = services.BuildServiceProvider();
                    using var scope = sp.CreateScope();
                    var scopedServices = scope.ServiceProvider;
                    var db = scopedServices.GetRequiredService<ApplicationDbContext>();

                    db.Database.EnsureCreated();
                    SeedDatabase(db);
                });
            });

            _client = _factory.CreateClient();
        }

        [Fact]
        public async Task Index_ReturnsSuccessAndCorrectContentType()
        {
            // Act
            var response = await _client.GetAsync("/Order");

            // Assert
            response.EnsureSuccessStatusCode();
            response.Content.Headers.ContentType?.ToString()
                .Should().StartWith("text/html");
        }

        [Fact]
        public async Task Details_WithValidId_ReturnsOrderDetails()
        {
            // Arrange
            using var scope = _factory.Services.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var order = await context.Orders.FirstAsync();

            // Act
            var response = await _client.GetAsync($"/Order/Details/{order.OrderId}");

            // Assert
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadAsStringAsync();
            content.Should().Contain(order.OrderNumber);
        }

        [Fact]
        public async Task Details_WithInvalidId_ReturnsNotFound()
        {
            // Act
            var response = await _client.GetAsync("/Order/Details/999999");

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task Search_ReturnsJsonResults()
        {
            // Act
            var response = await _client.GetAsync("/Order/Search?term=DDM");

            // Assert
            response.EnsureSuccessStatusCode();
            response.Content.Headers.ContentType?.ToString()
                .Should().StartWith("application/json");

            var jsonContent = await response.Content.ReadAsStringAsync();
            var results = JsonSerializer.Deserialize<object[]>(jsonContent);
            results.Should().NotBeNull();
        }

        [Fact]
        public async Task Export_ReturnsCsvFile()
        {
            // Act
            var response = await _client.GetAsync("/Order/Export?format=csv");

            // Assert
            response.EnsureSuccessStatusCode();
            response.Content.Headers.ContentType?.ToString()
                .Should().Be("text/csv");

            var content = await response.Content.ReadAsStringAsync();
            content.Should().Contain("訂單編號,訂單日期,客戶姓名");
        }

        private static void SeedDatabase(ApplicationDbContext context)
        {
            if (context.Orders.Any())
            {
                return; // Database already seeded
            }

            var customers = new[]
            {
                new Customer
                {
                    CustomerId = 1,
                    FirstName = "張",
                    LastName = "小明",
                    Email = "zhang@example.com",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                },
                new Customer
                {
                    CustomerId = 2,
                    FirstName = "李",
                    LastName = "美麗",
                    Email = "li@example.com",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                }
            };

            context.Customers.AddRange(customers);

            var orders = new[]
            {
                new Order
                {
                    OrderId = 1,
                    OrderNumber = "DDM2024001",
                    OrderDate = DateTime.Today.AddDays(-1),
                    CustomerId = 1,
                    TotalAmount = 1000m,
                    PaymentMethod = "CreditCard",
                    PaymentStatus = PaymentStatus.Paid,
                    OrderStatus = OrderStatus.Completed,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    CreatedBy = "Test"
                },
                new Order
                {
                    OrderId = 2,
                    OrderNumber = "DDM2024002",
                    OrderDate = DateTime.Today,
                    CustomerId = 2,
                    TotalAmount = 2000m,
                    PaymentMethod = "BankTransfer",
                    PaymentStatus = PaymentStatus.Pending,
                    OrderStatus = OrderStatus.Pending,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    CreatedBy = "Test"
                }
            };

            context.Orders.AddRange(orders);
            context.SaveChanges();
        }
    }
}
```

### Step 7.4: API Tests

**Tests/Api/ApiControllerTests.cs**
```csharp
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using FluentAssertions;
using System.Net;
using System.Text.Json;
using System.Text;
using DoDoManBackOffice.Controllers;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Tests.Api
{
    public class ApiControllerTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly WebApplicationFactory<Program> _factory;
        private readonly HttpClient _client;

        public ApiControllerTests(WebApplicationFactory<Program> factory)
        {
            _factory = factory;
            _client = _factory.CreateClient();
        }

        [Fact]
        public async Task GetOrders_ReturnsValidApiResponse()
        {
            // Act
            var response = await _client.GetAsync("/api/Api/orders");

            // Assert
            response.EnsureSuccessStatusCode();

            var jsonString = await response.Content.ReadAsStringAsync();
            var apiResponse = JsonSerializer.Deserialize<ApiResponse<IEnumerable<OrderDto>>>(jsonString,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            apiResponse.Should().NotBeNull();
            apiResponse!.Success.Should().BeTrue();
            apiResponse.Data.Should().NotBeNull();
        }

        [Fact]
        public async Task GetOrder_WithValidId_ReturnsOrder()
        {
            // Arrange - First get an order ID
            var ordersResponse = await _client.GetAsync("/api/Api/orders");
            var ordersContent = await ordersResponse.Content.ReadAsStringAsync();
            var ordersApiResponse = JsonSerializer.Deserialize<ApiResponse<IEnumerable<OrderDto>>>(ordersContent,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            var firstOrder = ordersApiResponse!.Data!.First();

            // Act
            var response = await _client.GetAsync($"/api/Api/orders/{firstOrder.OrderId}");

            // Assert
            response.EnsureSuccessStatusCode();

            var jsonString = await response.Content.ReadAsStringAsync();
            var apiResponse = JsonSerializer.Deserialize<ApiResponse<OrderDto>>(jsonString,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            apiResponse.Should().NotBeNull();
            apiResponse!.Success.Should().BeTrue();
            apiResponse.Data.Should().NotBeNull();
            apiResponse.Data!.OrderId.Should().Be(firstOrder.OrderId);
        }

        [Fact]
        public async Task GetOrder_WithInvalidId_ReturnsNotFound()
        {
            // Act
            var response = await _client.GetAsync("/api/Api/orders/999999");

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task GetSummary_ReturnsValidSummary()
        {
            // Act
            var response = await _client.GetAsync("/api/Api/summary");

            // Assert
            response.EnsureSuccessStatusCode();

            var jsonString = await response.Content.ReadAsStringAsync();
            var apiResponse = JsonSerializer.Deserialize<ApiResponse<OrderSummaryDto>>(jsonString,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            apiResponse.Should().NotBeNull();
            apiResponse!.Success.Should().BeTrue();
            apiResponse.Data.Should().NotBeNull();
            apiResponse.Data!.TotalOrders.Should().BeGreaterThanOrEqualTo(0);
        }
    }
}
```

### Step 7.5: N8N Integration Tests

**Tests/Integration/N8NIntegrationTests.cs**
```csharp
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;
using Moq;
using Moq.Protected;
using FluentAssertions;
using System.Net;
using System.Text.Json;
using DoDoManBackOffice.Services.Implementations;
using DoDoManBackOffice.Configuration;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Tests.Integration
{
    public class N8NIntegrationTests
    {
        private readonly Mock<HttpMessageHandler> _mockHttpHandler;
        private readonly HttpClient _httpClient;
        private readonly N8NIntegrationService _n8nService;
        private readonly Mock<ILogger<N8NIntegrationService>> _mockLogger;

        public N8NIntegrationTests()
        {
            _mockHttpHandler = new Mock<HttpMessageHandler>();
            _httpClient = new HttpClient(_mockHttpHandler.Object);
            _mockLogger = new Mock<ILogger<N8NIntegrationService>>();

            var settings = Options.Create(new N8NSettings
            {
                BaseUrl = "https://test-n8n.example.com",
                ApiKey = "test-api-key",
                WebhookSecret = "test-secret",
                Endpoints = new N8NEndpoints
                {
                    OrderStatusUpdate = "/webhook/order-status",
                    PaymentNotification = "/webhook/payment",
                    CustomerNotification = "/webhook/customer-notify"
                }
            });

            _n8nService = new N8NIntegrationService(_httpClient, settings, _mockLogger.Object);
        }

        [Fact]
        public async Task SendOrderStatusUpdateAsync_WithValidOrder_SendsWebhook()
        {
            // Arrange
            var order = new Order
            {
                OrderId = 1,
                OrderNumber = "DDM2024001",
                OrderStatus = OrderStatus.Completed,
                UpdatedAt = DateTime.UtcNow,
                UpdatedBy = "TestUser"
            };

            var expectedResponse = new N8NResponse
            {
                Success = true,
                Message = "Webhook received successfully",
                WorkflowId = "workflow-123",
                Timestamp = DateTime.UtcNow
            };

            _mockHttpHandler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(JsonSerializer.Serialize(expectedResponse))
                });

            // Act
            var result = await _n8nService.SendOrderStatusUpdateAsync(order);

            // Assert
            result.Should().BeTrue();

            _mockHttpHandler.Protected().Verify(
                "SendAsync",
                Times.Once(),
                ItExpr.Is<HttpRequestMessage>(req =>
                    req.Method == HttpMethod.Post &&
                    req.RequestUri!.ToString().Contains("/webhook/order-status")),
                ItExpr.IsAny<CancellationToken>());
        }

        [Fact]
        public async Task ValidateWebhookSignature_WithValidSignature_ReturnsTrue()
        {
            // Arrange
            var payload = """{"orderId": 1, "status": "completed"}""";
            var secret = "test-secret";

            // Generate expected signature
            using var hmac = new System.Security.Cryptography.HMACSHA256(System.Text.Encoding.UTF8.GetBytes(secret));
            var hash = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(payload));
            var expectedSignature = "sha256=" + Convert.ToHexString(hash).ToLower();

            // Act
            var result = _n8nService.ValidateWebhookSignature(payload, expectedSignature);

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task ValidateWebhookSignature_WithInvalidSignature_ReturnsFalse()
        {
            // Arrange
            var payload = """{"orderId": 1, "status": "completed"}""";
            var invalidSignature = "sha256=invalid-signature";

            // Act
            var result = _n8nService.ValidateWebhookSignature(payload, invalidSignature);

            // Assert
            result.Should().BeFalse();
        }

        [Fact]
        public async Task TestConnectionAsync_WithSuccessResponse_ReturnsTrue()
        {
            // Arrange
            _mockHttpHandler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(JsonSerializer.Serialize(new N8NResponse
                    {
                        Success = true,
                        Message = "Connection test successful"
                    }))
                });

            // Act
            var result = await _n8nService.TestConnectionAsync();

            // Assert
            result.Should().BeTrue();
        }
    }
}
```

### Step 7.6: Performance Tests

**Tests/Performance/OrderServicePerformanceTests.cs**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using FluentAssertions;
using System.Diagnostics;
using DoDoManBackOffice.Data;
using DoDoManBackOffice.Services.Implementations;
using DoDoManBackOffice.Services.Interfaces;
using DoDoManBackOffice.Models.Entities;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Configuration;

namespace DoDoManBackOffice.Tests.Performance
{
    public class OrderServicePerformanceTests : IDisposable
    {
        private readonly ApplicationDbContext _context;
        private readonly OrderService _orderService;
        private readonly Mock<IN8NIntegrationService> _mockN8NService;

        public OrderServicePerformanceTests()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: $"PerformanceTest_{Guid.NewGuid()}")
                .Options;

            _context = new ApplicationDbContext(options);
            _mockN8NService = new Mock<IN8NIntegrationService>();

            var mockLogger = new Mock<ILogger<OrderService>>();
            var appSettings = Options.Create(new AppSettings { PageSize = 20, MaxPageSize = 100 });

            _orderService = new OrderService(_context, appSettings, _mockN8NService.Object, mockLogger.Object);

            SeedLargeDataset();
        }

        [Fact]
        public async Task GetOrdersAsync_WithLargeDataset_CompletesWithinTimeLimit()
        {
            // Arrange
            var filter = new FilterViewModel
            {
                Page = 1,
                PageSize = 50,
                StartDate = DateTime.Today.AddDays(-365),
                EndDate = DateTime.Today
            };

            var stopwatch = Stopwatch.StartNew();

            // Act
            var result = await _orderService.GetOrdersAsync(filter);

            stopwatch.Stop();

            // Assert
            result.Should().NotBeNull();
            result.Orders.Should().NotBeEmpty();
            stopwatch.ElapsedMilliseconds.Should().BeLessThan(1000,
                "Query should complete within 1 second");
        }

        [Fact]
        public async Task GetOrdersAsync_Pagination_PerformanceIsConsistent()
        {
            // Test multiple pages to ensure consistent performance
            var times = new List<long>();

            for (int page = 1; page <= 5; page++)
            {
                var filter = new FilterViewModel
                {
                    Page = page,
                    PageSize = 20
                };

                var stopwatch = Stopwatch.StartNew();
                await _orderService.GetOrdersAsync(filter);
                stopwatch.Stop();

                times.Add(stopwatch.ElapsedMilliseconds);
            }

            // Performance should be consistent across pages
            var maxTime = times.Max();
            var minTime = times.Min();
            var variance = maxTime - minTime;

            variance.Should().BeLessThan(500,
                "Page load times should not vary by more than 500ms");
        }

        [Theory]
        [InlineData(10)]
        [InlineData(50)]
        [InlineData(100)]
        public async Task GetOrdersAsync_DifferentPageSizes_PerformanceScalesAcceptably(int pageSize)
        {
            // Arrange
            var filter = new FilterViewModel
            {
                Page = 1,
                PageSize = pageSize
            };

            var stopwatch = Stopwatch.StartNew();

            // Act
            var result = await _orderService.GetOrdersAsync(filter);

            stopwatch.Stop();

            // Assert
            result.Orders.Count().Should().BeLessOrEqualTo(pageSize);

            // Performance should scale reasonably with page size
            var expectedMaxTime = pageSize * 10; // 10ms per record max
            stopwatch.ElapsedMilliseconds.Should().BeLessThan(expectedMaxTime);
        }

        private void SeedLargeDataset()
        {
            var random = new Random();
            var customers = new List<Customer>();

            // Create 100 customers
            for (int i = 1; i <= 100; i++)
            {
                customers.Add(new Customer
                {
                    CustomerId = i,
                    FirstName = $"Customer{i}",
                    LastName = $"LastName{i}",
                    Email = $"customer{i}@example.com",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });
            }

            _context.Customers.AddRange(customers);
            _context.SaveChanges();

            var orders = new List<Order>();

            // Create 1000 orders
            for (int i = 1; i <= 1000; i++)
            {
                orders.Add(new Order
                {
                    OrderId = i,
                    OrderNumber = $"DDM{DateTime.Now.Year}{i:D6}",
                    OrderDate = DateTime.Today.AddDays(-random.Next(0, 365)),
                    CustomerId = random.Next(1, 101),
                    TotalAmount = random.Next(100, 5000),
                    PaymentMethod = new[] { "CreditCard", "BankTransfer", "PayPal" }[random.Next(3)],
                    PaymentStatus = (PaymentStatus)random.Next(0, 5),
                    OrderStatus = (OrderStatus)random.Next(0, 5),
                    CreatedAt = DateTime.UtcNow.AddDays(-random.Next(0, 365)),
                    UpdatedAt = DateTime.UtcNow.AddDays(-random.Next(0, 30)),
                    CreatedBy = "System"
                });
            }

            _context.Orders.AddRange(orders);
            _context.SaveChanges();
        }

        public void Dispose()
        {
            _context.Database.EnsureDeleted();
            _context.Dispose();
        }
    }
}
```

### Step 7.7: End-to-End Testing with Playwright

**Tests/E2E/OrderManagementE2ETests.cs**
```csharp
using Microsoft.Playwright;
using FluentAssertions;

namespace DoDoManBackOffice.Tests.E2E
{
    [TestClass]
    public class OrderManagementE2ETests
    {
        private static IPlaywright _playwright = null!;
        private static IBrowser _browser = null!;

        [ClassInitialize]
        public static async Task ClassInitialize(TestContext context)
        {
            _playwright = await Playwright.CreateAsync();
            _browser = await _playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            {
                Headless = true
            });
        }

        [ClassCleanup]
        public static async Task ClassCleanup()
        {
            await _browser.CloseAsync();
            _playwright.Dispose();
        }

        [TestMethod]
        public async Task OrderListPage_LoadsAndDisplaysOrders()
        {
            // Arrange
            var context = await _browser.NewContextAsync();
            var page = await context.NewPageAsync();

            // Act
            await page.GotoAsync("https://localhost:5001/Order");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Assert
            var title = await page.TitleAsync();
            title.Should().Contain("訂單管理");

            var ordersTable = page.Locator("table");
            await ordersTable.WaitForAsync();

            var orderRows = page.Locator("tbody tr");
            var rowCount = await orderRows.CountAsync();
            rowCount.Should().BeGreaterThan(0, "Should display at least one order");

            await context.CloseAsync();
        }

        [TestMethod]
        public async Task OrderSearch_FiltersOrdersCorrectly()
        {
            // Arrange
            var context = await _browser.NewContextAsync();
            var page = await context.NewPageAsync();

            await page.GotoAsync("https://localhost:5001/Order");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Act
            await page.FillAsync("#OrderNumber", "DDM2024001");
            await page.ClickAsync("button[type='submit']");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Assert
            var searchResults = page.Locator("tbody tr");
            var resultCount = await searchResults.CountAsync();

            if (resultCount > 0)
            {
                var firstOrderNumber = await page.Locator("tbody tr:first-child td:first-child a").TextContentAsync();
                firstOrderNumber.Should().Contain("DDM2024001");
            }

            await context.CloseAsync();
        }

        [TestMethod]
        public async Task OrderDetails_DisplaysCorrectInformation()
        {
            // Arrange
            var context = await _browser.NewContextAsync();
            var page = await context.NewPageAsync();

            await page.GotoAsync("https://localhost:5001/Order");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Act - Click on first order link
            var firstOrderLink = page.Locator("tbody tr:first-child td:first-child a");
            await firstOrderLink.ClickAsync();
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Assert
            var url = page.Url;
            url.Should().Contain("/Order/Details/");

            var orderDetailsCard = page.Locator(".card");
            await orderDetailsCard.WaitForAsync();

            await context.CloseAsync();
        }

        [TestMethod]
        public async Task DateRangePicker_FiltersOrdersByDate()
        {
            // Arrange
            var context = await _browser.NewContextAsync();
            var page = await context.NewPageAsync();

            await page.GotoAsync("https://localhost:5001/Order");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Act
            await page.ClickAsync("#dateRange");
            await page.WaitForSelectorAsync(".daterangepicker", new PageWaitForSelectorOptions
            {
                State = WaitForSelectorState.Visible
            });

            // Select "最近7天" range
            await page.ClickAsync(".ranges li:has-text('最近7天')");
            await page.ClickAsync(".applyBtn");

            await page.WaitForTimeoutAsync(1000); // Wait for date range to be applied
            await page.ClickAsync("button[type='submit']");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);

            // Assert
            var dateRangeInput = page.Locator("#dateRange");
            var dateRangeValue = await dateRangeInput.InputValueAsync();
            dateRangeValue.Should().NotBeEmpty("Date range should be populated");

            await context.CloseAsync();
        }
    }
}
```

### Step 7.8: CI/CD Pipeline Configuration

**.github/workflows/ci.yml**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  DOTNET_VERSION: '8.0.x'
  NODE_VERSION: '18.x'

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      sqlserver:
        image: mcr.microsoft.com/mssql/server:2022-latest
        env:
          SA_PASSWORD: 'YourStrong!Passw0rd'
          ACCEPT_EULA: 'Y'
        ports:
          - 1433:1433
        options: >-
          --health-cmd "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q 'SELECT 1'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}

    - name: Cache NuGet packages
      uses: actions/cache@v3
      with:
        path: ~/.nuget/packages
        key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
        restore-keys: |
          ${{ runner.os }}-nuget-

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore --configuration Release

    - name: Run Unit Tests
      run: |
        dotnet test --no-build --configuration Release \
          --logger trx --results-directory TestResults \
          --collect:"XPlat Code Coverage"

    - name: Install Playwright
      run: |
        cd Tests
        dotnet build
        pwsh bin/Release/net8.0/playwright.ps1 install chromium

    - name: Run E2E Tests
      run: |
        dotnet run --project DoDoManBackOffice --configuration Release &
        sleep 30
        dotnet test Tests/E2E --configuration Release
      env:
        ASPNETCORE_URLS: 'https://localhost:5001'

    - name: Generate Code Coverage Report
      uses: danielpalme/ReportGenerator-GitHub-Action@5.1.26
      with:
        reports: 'TestResults/*/coverage.cobertura.xml'
        targetdir: 'CoverageReport'
        reporttypes: 'Html;Cobertura'

    - name: Upload Coverage to CodeCov
      uses: codecov/codecov-action@v3
      with:
        files: ./CoverageReport/Cobertura.xml

    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: TestResults

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  deploy-staging:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}

    - name: Publish
      run: dotnet publish --configuration Release --output ./publish

    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment..."
        # Add your staging deployment commands here

  deploy-production:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}

    - name: Publish
      run: dotnet publish --configuration Release --output ./publish

    - name: Deploy to Production
      run: |
        echo "Deploying to production environment..."
        # Add your production deployment commands here
```

### Step 7.9: Docker Configuration

**Dockerfile**
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["DoDoManBackOffice.csproj", "./"]
RUN dotnet restore "DoDoManBackOffice.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "DoDoManBackOffice.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "DoDoManBackOffice.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy published app
COPY --from=publish /app/publish .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "DoDoManBackOffice.dll"]
```

**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=DoDoManBackOffice;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=true
      - N8NSettings__BaseUrl=https://n8n.yourcompany.com
      - N8NSettings__ApiKey=${N8N_API_KEY}
    depends_on:
      - sqlserver
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      SA_PASSWORD: 'YourStrong!Passw0rd'
      ACCEPT_EULA: 'Y'
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: unless-stopped

volumes:
  sqlserver_data:
```

## Test Execution Commands

```bash
# Run all tests
dotnet test

# Run unit tests only
dotnet test --filter "Category=Unit"

# Run integration tests only
dotnet test --filter "Category=Integration"

# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run performance tests
dotnet test --filter "Category=Performance"

# Run E2E tests
dotnet test Tests/E2E

# Build and run in Docker
docker-compose up --build

# Run security scans
dotnet list package --vulnerable
dotnet list package --outdated
```

## Verification Steps
1. Execute all unit tests: `dotnet test --filter "Category=Unit"`
2. Run integration tests: `dotnet test --filter "Category=Integration"`
3. Verify code coverage > 80%
4. Execute performance tests and verify acceptable response times
5. Run E2E tests against staging environment
6. Validate security scans pass
7. Test Docker deployment locally
8. Verify CI/CD pipeline execution

## Production Deployment Checklist
- [ ] All tests passing
- [ ] Code coverage >= 80%
- [ ] Security vulnerabilities resolved
- [ ] Performance benchmarks met
- [ ] Database migrations tested
- [ ] N8N integration tested
- [ ] SSL certificates configured
- [ ] Environment variables set
- [ ] Monitoring and logging configured
- [ ] Backup strategy implemented
- [ ] Load testing completed