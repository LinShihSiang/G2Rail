# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **DoDoMan Travel BackOffice Management System**, a .NET Core 8 web application for managing travel bookings and orders. The system provides administrative interfaces for order management, customer service, and integration with N8N workflow automation.

## Development Commands

### .NET Core Commands
- `dotnet run` - Run the application in development mode
- `dotnet build` - Build the application
- `dotnet test` - Run all unit tests
- `dotnet test --filter TestClassName` - Run specific test class
- `dotnet watch run` - Run with hot reload for development
- `dotnet publish -c Release -o ./publish` - Publish for production
- `dotnet ef database update` - Apply Entity Framework migrations
- `dotnet ef migrations add MigrationName` - Create new EF migration
- `dotnet clean` - Clean build artifacts
- `dotnet restore` - Restore NuGet packages

### Development Tools
- `dotnet format` - Format code according to .NET conventions
- `dotnet dev-certs https --trust` - Trust development HTTPS certificate

## Architecture

The system follows a layered architecture pattern optimized for administrative interfaces and API integrations:

### Project Structure
```
BackOffice/
├── Controllers/          # MVC Controllers for web interface and API endpoints
│   ├── OrderController.cs       # Order management CRUD operations
│   ├── DashboardController.cs   # Main dashboard and overview
│   └── ApiController.cs         # API endpoints for external integrations
├── Models/              # Data models and ViewModels
│   ├── Order.cs                 # Order entity model
│   ├── Customer.cs              # Customer entity model
│   ├── OrderViewModel.cs        # View models for order display
│   └── FilterModels.cs          # Search and filter models
├── Services/            # Business logic and external integrations
│   ├── OrderService.cs          # Order management business logic
│   ├── N8NIntegrationService.cs # N8N workflow integration
│   └── PaymentService.cs        # Payment processing logic
├── Data/                # Entity Framework context and configurations
│   ├── ApplicationDbContext.cs  # Main EF DbContext
│   └── Migrations/              # EF database migrations
├── Views/               # Razor views for web interface
│   ├── Order/                   # Order management views
│   │   ├── Index.cshtml         # Order listing with filters
│   │   ├── Details.cshtml       # Order detail view
│   │   └── Edit.cshtml          # Order editing interface
│   ├── Dashboard/
│   │   └── Index.cshtml         # Main dashboard
│   └── Shared/                  # Shared layout and components
├── wwwroot/             # Static files (CSS, JS, images)
├── appsettings.json     # Application configuration
└── Program.cs           # Application entry point and configuration
```

## Key Features Implementation

### Order Management System
Based on the UI template provided, the system implements:

#### Filter Interface (頂部篩選區塊)
- **Date Range Filter**: 日期區間 picker for order date filtering
- **Order Number Search**: 訂單編號 text input with search functionality
- **Payment Method Filter**: 支付方式 dropdown (Credit Card, Bank Transfer)
- **Search Button**: 搜尋 button to apply filters

#### Order Listing Table (訂單列表)
- **Order Number**: 訂單編號 - Unique identifier linking to order details
- **Order Date**: 訂單日期 - Creation timestamp formatted for display
- **Customer Name**: 客戶姓名 - Customer contact information
- **Payment Method**: 支付方式 - Credit Card, Bank Transfer, etc.
- **Payment Status**: 支付狀態 - Visual status indicators (paid, pending, failed)
- **Actions**: 操作 - View details, edit, process links

#### Pagination & Navigation
- Page size controls (每頁筆數)
- Page navigation with numbered pages
- Total record count display

## External Integrations

### N8N Workflow Integration
- **Service**: `N8NIntegrationService.cs` handles API communication
- **Endpoints**: Configured in appsettings.json under `N8NSettings`
- **Authentication**: Bearer token or API key authentication
- **Use Cases**: Order status updates, automated customer notifications, payment processing workflows

### Database Configuration
- **Entity Framework Core** with SQL Server/PostgreSQL support
- **Connection String**: Configured in `appsettings.json`
- **Migrations**: Located in `Data/Migrations/` directory

## UI Framework & Styling

### Frontend Stack
- **Bootstrap 5** - CSS framework matching the provided UI template
- **jQuery** - For dynamic filtering and AJAX operations
- **Chart.js** - Dashboard analytics and reporting
- **DateRangePicker** - For date filtering functionality

### Design System
The UI follows the template design with:
- Clean white background with subtle borders
- Green accent color (#28a745) for primary actions
- Status indicators with appropriate color coding
- Responsive table layout with proper spacing
- Professional admin interface styling

## Configuration

### Key Settings (appsettings.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=DoDoManBackOffice;..."
  },
  "N8NSettings": {
    "BaseUrl": "https://n8n.yourinstance.com",
    "ApiKey": "your-api-key"
  },
  "PaymentSettings": {
    "SupportedMethods": ["CreditCard", "BankTransfer"]
  }
}
```

## Security Considerations

- **Authentication**: ASP.NET Core Identity for admin user management
- **Authorization**: Role-based access control for different admin levels
- **API Security**: JWT tokens for N8N integration endpoints
- **Data Protection**: HTTPS enforcement and sensitive data encryption
- **Input Validation**: Model validation attributes and anti-forgery tokens

## Development Environment

- **.NET Core 8.0** - Target framework
- **Entity Framework Core** - ORM for database operations
- **SQL Server/PostgreSQL** - Database options
- **Visual Studio 2022** or **VS Code** - Recommended IDEs
- **Node.js** - For frontend tooling if needed

## Important Implementation Notes

### Order Status Workflow
The system tracks orders through these states:
1. **Pending** - 待處理 - New orders requiring review
2. **Confirmed** - 已確認 - Orders validated and approved
3. **In Progress** - 進行中 - Orders being processed
4. **Completed** - 已完成 - Successfully fulfilled orders
5. **Cancelled** - 已取消 - Cancelled or refunded orders

### N8N Integration Points
- Order status changes trigger N8N workflows
- Payment status updates are synchronized
- Customer notification workflows are automated
- Reporting data is pushed to analytics workflows