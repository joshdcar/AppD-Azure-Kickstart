using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SecondChanceParts.Web.Models
{
    public class Part
    {
        [Key()]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int PartId {get;set;}
        public String Name {get;set;}
        public Decimal UnitCost {get;set;}

        [NotMapped]
        public int Units{get;set;}
    }
}