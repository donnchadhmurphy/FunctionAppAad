using FunctionAppAad.Api.Interfaces;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Services
{
    public class SBService : ISBService
    {
        private readonly HttpClient _httpClient;

        public SBService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public Task<HttpResponseMessage> PostMessage(string message)
        {
            var request = new StringContent(message, Encoding.UTF8, "application/json");
            return _httpClient.PostAsync(_httpClient.BaseAddress, request);
        }
    }
}
