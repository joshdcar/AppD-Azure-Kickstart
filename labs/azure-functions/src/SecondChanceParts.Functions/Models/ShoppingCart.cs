using System;
using System.Collections.Generic;


namespace SecondChanceParts.Functions.Models
{
    public class ShoppingCart
    {
        public int CartId{get;set;}
        public String Username {get;set;}
        public String UserStatus{get;set;}
        public String CartStatus {get;set;}
        public List<ShoppingCartItem> Items{get;set;}
    }
}