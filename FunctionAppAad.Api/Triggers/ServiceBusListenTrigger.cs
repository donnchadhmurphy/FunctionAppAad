using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace FunctionAppAad.Api.Triggers
{
    public static class ServiceBusListenTrigger
    {
        [FunctionName(nameof(ServiceBusListenTrigger))]
        public static void Run([ServiceBusTrigger("sbq-faad-demo", Connection = "ServiceBusConnection")] string myQueueItem, ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
