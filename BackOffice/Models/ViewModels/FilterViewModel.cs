using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class FilterViewModel
    {
        [Display(Name = "Start Date")]
        [DataType(DataType.Date)]
        public DateTime? StartDate { get; set; }

        [Display(Name = "End Date")]
        [DataType(DataType.Date)]
        public DateTime? EndDate { get; set; }

        [Display(Name = "Order Number")]
        public int? OrderNumber { get; set; }

        [Display(Name = "Customer Name")]
        [StringLength(100)]
        public string? CustomerName { get; set; }

        [Display(Name = "Payment Method")]
        public string? PaymentMethod { get; set; }

        [Display(Name = "Payment Status")]
        public string? PaymentStatus { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;

        // For dropdowns
        public List<SelectListItem> PaymentMethodOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "All" },
            new SelectListItem { Value = "credit card", Text = "Credit Card" },
            new SelectListItem { Value = "bank transfer", Text = "Bank Transfer" }
        };

        public List<SelectListItem> PaymentStatusOptions { get; set; } = new()
        {
            new SelectListItem { Value = "", Text = "All" },
            new SelectListItem { Value = "pending", Text = "Pending" },
            new SelectListItem { Value = "success", Text = "Paid" },
            new SelectListItem { Value = "failed", Text = "Failed" },
            new SelectListItem { Value = "refunded", Text = "Refunded" },
            new SelectListItem { Value = "cancelled", Text = "Cancelled" }
        };
    }
}