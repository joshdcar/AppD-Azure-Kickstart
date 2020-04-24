using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Web.Data;
using SecondChanceParts.Web.Models;

namespace SecondChanceParts.Web.Pages.CartItems
{
    public class DeleteModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public DeleteModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

        [BindProperty]
        public ShoppingCartItem ShoppingCartItem { get; set; }

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            ShoppingCartItem = await _context.ShoppingCartItems
                .Include(s => s.Cart)
                .Include(s => s.Part).FirstOrDefaultAsync(m => m.ItemId == id);

            if (ShoppingCartItem == null)
            {
                return NotFound();
            }
            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            ShoppingCartItem = await _context.ShoppingCartItems.FindAsync(id);

            if (ShoppingCartItem != null)
            {
                var cartId = ShoppingCartItem.ShoppingCartId;

                _context.ShoppingCartItems.Remove(ShoppingCartItem);
                await _context.SaveChangesAsync();

                return RedirectToPage($"/Cart/Details", new { id=cartId});
            }

            return RedirectToPage("./Index");
        }
    }
}
