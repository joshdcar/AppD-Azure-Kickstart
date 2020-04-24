using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace SecondChanceParts.Api.Models
{
    public class ShoppingCartItem
    {
        [Key()]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ItemId {get;set;}

      
        public int ShoppingCartId {get;set;}
        public int PartId {get;set;}
        public int ItemCount{get;set;}

        [ForeignKey("PartId")]
        public Part Part {get;set;}

        [JsonIgnore]
        [ForeignKey("ShoppingCartId")]
        public ShoppingCart Cart {get;set;}
    }
}