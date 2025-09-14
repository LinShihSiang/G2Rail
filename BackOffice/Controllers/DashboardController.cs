using Microsoft.AspNetCore.Mvc;

namespace DoDoManBackOffice.Controllers
{
    public class DashboardController : Controller
    {
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(ILogger<DashboardController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            // Dashboard implementation will be added in Step 04
            ViewData["Title"] = "儀表板";
            return View();
        }
    }
}