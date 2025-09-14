using System.Text.Json.Serialization;

namespace DoDoManBackOffice.Models.DTOs
{
    public class N8NOrderResponseDto
    {
        [JsonPropertyName("row_number")]
        public int RowNumber { get; set; }

        [JsonPropertyName("id")]
        public int OrderNumber { get; set; }

        [JsonPropertyName("date")]
        public string OrderDate { get; set; } = string.Empty;

        [JsonPropertyName("name")]
        public string CustomerName { get; set; } = string.Empty;

        [JsonPropertyName("method")]
        public string PaymentMethod { get; set; } = string.Empty;

        [JsonPropertyName("status")]
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
        Pending = 0,      // Pending
        Confirmed = 1,    // Confirmed
        InProgress = 2,   // In Progress
        Completed = 3,    // Completed
        Cancelled = 4     // Cancelled
    }
}