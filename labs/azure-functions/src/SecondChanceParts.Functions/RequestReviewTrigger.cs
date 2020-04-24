using System.Diagnostics;
using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using MongoDB.Driver;
using System.Threading.Tasks;
using SecondChanceParts.Functions.Models;

namespace SecondChanceParts.Functions
{

    public class OrderProcessingTrigger
    {
        [FunctionName("OrderProcessingTrigger")]
        public async Task Run([ServiceBusTrigger("OrderTopic", "ordersSubscription", Connection = "ServiceBusConnection")]ShoppingCart model, ILogger log)
        {
            await ProcessOrder(model);

            log.LogInformation($"C# ServiceBus topic trigger function processed message: {model.CartId}");
        }

        public async Task<ShoppingCart> ProcessOrder(ShoppingCart model)
        {
            var database = GetDatabaseConnection();

            var ordersCollection = database.GetCollection<ShoppingCart>("orders");

            await ordersCollection.InsertOneAsync(model);

            return model;

        }

         public IMongoDatabase GetDatabaseConnection()
        {
            var connectionString = Environment.GetEnvironmentVariable("CosmosDbConnection");

            MongoClient client = new MongoClient(connectionString);

            IMongoDatabase database = client.GetDatabase("ordersDb");

            return database;

        }

       

        
    }
}
