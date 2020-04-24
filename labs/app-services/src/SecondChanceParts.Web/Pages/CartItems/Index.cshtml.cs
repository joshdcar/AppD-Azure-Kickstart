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
    public class IndexModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public IndexModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

        public IList<ShoppingCartItem> ShoppingCartItem { get;set; }

        public async Task OnGetAsync()
        {
            ShoppingCartItem = await _context.ShoppingCartItems
                .Include(s => s.Cart)
                .Include(s => s.Part).ToListAsync();
        }
    }
}
