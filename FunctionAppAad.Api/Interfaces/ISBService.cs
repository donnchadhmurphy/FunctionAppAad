using System.Net.Http;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Interfaces
{
    public interface ISBService
    {
        Task<HttpResponseMessage> PostMessage(string message);
    }
}
