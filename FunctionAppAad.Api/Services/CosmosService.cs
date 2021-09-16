using Azure.Identity;
using FunctionAppAad.Api.Interfaces;
using FunctionAppAad.Api.Models;
using Microsoft.Azure.Cosmos;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Services
{
    public class CosmosService : ICosmosService
    {
        private readonly CosmosClient _client;
        private readonly Container _container;

        public CosmosService(string endpoint)
        {
            _client = new CosmosClient(endpoint, new DefaultAzureCredential());
            _container = _client.GetContainer("FruitDB", "FruitStore");
        }

        public async Task<Fruit> StoreFruit(Fruit fruit)
        {
            var response = await _container.CreateItemAsync(fruit);

            return response.Resource;
        }

        public async Task<IEnumerable<Fruit>> GetFruitByColor(string color)
        {
            string query = "SELECT * FROM c WHERE (c.color = @Color)";
            QueryDefinition queryDefinition = new QueryDefinition(query).WithParameter("@Color", color);
            IEnumerable<Fruit> fruits = await GetItemsAsync(queryDefinition);

            return fruits;
        }

        private async Task<IEnumerable<Fruit>> GetItemsAsync(QueryDefinition queryDefinition)
        {
            FeedIterator<Fruit> resultSetIterator = _container.GetItemQueryIterator<Fruit>(queryDefinition);
            List<Fruit> results = new List<Fruit>();

            while (resultSetIterator.HasMoreResults)
            {
                FeedResponse<Fruit> response = await resultSetIterator.ReadNextAsync();
                results.AddRange(response.ToList());
            }

            return results;
        }
    }
}
