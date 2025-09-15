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
                .WithMessage("Start date cannot be later than end date");

            RuleFor(x => x.EndDate)
                .LessThanOrEqualTo(DateTime.Today)
                .When(x => x.EndDate.HasValue)
                .WithMessage("End date cannot be later than today");

            RuleFor(x => x.OrderNumber)
                .NotEmpty()
                .When(x => !string.IsNullOrEmpty(x.OrderNumber))
                .WithMessage("Order number cannot be empty");

            RuleFor(x => x.CustomerName)
                .MaximumLength(100)
                .WithMessage("Customer name cannot exceed 100 characters");

            RuleFor(x => x.PageSize)
                .GreaterThan(0)
                .LessThanOrEqualTo(100)
                .WithMessage("Page size must be between 1-100");
        }
    }

    public class N8NOrderResponseValidator : AbstractValidator<N8NOrderResponseDto>
    {
        public N8NOrderResponseValidator()
        {
            RuleFor(x => x.OrderNumber)
                .NotEmpty()
                .WithMessage("Order number cannot be empty");

            RuleFor(x => x.CustomerName)
                .NotEmpty()
                .WithMessage("Customer name cannot be empty")
                .MaximumLength(200)
                .WithMessage("Customer name cannot exceed 200 characters");

            RuleFor(x => x.OrderDate)
                .NotEmpty()
                .WithMessage("Order date cannot be empty");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty()
                .WithMessage("Payment method cannot be empty")
                .Must(BeValidPaymentMethod)
                .WithMessage("Unsupported payment method");

            RuleFor(x => x.PaymentStatus)
                .NotEmpty()
                .WithMessage("Payment status cannot be empty")
                .Must(BeValidPaymentStatus)
                .WithMessage("Unsupported payment status");
        }

        private bool BeValidPaymentMethod(string paymentMethod)
        {
            var validMethods = new[] { "credit card", "bank transfer" };
            return validMethods.Contains(paymentMethod?.ToLower());
        }

        private bool BeValidPaymentStatus(string paymentStatus)
        {
            var validStatuses = new[] { "pending", "success", "failed", "refunded", "cancelled" };
            return validStatuses.Contains(paymentStatus?.ToLower());
        }
    }
}