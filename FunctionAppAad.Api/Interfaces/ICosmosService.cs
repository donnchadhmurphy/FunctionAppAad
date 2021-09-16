using FunctionAppAad.Api.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FunctionAppAad.Api.Interfaces
{
    public interface ICosmosService
    {
        Task<IEnumerable<Fruit>> GetFruitByColor(string color);
        Task<Fruit> StoreFruit(Fruit fruit);
    }
}
