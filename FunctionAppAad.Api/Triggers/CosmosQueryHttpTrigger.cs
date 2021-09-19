using FunctionAppAad.Api.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.IO;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Triggers
{
    public class CosmosQueryHttpTrigger
    {
        private readonly ICosmosService _cosmosService;

        public CosmosQueryHttpTrigger(ICosmosService cosmosService)
        {
            _cosmosService = cosmosService;
        }

        [FunctionName(nameof(CosmosQueryHttpTrigger))]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string color = req.Query["color"];
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            color = color ?? data?.color;

            var response = await _cosmosService.GetFruitByColor(color);

            return new OkObjectResult(response);
        }
    }
}
