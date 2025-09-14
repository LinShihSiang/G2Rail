using System.ComponentModel.DataAnnotations;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderViewModel
    {
        [Display(Name = "Order Number")]
        public int OrderNumber { get; set; }

        [Display(Name = "Order Date")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime OrderDate { get; set; }

        [Display(Name = "Customer Name")]
        public string CustomerName { get; set; } = string.Empty;

        [Display(Name = "Payment Method")]
        public string PaymentMethod { get; set; } = string.Empty;

        [Display(Name = "Payment Status")]
        public string PaymentStatusRaw { get; set; } = string.Empty;

        public PaymentStatus PaymentStatus => ParsePaymentStatus(PaymentStatusRaw);

        public string PaymentStatusDisplay => GetPaymentStatusDisplay();
        public string PaymentStatusCssClass => GetPaymentStatusCssClass();

        private PaymentStatus ParsePaymentStatus(string status)
        {
            return status?.ToLower() switch
            {
                "success" => PaymentStatus.Success,
                "pending" => PaymentStatus.Pending,
                "failed" => PaymentStatus.Failed,
                "refunded" => PaymentStatus.Refunded,
                "cancelled" => PaymentStatus.Cancelled,
                _ => PaymentStatus.Pending
            };
        }

        private string GetPaymentStatusDisplay()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "Pending",
                PaymentStatus.Success => "Paid",
                PaymentStatus.Failed => "Failed",
                PaymentStatus.Refunded => "Refunded",
                PaymentStatus.Cancelled => "Cancelled",
                _ => "Unknown"
            };
        }

        private string GetPaymentStatusCssClass()
        {
            return PaymentStatus switch
            {
                PaymentStatus.Pending => "badge bg-warning",
                PaymentStatus.Success => "badge bg-success",
                PaymentStatus.Failed => "badge bg-danger",
                PaymentStatus.Refunded => "badge bg-info",
                PaymentStatus.Cancelled => "badge bg-secondary",
                _ => "badge bg-light"
            };
        }

        public static OrderViewModel FromN8NDto(N8NOrderResponseDto dto)
        {
            return new OrderViewModel
            {
                OrderNumber = dto.OrderNumber,
                OrderDate = DateTime.TryParse(dto.OrderDate, out var orderDate) ? orderDate : DateTime.MinValue,
                CustomerName = dto.CustomerName,
                PaymentMethod = FormatPaymentMethod(dto.PaymentMethod),
                PaymentStatusRaw = dto.PaymentStatus
            };
        }

        private static string FormatPaymentMethod(string method)
        {
            return method?.ToLower() switch
            {
                "credit card" => "Credit Card",
                "bank transfer" => "Bank Transfer",
                _ => method ?? ""
            };
        }
    }
}