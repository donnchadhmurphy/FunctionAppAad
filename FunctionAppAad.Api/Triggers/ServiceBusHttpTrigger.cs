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
    public class ServiceBusHttpTrigger
    {
        private readonly ISBService _sBService;

        public ServiceBusHttpTrigger(ISBService sBService)
        {
            _sBService = sBService;
        }


        [FunctionName(nameof(ServiceBusHttpTrigger))]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            string message = req.Query["message"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);


            message = message ?? data?.message;

            var response = await _sBService.PostMessage(message);

            return new OkObjectResult(response.Content.ReadAsStringAsync());
        }
    }
}
