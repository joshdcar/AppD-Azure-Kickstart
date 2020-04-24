using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using SecondChanceParts.Web.Data;
using SecondChanceParts.Web.Models;

namespace SecondChanceParts.Web.Pages.CartItems
{
    public class CreateModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public CreateModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

        public IActionResult OnGet()
        {
        ViewData["ShoppingCartId"] = new SelectList(_context.ShoppingCarts, "CartId", "CartId");
        ViewData["PartId"] = new SelectList(_context.Parts, "PartId", "PartId");
            return Page();
        }

        [BindProperty]
        public ShoppingCartItem ShoppingCartItem { get; set; }

        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://aka.ms/RazorPagesCRUD.
        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            _context.ShoppingCartItems.Add(ShoppingCartItem);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
