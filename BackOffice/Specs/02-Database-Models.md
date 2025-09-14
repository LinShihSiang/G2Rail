# 02. Database Models and Entity Framework

## Overview
定義 DoDoMan 後台管理系統的資料庫結構、實體模型和 Entity Framework 配置。

## Implementation Steps

### Step 2.1: Entity Models

**Models/Entities/Order.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoDoManBackOffice.Models.Entities
{
    public class Order
    {
        [Key]
        public int OrderId { get; set; }

        [Required]
        public int OrderNumber { get; set; } // N8N API returns integer order number (訂單編號)

        [Required]
        public DateTime OrderDate { get; set; }

        [Required]
        public int CustomerId { get; set; }

        [ForeignKey("CustomerId")]
        public virtual Customer Customer { get; set; } = null!;

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        [Required]
        [StringLength(50)]
        public string PaymentMethod { get; set; } = string.Empty; // CreditCard, BankTransfer

        [Required]
        public PaymentStatus PaymentStatus { get; set; }

        [Required]
        public OrderStatus OrderStatus { get; set; }

        [StringLength(1000)]
        public string? Notes { get; set; }

        [StringLength(500)]
        public string? PaymentReference { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        [StringLength(100)]
        public string CreatedBy { get; set; } = string.Empty;

        [StringLength(100)]
        public string? UpdatedBy { get; set; }

        // Navigation Properties
        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
        public virtual ICollection<OrderStatusHistory> StatusHistory { get; set; } = new List<OrderStatusHistory>();
    }

    public enum PaymentStatus
    {
        Pending = 0,      // 待付款
        Paid = 1,         // 已付款
        Failed = 2,       // 付款失敗
        Refunded = 3,     // 已退款
        Cancelled = 4     // 已取消
    }

    public enum OrderStatus
    {
        Pending = 0,      // 待處理
        Confirmed = 1,    // 已確認
        InProgress = 2,   // 進行中
        Completed = 3,    // 已完成
        Cancelled = 4     // 已取消
    }
}
```

**Models/Entities/Customer.cs**
```csharp
using System.ComponentModel.DataAnnotations;

namespace DoDoManBackOffice.Models.Entities
{
    public class Customer
    {
        [Key]
        public int CustomerId { get; set; }

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        [NotMapped]
        public string FullName => $"{FirstName} {LastName}";

        [Required]
        [EmailAddress]
        [StringLength(200)]
        public string Email { get; set; } = string.Empty;

        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        [StringLength(500)]
        public string? Address { get; set; }

        [StringLength(100)]
        public string? City { get; set; }

        [StringLength(50)]
        public string? Country { get; set; }

        [StringLength(20)]
        public string? PostalCode { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        public bool IsActive { get; set; } = true;

        // Navigation Properties
        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}
```

**Models/Entities/OrderItem.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoDoManBackOffice.Models.Entities
{
    public class OrderItem
    {
        [Key]
        public int OrderItemId { get; set; }

        [Required]
        public int OrderId { get; set; }

        [ForeignKey("OrderId")]
        public virtual Order Order { get; set; } = null!;

        [Required]
        [StringLength(200)]
        public string ProductName { get; set; } = string.Empty;

        [StringLength(50)]
        public string? ProductType { get; set; } // Tour, Package, Service

        [Required]
        public int Quantity { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal UnitPrice { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalPrice { get; set; }

        [StringLength(1000)]
        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
```

**Models/Entities/OrderStatusHistory.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoDoManBackOffice.Models.Entities
{
    public class OrderStatusHistory
    {
        [Key]
        public int HistoryId { get; set; }

        [Required]
        public int OrderId { get; set; }

        [ForeignKey("OrderId")]
        public virtual Order Order { get; set; } = null!;

        [Required]
        public OrderStatus FromStatus { get; set; }

        [Required]
        public OrderStatus ToStatus { get; set; }

        [Required]
        public DateTime ChangedAt { get; set; }

        [Required]
        [StringLength(100)]
        public string ChangedBy { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Reason { get; set; }

        [StringLength(1000)]
        public string? Notes { get; set; }
    }
}
```

### Step 2.2: View Models

**Models/ViewModels/OrderViewModel.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderViewModel
    {
        public int OrderId { get; set; }

        [Display(Name = "訂單編號")]
        public int OrderNumber { get; set; } // N8N API returns integer order number

        [Display(Name = "訂單日期")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime OrderDate { get; set; }

        [Display(Name = "客戶姓名")]
        public string CustomerName { get; set; } = string.Empty; // Maps to N8N API field "客戶名稱"

        [Display(Name = "客戶Email")]
        public string CustomerEmail { get; set; } = string.Empty;

        [Display(Name = "支付方式")]
        public string PaymentMethod { get; set; } = string.Empty;

        [Display(Name = "支付狀態")]
        public PaymentStatus PaymentStatus { get; set; }

        [Display(Name = "訂單狀態")]
        public OrderStatus OrderStatus { get; set; }

        [Display(Name = "總金額")]
        [DisplayFormat(DataFormatString = "{0:C}")]
        public decimal TotalAmount { get; set; }

        [Display(Name = "備註")]
        public string? Notes { get; set; }

        public string PaymentStatusDisplay => GetPaymentStatusDisplay();
        public string OrderStatusDisplay => GetOrderStatusDisplay();
        public string PaymentStatusCssClass => GetPaymentStatusCssClass();
        public string OrderStatusCssClass => GetOrderStatusCssClass();

        private string GetPaymentStatusDisplay()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "待付款",
                PaymentStatus.Paid => "已付款",
                PaymentStatus.Failed => "付款失敗",
                PaymentStatus.Refunded => "已退款",
                PaymentStatus.Cancelled => "已取消",
                _ => "未知"
            };
        }

        private string GetOrderStatusDisplay()
        {
            return OrderStatus switch
            {
                OrderStatus.Pending => "待處理",
                OrderStatus.Confirmed => "已確認",
                OrderStatus.InProgress => "進行中",
                OrderStatus.Completed => "已完成",
                OrderStatus.Cancelled => "已取消",
                _ => "未知"
            };
        }

        private string GetPaymentStatusCssClass()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "badge bg-warning",
                PaymentStatus.Paid => "badge bg-success",
                PaymentStatus.Failed => "badge bg-danger",
                PaymentStatus.Refunded => "badge bg-info",
                PaymentStatus.Cancelled => "badge bg-secondary",
                _ => "badge bg-light"
            };
        }

        private string GetOrderStatusCssClass()
        {
            return OrderStatus switch
            {
                OrderStatus.Pending => "badge bg-warning",
                OrderStatus.Confirmed => "badge bg-primary",
                OrderStatus.InProgress => "badge bg-info",
                OrderStatus.Completed => "badge bg-success",
                OrderStatus.Cancelled => "badge bg-secondary",
                _ => "badge bg-light"
            };
        }
    }
}
```

**Models/ViewModels/OrderListViewModel.cs**
```csharp
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderListViewModel
    {
        public IEnumerable<OrderViewModel> Orders { get; set; } = new List<OrderViewModel>();
        public FilterViewModel Filter { get; set; } = new();
        public PaginationViewModel Pagination { get; set; } = new();

        // Summary Statistics
        public int TotalOrders { get; set; }
        public decimal TotalRevenue { get; set; }
        public int PendingOrders { get; set; }
        public int CompletedOrders { get; set; }
    }

    public class PaginationViewModel
    {
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 20;
        public int TotalItems { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);

        public bool HasPreviousPage => CurrentPage > 1;
        public bool HasNextPage => CurrentPage < TotalPages;

        public int StartItem => (CurrentPage - 1) * PageSize + 1;
        public int EndItem => Math.Min(CurrentPage * PageSize, TotalItems);
    }
}
```

**Models/ViewModels/FilterViewModel.cs**
```csharp
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class FilterViewModel
    {
        [Display(Name = "開始日期")]
        [DataType(DataType.Date)]
        public DateTime? StartDate { get; set; }

        [Display(Name = "結束日期")]
        [DataType(DataType.Date)]
        public DateTime? EndDate { get; set; }

        [Display(Name = "訂單編號")]
        public int? OrderNumber { get; set; } // N8N API uses integer order numbers

        [Display(Name = "客戶姓名")]
        [StringLength(100)]
        public string? CustomerName { get; set; }

        [Display(Name = "支付方式")]
        public string? PaymentMethod { get; set; }

        [Display(Name = "支付狀態")]
        public PaymentStatus? PaymentStatus { get; set; }

        [Display(Name = "訂單狀態")]
        public OrderStatus? OrderStatus { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;

        // For dropdowns
        public List<SelectListItem> PaymentMethodOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "CreditCard", Text = "信用卡" },
            new SelectListItem { Value = "BankTransfer", Text = "銀行轉帳" },
            new SelectListItem { Value = "PayPal", Text = "PayPal" },
            new SelectListItem { Value = "LinePay", Text = "Line Pay" }
        };

        public List<SelectListItem> PaymentStatusOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "0", Text = "待付款" },
            new SelectListItem { Value = "1", Text = "已付款" },
            new SelectListItem { Value = "2", Text = "付款失敗" },
            new SelectListItem { Value = "3", Text = "已退款" },
            new SelectListItem { Value = "4", Text = "已取消" }
        };

        public List<SelectListItem> OrderStatusOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "0", Text = "待處理" },
            new SelectListItem { Value = "1", Text = "已確認" },
            new SelectListItem { Value = "2", Text = "進行中" },
            new SelectListItem { Value = "3", Text = "已完成" },
            new SelectListItem { Value = "4", Text = "已取消" }
        };
    }
}
```

### Step 2.3: Database Context

**Data/ApplicationDbContext.cs**
```csharp
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Order> Orders { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<OrderStatusHistory> OrderStatusHistories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Apply configurations
            modelBuilder.ApplyConfiguration(new OrderConfiguration());
            modelBuilder.ApplyConfiguration(new CustomerConfiguration());
            modelBuilder.ApplyConfiguration(new OrderItemConfiguration());
            modelBuilder.ApplyConfiguration(new OrderStatusHistoryConfiguration());

            // Seed data
            SeedData(modelBuilder);
        }

        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed Customers
            modelBuilder.Entity<Customer>().HasData(
                new Customer
                {
                    CustomerId = 1,
                    FirstName = "張",
                    LastName = "小明",
                    Email = "zhang.xiaoming@example.com",
                    PhoneNumber = "0912345678",
                    Address = "台北市信義區信義路五段7號",
                    City = "台北市",
                    Country = "台灣",
                    PostalCode = "110",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                },
                new Customer
                {
                    CustomerId = 2,
                    FirstName = "李",
                    LastName = "美麗",
                    Email = "li.meili@example.com",
                    PhoneNumber = "0987654321",
                    Address = "台中市西屯區台灣大道三段99號",
                    City = "台中市",
                    Country = "台灣",
                    PostalCode = "407",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                }
            );

            // Seed Orders
            modelBuilder.Entity<Order>().HasData(
                new Order
                {
                    OrderId = 1,
                    OrderNumber = 1, // N8N API format: integer order number
                    OrderDate = DateTime.UtcNow.AddDays(-7),
                    CustomerId = 1,
                    TotalAmount = 25000.00m,
                    PaymentMethod = "credit card", // N8N API format: lowercase
                    PaymentStatus = PaymentStatus.Paid,
                    OrderStatus = OrderStatus.Completed,
                    CreatedAt = DateTime.UtcNow.AddDays(-7),
                    UpdatedAt = DateTime.UtcNow.AddDays(-1),
                    CreatedBy = "System"
                },
                new Order
                {
                    OrderId = 2,
                    OrderNumber = 2, // N8N API format: integer order number
                    OrderDate = DateTime.UtcNow.AddDays(-3),
                    CustomerId = 2,
                    TotalAmount = 18500.00m,
                    PaymentMethod = "bank transfer", // N8N API format: lowercase
                    PaymentStatus = PaymentStatus.Pending,
                    OrderStatus = OrderStatus.Confirmed,
                    CreatedAt = DateTime.UtcNow.AddDays(-3),
                    UpdatedAt = DateTime.UtcNow.AddDays(-3),
                    CreatedBy = "System"
                }
            );
        }
    }
}
```

### Step 2.4: Entity Configurations

**Data/Configurations/OrderConfiguration.cs**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Data.Configurations
{
    public class OrderConfiguration : IEntityTypeConfiguration<Order>
    {
        public void Configure(EntityTypeBuilder<Order> builder)
        {
            // Table name
            builder.ToTable("Orders");

            // Primary key
            builder.HasKey(o => o.OrderId);

            // Properties
            builder.Property(o => o.OrderNumber)
                .IsRequired()
                .HasComment("訂單編號 (integer format from N8N API)");

            builder.Property(o => o.TotalAmount)
                .HasColumnType("decimal(18,2)")
                .HasComment("總金額");

            builder.Property(o => o.PaymentMethod)
                .IsRequired()
                .HasMaxLength(50)
                .HasComment("支付方式");

            builder.Property(o => o.Notes)
                .HasMaxLength(1000)
                .HasComment("備註");

            builder.Property(o => o.CreatedAt)
                .HasDefaultValueSql("GETUTCDATE()")
                .HasComment("建立時間");

            builder.Property(o => o.UpdatedAt)
                .HasDefaultValueSql("GETUTCDATE()")
                .HasComment("更新時間");

            // Indexes
            builder.HasIndex(o => o.OrderNumber)
                .IsUnique()
                .HasDatabaseName("IX_Orders_OrderNumber");

            builder.Property(o => o.OrderNumber)
                .HasComment("訂單編號 (integer format from N8N API)");

            builder.HasIndex(o => o.OrderDate)
                .HasDatabaseName("IX_Orders_OrderDate");

            builder.HasIndex(o => o.PaymentStatus)
                .HasDatabaseName("IX_Orders_PaymentStatus");

            builder.HasIndex(o => o.OrderStatus)
                .HasDatabaseName("IX_Orders_OrderStatus");

            // Relationships
            builder.HasOne(o => o.Customer)
                .WithMany(c => c.Orders)
                .HasForeignKey(o => o.CustomerId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(o => o.OrderItems)
                .WithOne(oi => oi.Order)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(o => o.StatusHistory)
                .WithOne(h => h.Order)
                .HasForeignKey(h => h.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
```

### Step 2.5: Create Database Migration
```bash
# Add initial migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Verify migration
dotnet ef migrations list
```

### Step 2.6: Data Transfer Objects (DTOs)

**Models/DTOs/OrderDto.cs**
```csharp
using DoDoManBackOffice.Models.Entities;

namespace DoDoManBackOffice.Models.DTOs
{
    public class OrderDto
    {
        public int OrderId { get; set; }
        public int OrderNumber { get; set; } // N8N API returns integer order number
        public DateTime OrderDate { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerEmail { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public PaymentStatus PaymentStatus { get; set; }
        public OrderStatus OrderStatus { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<OrderItemDto> OrderItems { get; set; } = new();
    }

    public class OrderItemDto
    {
        public int OrderItemId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string? ProductType { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
        public string? Description { get; set; }
    }
}
```

## Verification Steps
1. Run `dotnet ef migrations add InitialCreate`
2. Run `dotnet ef database update`
3. Verify tables are created in database
4. Check seed data is inserted
5. Test entity relationships work correctly

## Next Steps
After completing the database setup, proceed to:
- 03-Service-Layer.md for business logic implementation
- 04-Controllers-API.md for API and controller development