using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace SecondChanceParts.Web.Pages
{
    public class IndexModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public IndexModel(SecondChanceParts.Web.Data.SecondChancePartsContext context,ILogger<IndexModel> logger)
        {
            _context = context;
            _logger = logger;
        }

        private readonly ILogger<IndexModel> _logger;

        [BindProperty]
        public SecondChanceParts.Web.Models.ShoppingCart ShoppingCart { get; set; }

        public void OnGet()
        {

        }

        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://aka.ms/RazorPagesCRUD.
        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            ShoppingCart.CartStatus = "New";
            ShoppingCart.UserStatus = "Gold";

            _context.ShoppingCarts.Add(ShoppingCart);
            await _context.SaveChangesAsync();

            return RedirectToPage("/Cart/Details",new { id= ShoppingCart.CartId});
        }
    }
}
