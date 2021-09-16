using Azure.Identity;
using FunctionAppAad.Api.Interfaces;
using FunctionAppAad.Api.Services;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.IO;
using System.Net.Http.Headers;

[assembly: FunctionsStartup(typeof(FunctionAppAad.Api.Startup))]
namespace FunctionAppAad.Api
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var config = BuildConfig();

            builder.Services.AddHttpClient<ISBService, SBService>(client =>
            {
                var credential = new DefaultAzureCredential();
                var token = credential.GetToken(
                    new Azure.Core.TokenRequestContext(
                        new[] { "https://servicebus.azure.net" }));

                client.BaseAddress = new Uri($"https://{config.GetValue<string>("ServiceBusConnection:fullyQualifiedNamespace")}/sbq-faad-demo/messages");
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token.Token);
            });

            builder.Services.AddSingleton<ICosmosService>((s) =>
            {
                return new CosmosService(config.GetValue<string>("CosmosEndpoint"));
            });
        }

        private IConfiguration BuildConfig()
        {
            var configBuilder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables();

            return configBuilder.Build();
        }
    }
}
