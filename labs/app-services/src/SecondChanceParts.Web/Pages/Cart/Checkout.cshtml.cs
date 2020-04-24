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
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;

namespace SecondChanceParts.Web.Pages.Cart
{
    public class CheckoutModel : PageModel
    {
        private readonly SecondChanceParts.Web.Data.SecondChancePartsContext _context;
        private readonly IConfiguration _configuration;
        private string _apiUrl;

        private static readonly HttpClient _httpClient = new HttpClient();

        public CheckoutModel(SecondChanceParts.Web.Data.SecondChancePartsContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;

            _apiUrl = _configuration["AppSettings:ApiRootUrl"];
        }

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var cart = await GetShoppingCart(id.Value);
            await Checkout(cart);
            
            return Page();
        }

        [BindProperty]
        public SecondChanceParts.Web.Models.ShoppingCart ShoppingCart { get; set; }

        private async Task<SecondChanceParts.Web.Models.ShoppingCart> GetShoppingCart(int id){

            _httpClient.DefaultRequestHeaders.Accept.Clear();
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            var response = await _httpClient.GetAsync($"{_apiUrl}/api/carts/{id}");

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
        private async Task<SecondChanceParts.Web.Models.ShoppingCart> Checkout(SecondChanceParts.Web.Models.ShoppingCart cart){

            _httpClient.DefaultRequestHeaders.Accept.Clear();
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            StringContent content = new StringContent(JsonSerializer.Serialize(cart));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            
            var response = await _httpClient.PostAsync($"{_apiUrl}/api/carts/{cart.CartId}/checkout",content);

            if(!response.IsSuccessStatusCode){
                var errorContent = await response.Content.ReadAsStringAsync();
                throw new Exception($"Error checking out cart: {errorContent}");
            }

            return cart;

        }


    }
}
