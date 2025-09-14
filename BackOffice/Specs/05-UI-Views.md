# 05. UI Views and Frontend Implementation

## Overview
實作 DoDoMan 後台管理系統的 Razor Views 和前端介面，依據 UI Template 設計實現訂單管理介面。

## Implementation Steps

### Step 5.1: Shared Layout and Components

**Views/Shared/_Layout.cshtml**
```html
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - DoDoMan 後台管理系統</title>
    <link rel="stylesheet" href="~/lib/bootstrap/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="~/css/site.css" asp-append-version="true" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
            <div class="container-fluid">
                <!-- Logo and Brand -->
                <a class="navbar-brand d-flex align-items-center" asp-area="" asp-controller="Dashboard" asp-action="Index">
                    <span class="fw-bold fs-4" style="color: #007bff;">SRMLOGO</span>
                    <span class="ms-2 small">2.0</span>
                </a>

                <!-- Navigation Menu -->
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target=".navbar-collapse" aria-controls="navbarSupportedContent"
                        aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="navbar-collapse collapse d-sm-inline-flex justify-content-between">
                    <ul class="navbar-nav flex-grow-1">
                        <li class="nav-item">
                            <a class="nav-link text-dark" asp-controller="Dashboard" asp-action="Index">
                                <i class="bi bi-house-door"></i> 儀表板
                            </a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle text-dark" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                                <i class="bi bi-receipt"></i> 訂單管理
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" asp-controller="Order" asp-action="Index">訂單查詢</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" asp-controller="Customer" asp-action="Index">客戶管理</a></li>
                            </ul>
                        </li>
                    </ul>

                    <!-- User Info and Actions -->
                    <ul class="navbar-nav">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <div class="user-avatar me-2">
                                    <i class="bi bi-person-circle fs-5"></i>
                                </div>
                                <div class="user-info">
                                    <div class="user-name small">Project manager</div>
                                </div>
                                <i class="bi bi-chevron-down ms-1"></i>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="#"><i class="bi bi-gear me-2"></i>設定</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form class="d-inline" asp-area="Identity" asp-page="/Account/Logout" asp-route-returnUrl="@Url.Action("Index", "Home", new { area = "" })">
                                        <button type="submit" class="dropdown-item">
                                            <i class="bi bi-box-arrow-right me-2"></i>登出
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <!-- Sidebar Navigation (Optional) -->
    <div class="container-fluid">
        <div class="row">
            <nav id="sidebarMenu" class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link @(ViewContext.RouteData.Values["controller"]?.ToString() == "Dashboard" ? "active" : "")"
                               asp-controller="Dashboard" asp-action="Index">
                                <i class="bi bi-house-door me-2"></i>儀表板
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link @(ViewContext.RouteData.Values["controller"]?.ToString() == "Order" ? "active" : "")"
                               asp-controller="Order" asp-action="Index">
                                <i class="bi bi-receipt me-2"></i>訂單管理
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main Content Area -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <!-- Breadcrumb -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">@ViewData["Title"]</h1>
                </div>

                <!-- Alert Messages -->
                @if (TempData["Success"] != null)
                {
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        @TempData["Success"]
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                }
                @if (TempData["Error"] != null)
                {
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        @TempData["Error"]
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                }
                @if (TempData["Warning"] != null)
                {
                    <div class="alert alert-warning alert-dismissible fade show" role="alert">
                        @TempData["Warning"]
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                }

                <!-- Main Content -->
                @RenderBody()
            </main>
        </div>
    </div>

    <script src="~/lib/jquery/dist/jquery.min.js"></script>
    <script src="~/lib/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
    <script src="~/js/site.js" asp-append-version="true"></script>

    @await RenderSectionAsync("Scripts", required: false)
</body>
</html>
```

