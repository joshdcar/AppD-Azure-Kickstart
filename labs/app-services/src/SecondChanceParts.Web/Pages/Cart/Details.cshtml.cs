using System.Reflection.Emit;
using System.Collections.Immutable;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Web.Data;
using SecondChanceParts.Web.Models;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Logging;

namespace SecondChanceParts.Web.Pages.Cart
{
    public class DetailsModel : PageModel
    {
        private readonly IHttpClientFactory _clientFactory;
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;
        private readonly IConfiguration _configuration;
        private string _apiUrl;

        private ILogger<PageModel> _logger;

        public DetailsModel(SecondChanceParts.Web.Data.SecondChancePartsContext context, 
                            IConfiguration configuration, 
                            IHttpClientFactory clientFactory,
                            ILogger<PageModel> logger)
        {
            _context = context;
            _configuration = configuration;
            _clientFactory = clientFactory;
            _logger = logger;

            _apiUrl = _configuration["AppSettings:ApiRootUrl"];
        }

        [BindProperty]
        public SecondChanceParts.Web.Models.ShoppingCart ShoppingCart { get; set; }

        [BindProperty]
        public IList<ShoppingCartItem> ShoppingCartItems { get;set; }

        [BindProperty]
        public ShoppingCartItem NewShoppingCartItem {get;set;}

        [BindProperty]
        public IList<Part> Parts { get;set; }

        [BindProperty]
        public IList<SelectListItem> PartsList { get;set; }

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            await LoadData(id.Value);

            if (ShoppingCart == null)
            {
                return NotFound();
            }

            return Page();
        }
    
        public async Task<IActionResult> OnPostAddToCart(){

            //await _context.ShoppingCartItems.AddAsync(NewShoppingCartItem);
            //await _context.SaveChangesAsync();

            await AddToCart(NewShoppingCartItem);

            await LoadData(NewShoppingCartItem.ShoppingCartId);

            return Page();
        }

        public IActionResult OnPostCheckout(){

             return RedirectToPage("./Checkout", new {id=ShoppingCart.CartId});
        }

        private async Task LoadData(int cartId){

            
            NewShoppingCartItem = new ShoppingCartItem() {ShoppingCartId = cartId};

            ShoppingCart = await GetShoppingCart(cartId); //await _context.ShoppingCarts.FirstOrDefaultAsync(m => m.CartId == cartId);

            ShoppingCartItems = await GetShoppingCartItems(cartId); //await _context.ShoppingCartItems.Where(c => c.ShoppingCartId == cartId).ToListAsync();

            Parts = await GetParts();

            PartsList = Parts.Select(a => 
                                  new SelectListItem 
                                  {
                                      Value = a.PartId.ToString(),
                                      Text =  $"{a.Name} (${a.UnitCost})"
                                  }).ToList();

        }

        private async Task<SecondChanceParts.Web.Models.ShoppingCart> GetShoppingCart(int id){

            _logger.LogTrace($"GetShoppingCart: API URL={_apiUrl}");

            var client = _clientFactory.CreateClient();

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var response = await client.GetAsync($"{_apiUrl}/api/carts/{id}");

            if(!response.IsSuccessStatusCode){
                throw new Exception($"Shopping Cart with ID {id} not found.");
            }

            var content = await response.Content.ReadAsStringAsync();
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
            };
            var cart = JsonSerializer.Deserialize<SecondChanceParts.Web.Models.ShoppingCart>(content,options);

            return cart;

        }

        private async Task<List<SecondChanceParts.Web.Models.ShoppingCartItem>> GetShoppingCartItems(int id){

            var client = _clientFactory.CreateClient();

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            var response = await client.GetAsync($"{_apiUrl}/api/carts/{id}/items");

            if(!response.IsSuccessStatusCode){
                throw new Exception($"Shopping Cart with ID {id} not found.");
            }

            var content = await response.Content.ReadAsStringAsync();
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
            };
            var cart = JsonSerializer.Deserialize<List<SecondChanceParts.Web.Models.ShoppingCartItem>>(content,options);

            return cart;

        }

        private async Task<List<SecondChanceParts.Web.Models.Part>> GetParts(){

            var client = _clientFactory.CreateClient();

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var response = await client.GetAsync($"{_apiUrl}/api/parts");

            if(!response.IsSuccessStatusCode){
                throw new Exception($"Parts API not Found");
            }

            var content = await response.Content.ReadAsStringAsync();
            
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
            };
            var parts = JsonSerializer.Deserialize<List<SecondChanceParts.Web.Models.Part>>(content,options);

            return parts;

        }

        private async Task<SecondChanceParts.Web.Models.ShoppingCartItem> AddToCart(ShoppingCartItem item){

            var client = _clientFactory.CreateClient();

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            StringContent content = new StringContent(JsonSerializer.Serialize(item));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            
            var response = await client.PostAsync($"{_apiUrl}/api/carts/{item.ShoppingCartId}/addtocart",content);

            if(!response.IsSuccessStatusCode){
                var errorContent = await response.Content.ReadAsStringAsync();
                throw new Exception($"Error adding to cart: {errorContent}");
            }

            return item;

        }

    }
}
