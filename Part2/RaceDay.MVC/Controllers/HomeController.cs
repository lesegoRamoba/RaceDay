using Microsoft.AspNetCore.Mvc;
using RaceDay.MVC.Models;
using System.Text.Json;

namespace RaceDay.MVC.Controllers
{
    public class HomeController : Controller
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;

        public HomeController(IConfiguration config)
        {
            _config = config;
            _httpClient = new HttpClient();
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_config["ApiSettings:BaseUrl"]}/api/Events");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var events = JsonSerializer.Deserialize<List<Event>>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    return View(events);
                }
            }
            catch (Exception ex)
            {
                // If API is unreachable inside Docker, it will catch the error here
                Console.WriteLine($"Error fetching events: {ex.Message}");
            }

            return View(new List<Event>());
        }
    }
}