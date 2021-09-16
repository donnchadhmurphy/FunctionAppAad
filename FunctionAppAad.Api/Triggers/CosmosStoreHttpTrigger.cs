using FunctionAppAad.Api.Interfaces;
using FunctionAppAad.Api.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.IO;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Triggers
{
    public class CosmosHttpTrigger
    {
        private readonly ICosmosService _cosmosService;

        public CosmosHttpTrigger(ICosmosService cosmosService)
        {
            _cosmosService = cosmosService;
        }


        [FunctionName(nameof(CosmosHttpTrigger))]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var fruit = JsonConvert.DeserializeObject<Fruit>(requestBody);
            fruit.Id = Guid.NewGuid().ToString();
            var response = await _cosmosService.StoreFruit(fruit);

            return new OkObjectResult(response);
        }
    }
}