**Views/Shared/_FilterPartial.cshtml**
```html
@model DoDoManBackOffice.Models.ViewModels.FilterViewModel

<div class="card mb-4">
    <div class="card-header bg-light">
        <h6 class="card-title mb-0">
            <i class="bi bi-funnel me-2"></i>篩選條件
        </h6>
    </div>
    <div class="card-body">
        <form method="get" asp-action="Index" id="filterForm">
            <div class="row g-3">
                <!-- Date Range -->
                <div class="col-md-4">
                    <label for="dateRange" class="form-label">日期區間</label>
                    <div class="input-group">
                        <input type="text" class="form-control" id="dateRange" name="dateRange"
                               value="@(Model.StartDate?.ToString("yyyy-MM-dd")) - @(Model.EndDate?.ToString("yyyy-MM-dd"))" readonly>
                        <button class="btn btn-outline-secondary" type="button" id="clearDateRange">
                            <i class="bi bi-x"></i>
                        </button>
                    </div>
                    <input type="hidden" asp-for="StartDate" />
                    <input type="hidden" asp-for="EndDate" />
                </div>

                <!-- Order Number -->
                <div class="col-md-3">
                    <label asp-for="OrderNumber" class="form-label">訂單編號</label>
                    <input asp-for="OrderNumber" class="form-control" placeholder="輸入訂單編號..." autocomplete="off">
                </div>

                <!-- Customer Name -->
                <div class="col-md-3">
                    <label asp-for="CustomerName" class="form-label">客戶姓名</label>
                    <input asp-for="CustomerName" class="form-control" placeholder="輸入客戶姓名..." autocomplete="off">
                </div>

                <!-- Payment Method -->
                <div class="col-md-2">
                    <label asp-for="PaymentMethod" class="form-label">支付方式</label>
                    <select asp-for="PaymentMethod" asp-items="Model.PaymentMethodOptions" class="form-select">
                    </select>
                </div>

                <!-- Payment Status -->
                <div class="col-md-2">
                    <label asp-for="PaymentStatus" class="form-label">支付狀態</label>
                    <select asp-for="PaymentStatus" asp-items="Model.PaymentStatusOptions" class="form-select">
                    </select>
                </div>

                <!-- Order Status -->
                <div class="col-md-2">
                    <label asp-for="OrderStatus" class="form-label">訂單狀態</label>
                    <select asp-for="OrderStatus" asp-items="Model.OrderStatusOptions" class="form-select">
                    </select>
                </div>

                <!-- Page Size -->
                <div class="col-md-2">
                    <label asp-for="PageSize" class="form-label">每頁筆數</label>
                    <select asp-for="PageSize" class="form-select">
                        <option value="10" selected="@(Model.PageSize == 10)">10</option>
                        <option value="20" selected="@(Model.PageSize == 20)">20</option>
                        <option value="50" selected="@(Model.PageSize == 50)">50</option>
                        <option value="100" selected="@(Model.PageSize == 100)">100</option>
                    </select>
                </div>

                <!-- Search Buttons -->
                <div class="col-md-6">
                    <label class="form-label">&nbsp;</label>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-success">
                            <i class="bi bi-search me-1"></i>搜尋
                        </button>
                        <a href="@Url.Action("Index")" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-clockwise me-1"></i>重置
                        </a>
                        <button type="button" class="btn btn-outline-primary" onclick="exportOrders()">
                            <i class="bi bi-download me-1"></i>匯出
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
$(document).ready(function() {
    // Initialize date range picker
    $('#dateRange').daterangepicker({
        autoUpdateInput: false,
        locale: {
            cancelLabel: '清除',
            applyLabel: '確定',
            format: 'YYYY-MM-DD',
            daysOfWeek: ['日', '一', '二', '三', '四', '五', '六'],
            monthNames: ['一月', '二月', '三月', '四月', '五月', '六月',
                        '七月', '八月', '九月', '十月', '十一月', '十二月']
        },
        ranges: {
            '今天': [moment(), moment()],
            '昨天': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            '最近7天': [moment().subtract(6, 'days'), moment()],
            '最近30天': [moment().subtract(29, 'days'), moment()],
            '本月': [moment().startOf('month'), moment().endOf('month')],
            '上月': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
    });

    $('#dateRange').on('apply.daterangepicker', function(ev, picker) {
        $(this).val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
        $('input[name="StartDate"]').val(picker.startDate.format('YYYY-MM-DD'));
        $('input[name="EndDate"]').val(picker.endDate.format('YYYY-MM-DD'));
    });

    $('#dateRange').on('cancel.daterangepicker', function(ev, picker) {
        $(this).val('');
        $('input[name="StartDate"]').val('');
        $('input[name="EndDate"]').val('');
    });

    $('#clearDateRange').click(function() {
        $('#dateRange').val('');
        $('input[name="StartDate"]').val('');
        $('input[name="EndDate"]').val('');
    });

    // Order number autocomplete
    $('#OrderNumber').autocomplete({
        source: function(request, response) {
            $.ajax({
                url: '@Url.Action("Search", "Order")',
                type: 'GET',
                data: { term: request.term },
                success: function(data) {
                    response(data);
                }
            });
        },
        minLength: 2
    });
});

function exportOrders() {
    var form = $('#filterForm');
    var actionUrl = form.attr('action');
    form.attr('action', '@Url.Action("Export", "Order")');
    form.attr('target', '_blank');
    form.submit();
    form.attr('action', actionUrl);
    form.removeAttr('target');
}
</script>
```

