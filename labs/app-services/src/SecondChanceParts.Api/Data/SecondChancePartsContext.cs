using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Api.Models;

namespace SecondChanceParts.Api.Data
{
    public class SecondChancePartsContext : DbContext
    {
        public SecondChancePartsContext (
            DbContextOptions<SecondChancePartsContext> options)
            : base(options)
        {
        }

        public DbSet<Part> Parts { get; set; }
        public DbSet<ShoppingCart> ShoppingCarts { get; set; }
        public DbSet<ShoppingCartItem> ShoppingCartItems { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            modelBuilder.Entity<Part>().HasData(new Part {PartId=1, Name="NTK - OE Type Oxygen Sensor", UnitCost=39});
            modelBuilder.Entity<Part>().HasData(new Part {PartId=2, Name="Valeo - Clutch Kig", UnitCost=249});
            modelBuilder.Entity<Part>().HasData(new Part {PartId=3, Name="Denso - Oxygen Sensor 1 Wire", UnitCost=20});
            modelBuilder.Entity<Part>().HasData(new Part {PartId=4, Name="Flux Capacitor", UnitCost=1955});
            modelBuilder.Entity<Part>().HasData(new Part {PartId=5, Name="121 Gigawatts Power Source", UnitCost=18000000});

            base.OnModelCreating(modelBuilder);
        }
    }
}