using FluentValidation;
using DoDoManBackOffice.Models.ViewModels;
using DoDoManBackOffice.Models.DTOs;

namespace DoDoManBackOffice.Services.Implementations
{
    public class FilterViewModelValidator : AbstractValidator<FilterViewModel>
    {
        public FilterViewModelValidator()
        {
            RuleFor(x => x.StartDate)
                .LessThanOrEqualTo(x => x.EndDate)
                .When(x => x.StartDate.HasValue && x.EndDate.HasValue)
                .WithMessage("開始日期不能晚於結束日期");

            RuleFor(x => x.EndDate)
                .LessThanOrEqualTo(DateTime.Today)
                .When(x => x.EndDate.HasValue)
                .WithMessage("結束日期不能超過今天");

            RuleFor(x => x.OrderNumber)
                .GreaterThan(0)
                .When(x => x.OrderNumber.HasValue)
                .WithMessage("訂單編號必須大於0");

            RuleFor(x => x.CustomerName)
                .MaximumLength(100)
                .WithMessage("客戶姓名不能超過100個字元");

            RuleFor(x => x.PageSize)
                .GreaterThan(0)
                .LessThanOrEqualTo(100)
                .WithMessage("每頁顯示筆數必須在1-100之間");
        }
    }

    public class N8NOrderResponseValidator : AbstractValidator<N8NOrderResponseDto>
    {
        public N8NOrderResponseValidator()
        {
            RuleFor(x => x.OrderNumber)
                .GreaterThan(0)
                .WithMessage("訂單編號必須大於0");

            RuleFor(x => x.CustomerName)
                .NotEmpty()
                .WithMessage("客戶姓名不能為空")
                .MaximumLength(200)
                .WithMessage("客戶姓名不能超過200個字元");

            RuleFor(x => x.OrderDate)
                .NotEmpty()
                .WithMessage("訂單日期不能為空");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty()
                .WithMessage("支付方式不能為空")
                .Must(BeValidPaymentMethod)
                .WithMessage("不支援的支付方式");

            RuleFor(x => x.PaymentStatus)
                .NotEmpty()
                .WithMessage("支付狀態不能為空")
                .Must(BeValidPaymentStatus)
                .WithMessage("不支援的支付狀態");
        }

        private bool BeValidPaymentMethod(string paymentMethod)
        {
            var validMethods = new[] { "credit card", "bank transfer", "paypal", "line pay" };
            return validMethods.Contains(paymentMethod?.ToLower());
        }

        private bool BeValidPaymentStatus(string paymentStatus)
        {
            var validStatuses = new[] { "pending", "success", "failed", "refunded", "cancelled" };
            return validStatuses.Contains(paymentStatus?.ToLower());
        }
    }
}