### Step 5.2: Order Index View

**Views/Order/Index.cshtml**
```html
@model DoDoManBackOffice.Models.ViewModels.OrderListViewModel
@{
    ViewData["Title"] = "訂單管理";
    Layout = "~/Views/Shared/_Layout.cshtml";
}

<!-- Summary Cards -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card text-white bg-primary">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4>@Model.TotalOrders</h4>
                        <p class="card-text">總訂單數</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-receipt fs-2"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-success">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4>@Model.TotalRevenue.ToString("C")</h4>
                        <p class="card-text">總營收</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-currency-dollar fs-2"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-warning">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4>@Model.PendingOrders</h4>
                        <p class="card-text">待處理</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-clock-history fs-2"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-info">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h4>@Model.CompletedOrders</h4>
                        <p class="card-text">已完成</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-check-circle fs-2"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Filter Section -->
<partial name="_FilterPartial" model="@Model.Filter" />

<!-- Orders Table -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="card-title mb-0">訂單列表</h6>
        <div class="text-muted small">
            共 @Model.Pagination.TotalItems 筆資料，第 @Model.Pagination.CurrentPage 頁
        </div>
    </div>
    <div class="card-body p-0">
        @if (Model.Orders.Any())
        {
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>訂單編號</th>
                            <th>訂單日期</th>
                            <th>客戶姓名</th>
                            <th>支付方式</th>
                            <th>支付狀態</th>
                            <th>訂單狀態</th>
                            <th class="text-end">總金額</th>
                            <th width="120">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach (var order in Model.Orders)
                        {
                            <tr>
                                <td>
                                    <a href="@Url.Action("Details", new { id = order.OrderId })"
                                       class="text-decoration-none fw-bold">
                                        @order.OrderNumber
                                    </a>
                                </td>
                                <td>@order.OrderDate.ToString("yyyy-MM-dd HH:mm")</td>
                                <td>
                                    <div>@order.CustomerName</div>
                                    <small class="text-muted">@order.CustomerEmail</small>
                                </td>
                                <td>
                                    <span class="badge bg-light text-dark">
                                        @order.PaymentMethod
                                    </span>
                                </td>
                                <td>
                                    <span class="@order.PaymentStatusCssClass">
                                        @order.PaymentStatusDisplay
                                    </span>
                                </td>
                                <td>
                                    <span class="@order.OrderStatusCssClass">
                                        @order.OrderStatusDisplay
                                    </span>
                                </td>
                                <td class="text-end fw-bold">@order.TotalAmount.ToString("C")</td>
                                <td>
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-outline-secondary dropdown-toggle"
                                                type="button" data-bs-toggle="dropdown">
                                            操作
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <a class="dropdown-item"
                                                   href="@Url.Action("Details", new { id = order.OrderId })">
                                                    <i class="bi bi-eye me-2"></i>查看詳情
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item"
                                                   href="@Url.Action("Edit", new { id = order.OrderId })">
                                                    <i class="bi bi-pencil me-2"></i>編輯
                                                </a>
                                            </li>
                                            @if (order.OrderStatus == DoDoManBackOffice.Models.Entities.OrderStatus.Pending ||
                                                 order.OrderStatus == DoDoManBackOffice.Models.Entities.OrderStatus.Confirmed)
                                            {
                                                <li><hr class="dropdown-divider"></li>
                                                <li>
                                                    <button class="dropdown-item text-danger"
                                                            onclick="cancelOrder(@order.OrderId, '@order.OrderNumber')">
                                                        <i class="bi bi-x-circle me-2"></i>取消訂單
                                                    </button>
                                                </li>
                                            }
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        }
                    </tbody>
                </table>
            </div>
        }
        else
        {
            <div class="text-center py-5">
                <i class="bi bi-inbox display-4 text-muted"></i>
                <p class="text-muted mt-3">沒有找到符合條件的訂單</p>
                <a href="@Url.Action("Index")" class="btn btn-primary">重置篩選條件</a>
            </div>
        }
    </div>
</div>

<!-- Pagination -->
@if (Model.Pagination.TotalPages > 1)
{
    <nav aria-label="Page navigation" class="mt-4">
        <ul class="pagination justify-content-center">
            <!-- Previous Page -->
            <li class="page-item @(!Model.Pagination.HasPreviousPage ? "disabled" : "")">
                <a class="page-link"
                   href="@(Model.Pagination.HasPreviousPage ? Url.Action("Index", new {
                       page = Model.Pagination.CurrentPage - 1,
                       pageSize = Model.Filter.PageSize,
                       startDate = Model.Filter.StartDate?.ToString("yyyy-MM-dd"),
                       endDate = Model.Filter.EndDate?.ToString("yyyy-MM-dd"),
                       orderNumber = Model.Filter.OrderNumber,
                       customerName = Model.Filter.CustomerName,
                       paymentMethod = Model.Filter.PaymentMethod,
                       paymentStatus = Model.Filter.PaymentStatus,
                       orderStatus = Model.Filter.OrderStatus
                   }) : "#")">
                    <i class="bi bi-chevron-left"></i>
                </a>
            </li>

            <!-- Page Numbers -->
            @{
                var startPage = Math.Max(1, Model.Pagination.CurrentPage - 2);
                var endPage = Math.Min(Model.Pagination.TotalPages, Model.Pagination.CurrentPage + 2);
            }

            @if (startPage > 1)
            {
                <li class="page-item">
                    <a class="page-link" href="@Url.Action("Index", new { page = 1 })">1</a>
                </li>
                @if (startPage > 2)
                {
                    <li class="page-item disabled">
                        <span class="page-link">...</span>
                    </li>
                }
            }

            @for (int i = startPage; i <= endPage; i++)
            {
                <li class="page-item @(i == Model.Pagination.CurrentPage ? "active" : "")">
                    <a class="page-link"
                       href="@Url.Action("Index", new {
                           page = i,
                           pageSize = Model.Filter.PageSize,
                           startDate = Model.Filter.StartDate?.ToString("yyyy-MM-dd"),
                           endDate = Model.Filter.EndDate?.ToString("yyyy-MM-dd"),
                           orderNumber = Model.Filter.OrderNumber,
                           customerName = Model.Filter.CustomerName,
                           paymentMethod = Model.Filter.PaymentMethod,
                           paymentStatus = Model.Filter.PaymentStatus,
                           orderStatus = Model.Filter.OrderStatus
                       })">
                        @i
                    </a>
                </li>
            }

            @if (endPage < Model.Pagination.TotalPages)
            {
                @if (endPage < Model.Pagination.TotalPages - 1)
                {
                    <li class="page-item disabled">
                        <span class="page-link">...</span>
                    </li>
                }
                <li class="page-item">
                    <a class="page-link" href="@Url.Action("Index", new { page = Model.Pagination.TotalPages })">
                        @Model.Pagination.TotalPages
                    </a>
                </li>
            }

            <!-- Next Page -->
            <li class="page-item @(!Model.Pagination.HasNextPage ? "disabled" : "")">
                <a class="page-link"
                   href="@(Model.Pagination.HasNextPage ? Url.Action("Index", new {
                       page = Model.Pagination.CurrentPage + 1,
                       pageSize = Model.Filter.PageSize,
                       startDate = Model.Filter.StartDate?.ToString("yyyy-MM-dd"),
                       endDate = Model.Filter.EndDate?.ToString("yyyy-MM-dd"),
                       orderNumber = Model.Filter.OrderNumber,
                       customerName = Model.Filter.CustomerName,
                       paymentMethod = Model.Filter.PaymentMethod,
                       paymentStatus = Model.Filter.PaymentStatus,
                       orderStatus = Model.Filter.OrderStatus
                   }) : "#")">
                    <i class="bi bi-chevron-right"></i>
                </a>
            </li>
        </ul>

        <!-- Pagination Info -->
        <div class="text-center text-muted small mt-2">
            顯示第 @Model.Pagination.StartItem - @Model.Pagination.EndItem 筆，共 @Model.Pagination.TotalItems 筆資料
        </div>
    </nav>
}

<!-- Cancel Order Modal -->
<div class="modal fade" id="cancelOrderModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">取消訂單</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>您確定要取消訂單 <strong id="cancelOrderNumber"></strong> 嗎？</p>
                <div class="mb-3">
                    <label for="cancelReason" class="form-label">取消原因 <span class="text-danger">*</span></label>
                    <textarea id="cancelReason" class="form-control" rows="3" placeholder="請輸入取消原因..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" onclick="confirmCancelOrder()">確定取消</button>
            </div>
        </div>
    </div>
</div>

@section Scripts {
    <script>
        let currentCancelOrderId = 0;

        function cancelOrder(orderId, orderNumber) {
            currentCancelOrderId = orderId;
            $('#cancelOrderNumber').text(orderNumber);
            $('#cancelReason').val('');
            $('#cancelOrderModal').modal('show');
        }

        function confirmCancelOrder() {
            const reason = $('#cancelReason').val().trim();
            if (!reason) {
                alert('請輸入取消原因');
                return;
            }

            $.ajax({
                url: '@Url.Action("Cancel", "Order")',
                type: 'POST',
                data: {
                    orderId: currentCancelOrderId,
                    reason: reason,
                    __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
                },
                success: function(response) {
                    if (response.success) {
                        $('#cancelOrderModal').modal('hide');
                        location.reload();
                    } else {
                        alert(response.message || '取消訂單失敗');
                    }
                },
                error: function() {
                    alert('取消訂單時發生錯誤');
                }
            });
        }

        // Add CSRF token to all AJAX requests
        $.ajaxSetup({
            beforeSend: function(xhr, settings) {
                if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type) && !this.crossDomain) {
                    xhr.setRequestHeader("RequestVerificationToken", $('input[name="__RequestVerificationToken"]').val());
                }
            }
        });
    </script>
}
```

