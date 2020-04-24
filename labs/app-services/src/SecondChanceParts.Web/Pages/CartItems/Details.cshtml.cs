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
    public class DetailsModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public DetailsModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

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
    }
}
