using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SecondChanceParts.Api.Models
{
    public class ShoppingCart
    {
        [Key()]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int CartId{get;set;}
        public String Username {get;set;}
        public String UserStatus{get;set;}
        public String CartStatus {get;set;}
        public List<ShoppingCartItem> Items{get;set;}
    }
}