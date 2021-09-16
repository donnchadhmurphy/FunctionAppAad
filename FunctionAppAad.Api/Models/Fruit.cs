using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace FunctionAppAad.Api.Models
{
    [JsonObject(NamingStrategyType = typeof(CamelCaseNamingStrategy))]
    public class Fruit
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Color { get; set; }
    }
}