### Step 5.3: Custom CSS Styles

**wwwroot/css/site.css**
```css
/* Custom styles for DoDoMan BackOffice */

:root {
    --primary-color: #28a745;
    --secondary-color: #6c757d;
    --success-color: #28a745;
    --info-color: #17a2b8;
    --warning-color: #ffc107;
    --danger-color: #dc3545;
    --light-color: #f8f9fa;
    --dark-color: #343a40;
}

/* Layout adjustments */
.sidebar {
    position: fixed;
    top: 56px;
    bottom: 0;
    left: 0;
    z-index: 100;
    padding: 48px 0 0;
    box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
}

.sidebar .nav-link {
    color: #333;
    border-radius: 0.25rem;
    margin: 0 0.5rem;
}

.sidebar .nav-link:hover {
    background-color: rgba(0, 0, 0, .075);
}

.sidebar .nav-link.active {
    background-color: var(--primary-color);
    color: white;
}

/* Table enhancements */
.table th {
    border-top: none;
    font-weight: 600;
    color: #495057;
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.table td {
    vertical-align: middle;
    border-color: #e9ecef;
}

.table-hover tbody tr:hover {
    background-color: rgba(0, 0, 0, .025);
}

/* Card enhancements */
.card {
    border: 1px solid rgba(0, 0, 0, 0.075);
    box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.card-header {
    background-color: #f8f9fa;
    border-bottom: 1px solid rgba(0, 0, 0, 0.075);
    font-weight: 600;
}

/* Status badges */
.badge {
    font-size: 0.75rem;
    font-weight: 500;
}

/* Form enhancements */
.form-control:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
}

.form-select:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
}

/* Button enhancements */
.btn-success {
    background-color: var(--primary-color);
    border-color: var(--primary-color);
}

.btn-success:hover {
    background-color: #218838;
    border-color: #1e7e34;
}

/* Dropdown enhancements */
.dropdown-menu {
    border: 1px solid rgba(0, 0, 0, 0.15);
    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.dropdown-item:hover {
    background-color: #f8f9fa;
}

/* User avatar */
.user-avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background-color: #e9ecef;
    display: flex;
    align-items: center;
    justify-content: center;
}

.user-info .user-name {
    font-weight: 500;
    line-height: 1;
}

/* Alert enhancements */
.alert {
    border: none;
    border-radius: 0.5rem;
}

.alert-success {
    background-color: #d4edda;
    color: #155724;
}

.alert-danger {
    background-color: #f8d7da;
    color: #721c24;
}

.alert-warning {
    background-color: #fff3cd;
    color: #856404;
}

/* Pagination */
.pagination .page-link {
    color: var(--primary-color);
    border-color: #dee2e6;
}

.pagination .page-item.active .page-link {
    background-color: var(--primary-color);
    border-color: var(--primary-color);
}

.pagination .page-link:hover {
    color: #1e7e34;
    background-color: #e9ecef;
    border-color: #dee2e6;
}

/* Loading states */
.btn.loading {
    pointer-events: none;
    opacity: 0.6;
}

.btn.loading:after {
    content: "";
    width: 16px;
    height: 16px;
    margin-left: 8px;
    border: 2px solid transparent;
    border-top-color: currentColor;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    display: inline-block;
    vertical-align: middle;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Responsive adjustments */
@media (max-width: 767.98px) {
    .sidebar {
        top: 56px;
        position: static;
        height: auto;
        padding: 0;
    }

    main {
        margin-left: 0 !important;
    }

    .table-responsive {
        font-size: 0.875rem;
    }

    .btn-sm {
        font-size: 0.75rem;
    }
}

/* Date range picker customization */
.daterangepicker {
    font-family: inherit;
}

.daterangepicker .ranges li {
    color: var(--primary-color);
}

.daterangepicker .ranges li:hover {
    background-color: var(--primary-color);
    color: white;
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 3rem 1rem;
    color: #6c757d;
}

.empty-state i {
    font-size: 4rem;
    margin-bottom: 1rem;
    color: #dee2e6;
}

/* Statistics cards */
.stats-card {
    border-left: 4px solid var(--primary-color);
}

.stats-card .card-body {
    padding: 1.5rem;
}

.stats-card h3 {
    font-size: 2rem;
    font-weight: 700;
    color: var(--primary-color);
    margin-bottom: 0.5rem;
}

.stats-card p {
    color: #6c757d;
    margin-bottom: 0;
    font-weight: 500;
}

/* Utility classes */
.text-truncate-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
}

.shadow-sm {
    box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075) !important;
}

.border-start-success {
    border-left: 4px solid var(--success-color) !important;
}

.border-start-primary {
    border-left: 4px solid var(--primary-color) !important;
}

.border-start-warning {
    border-left: 4px solid var(--warning-color) !important;
}

.border-start-info {
    border-left: 4px solid var(--info-color) !important;
}
```

