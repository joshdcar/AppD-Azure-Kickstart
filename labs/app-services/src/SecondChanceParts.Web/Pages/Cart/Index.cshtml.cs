using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Web.Data;
using SecondChanceParts.Web.Models;

namespace SecondChanceParts.Web.Pages.Cart
{
    public class IndexModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;

        public IndexModel(SecondChanceParts.Web.Data.SecondChancePartsContext context)
        {
            _context = context;
        }

        public IList<SecondChanceParts.Web.Models.ShoppingCart> ShoppingCart { get;set; }

        public async Task OnGetAsync()
        {
            ShoppingCart = await _context.ShoppingCarts.ToListAsync();
        }
    }
}
