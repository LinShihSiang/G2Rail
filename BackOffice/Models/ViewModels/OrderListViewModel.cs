namespace DoDoManBackOffice.Models.ViewModels
{
    public class OrderListViewModel
    {
        public IEnumerable<OrderViewModel> Orders { get; set; } = new List<OrderViewModel>();
        public FilterViewModel Filter { get; set; } = new();
        public PaginationViewModel Pagination { get; set; } = new();

        // Summary Statistics (calculated from filtered results)
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int SuccessfulOrders { get; set; }
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