### Step 5.4: Dashboard View

**Views/Dashboard/Index.cshtml**
```html
@model DoDoManBackOffice.Controllers.DashboardViewModel
@{
    ViewData["Title"] = "儀表板";
    Layout = "~/Views/Shared/_Layout.cshtml";
}

<!-- Statistics Overview -->
<div class="row mb-4">
    <div class="col-lg-3 col-md-6 mb-4">
        <div class="card stats-card border-start-primary">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h3>@Model.TodayOrderCount</h3>
                        <p class="mb-0">今日訂單</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-calendar-today fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 mb-4">
        <div class="card stats-card border-start-success">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h3>@Model.TodayRevenue.ToString("C0")</h3>
                        <p class="mb-0">今日營收</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-currency-dollar fs-1 text-success"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 mb-4">
        <div class="card stats-card border-start-warning">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h3>@Model.PendingOrderCount</h3>
                        <p class="mb-0">待處理訂單</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-clock-history fs-1 text-warning"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 mb-4">
        <div class="card stats-card border-start-info">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h3>@Model.MonthOrderCount</h3>
                        <p class="mb-0">本月訂單</p>
                    </div>
                    <div class="align-self-center">
                        <i class="bi bi-graph-up fs-1 text-info"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Charts and Recent Orders -->
<div class="row">
    <!-- Order Status Chart -->
    <div class="col-lg-4 mb-4">
        <div class="card">
            <div class="card-header">
                <h6 class="card-title mb-0">訂單狀態分佈</h6>
            </div>
            <div class="card-body">
                <canvas id="orderStatusChart" width="400" height="400"></canvas>
            </div>
        </div>
    </div>

    <!-- Payment Method Chart -->
    <div class="col-lg-4 mb-4">
        <div class="card">
            <div class="card-header">
                <h6 class="card-title mb-0">支付方式分佈</h6>
            </div>
            <div class="card-body">
                <canvas id="paymentMethodChart" width="400" height="400"></canvas>
            </div>
        </div>
    </div>

    <!-- Recent Orders -->
    <div class="col-lg-4 mb-4">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h6 class="card-title mb-0">最新訂單</h6>
                <a href="@Url.Action("Index", "Order")" class="btn btn-sm btn-outline-primary">
                    查看全部
                </a>
            </div>
            <div class="card-body p-0">
                @if (Model.RecentOrders.Any())
                {
                    <div class="list-group list-group-flush">
                        @foreach (var order in Model.RecentOrders)
                        {
                            <div class="list-group-item">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1">
                                            <a href="@Url.Action("Details", "Order", new { id = order.OrderId })"
                                               class="text-decoration-none">
                                                @order.OrderNumber
                                            </a>
                                        </h6>
                                        <p class="mb-1 small text-muted">@order.CustomerName</p>
                                        <small class="text-muted">@order.OrderDate.ToString("MM-dd HH:mm")</small>
                                    </div>
                                    <div class="text-end">
                                        <span class="@order.OrderStatusCssClass mb-1">
                                            @order.OrderStatusDisplay
                                        </span>
                                        <div class="fw-bold small">@order.TotalAmount.ToString("C")</div>
                                    </div>
                                </div>
                            </div>
                        }
                    </div>
                }
                else
                {
                    <div class="text-center py-4 text-muted">
                        <i class="bi bi-inbox fs-3"></i>
                        <p class="mb-0 mt-2">暫無訂單資料</p>
                    </div>
                }
            </div>
        </div>
    </div>
</div>

@section Scripts {
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // Order Status Pie Chart
        const statusCtx = document.getElementById('orderStatusChart').getContext('2d');
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: [@Html.Raw(string.Join(",", Model.StatusCounts.Select(s => $"'{s.DisplayName}'")))],
                datasets: [{
                    data: [@string.Join(",", Model.StatusCounts.Select(s => s.Count))],
                    backgroundColor: [
                        '#ffc107', // Pending - Warning
                        '#007bff', // Confirmed - Primary
                        '#17a2b8', // InProgress - Info
                        '#28a745', // Completed - Success
                        '#6c757d'  // Cancelled - Secondary
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    }
                }
            }
        });

        // Payment Method Chart
        const paymentCtx = document.getElementById('paymentMethodChart').getContext('2d');
        new Chart(paymentCtx, {
            type: 'bar',
            data: {
                labels: [@Html.Raw(string.Join(",", Model.PaymentMethodSummary.Select(p => $"'{p.PaymentMethod}'")))],
                datasets: [{
                    label: '訂單數量',
                    data: [@string.Join(",", Model.PaymentMethodSummary.Select(p => p.Count))],
                    backgroundColor: '#28a745',
                    borderColor: '#1e7e34',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            precision: 0
                        }
                    }
                }
            }
        });
    </script>
}
```

## Verification Steps
1. Build and run the application: `dotnet run`
2. Navigate to the Order Index page
3. Test filtering functionality
4. Verify responsive design on mobile
5. Test pagination and sorting
6. Check accessibility and browser compatibility
7. Validate form submissions and AJAX calls

## Next Steps
After completing the UI implementation, proceed to:
- 06-N8N-Integration.md for N8N workflow integration
- 07-Testing-Deployment.md for testing and deployment specifications