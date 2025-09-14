using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;
using DoDoManBackOffice.Models.DTOs;

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
        public int? OrderNumber { get; set; }

        [Display(Name = "客戶姓名")]
        [StringLength(100)]
        public string? CustomerName { get; set; }

        [Display(Name = "支付方式")]
        public string? PaymentMethod { get; set; }

        [Display(Name = "支付狀態")]
        public string? PaymentStatus { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;

        // For dropdowns
        public List<SelectListItem> PaymentMethodOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "credit card", Text = "信用卡" },
            new SelectListItem { Value = "bank transfer", Text = "銀行轉帳" },
            new SelectListItem { Value = "paypal", Text = "PayPal" },
            new SelectListItem { Value = "line pay", Text = "Line Pay" }
        };

        public List<SelectListItem> PaymentStatusOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "全部" },
            new SelectListItem { Value = "pending", Text = "待付款" },
            new SelectListItem { Value = "success", Text = "已付款" },
            new SelectListItem { Value = "failed", Text = "付款失敗" },
            new SelectListItem { Value = "refunded", Text = "已退款" },
            new SelectListItem { Value = "cancelled", Text = "已取消" }
        };
    }
}