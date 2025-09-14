namespace DoDoManBackOffice.Configuration
{
    public class AppSettings
    {
        public int PageSize { get; set; } = 20;
        public int MaxPageSize { get; set; } = 100;
        public string DateFormat { get; set; } = "yyyy-MM-dd";
        public string TimeZone { get; set; } = "Asia/Taipei";
    }
}