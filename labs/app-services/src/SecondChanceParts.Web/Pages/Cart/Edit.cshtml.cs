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

namespace SecondChanceParts.Web.Pages.Cart
{
    public class EditModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public EditModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

        [BindProperty]
        public SecondChanceParts.Web.Models.ShoppingCart ShoppingCart { get; set; }

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            ShoppingCart = await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == id);

            if (ShoppingCart == null)
            {
                return NotFound();
            }
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

            _context.Attach(ShoppingCart).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ShoppingCartExists(ShoppingCart.CartId))
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

        private bool ShoppingCartExists(int id)
        {
            return _context.ShoppingCarts.Any(e => e.CartId == id);
        }
    }
}
