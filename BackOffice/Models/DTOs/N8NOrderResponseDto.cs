using System.Text.Json.Serialization;

namespace DoDoManBackOffice.Models.DTOs
{
    public class N8NOrderResponseDto
    {
        [JsonPropertyName("row_number")]
        public int RowNumber { get; set; }

        [JsonPropertyName("訂單編號")]
        public int OrderNumber { get; set; }

        [JsonPropertyName("訂單日期")]
        public string OrderDate { get; set; } = string.Empty;

        [JsonPropertyName("客戶名稱")]
        public string CustomerName { get; set; } = string.Empty;

        [JsonPropertyName("支付方式")]
        public string PaymentMethod { get; set; } = string.Empty;

        [JsonPropertyName("支付狀態")]
        public string PaymentStatus { get; set; } = string.Empty;
    }

    public enum PaymentStatus
    {
        Pending = 0,      // pending
        Success = 1,      // success
        Failed = 2,       // failed
        Refunded = 3,     // refunded
        Cancelled = 4     // cancelled
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