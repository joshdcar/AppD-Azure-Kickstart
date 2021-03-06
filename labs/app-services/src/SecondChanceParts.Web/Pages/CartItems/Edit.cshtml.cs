using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Web.Data;
using SecondChanceParts.Web.Models;

namespace SecondChanceParts.Web.Pages.CartItems
{
    public class EditModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public EditModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
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
           ViewData["ShoppingCartId"] = new SelectList(_context.ShoppingCarts, "CartId", "CartId");
           ViewData["PartId"] = new SelectList(_context.Parts, "PartId", "PartId");
            return Page();
        }

        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://aka.ms/RazorPagesCRUD.
        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            _context.Attach(ShoppingCartItem).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ShoppingCartItemExists(ShoppingCartItem.ItemId))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return RedirectToPage("./Index");
        }

        private bool ShoppingCartItemExists(int id)
        {
            return _context.ShoppingCartItems.Any(e => e.ItemId == id);
        }
    }
}
