using Microsoft.AspNetCore.Mvc;
using RaceDay.MVC.Models;
using System.Text;
using System.Text.Json;

namespace RaceDay.MVC.Controllers
{
    public class AuthController : Controller
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;

        public AuthController(IConfiguration config)
        {
            _config = config;
            _httpClient = new HttpClient();
        }

        [HttpGet]
        public IActionResult Login() => View();

        [HttpPost]
        public async Task<IActionResult> Login(string email, string password)
        {
            var loginData = new { Email = email, Password = password };
            var json = JsonSerializer.Serialize(loginData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync($"{_config["ApiSettings:BaseUrl"]}/api/Auth/login", content);

            if (response.IsSuccessStatusCode)
            {
                var responseJson = await response.Content.ReadAsStringAsync();
                var user = JsonSerializer.Deserialize<Participant>(responseJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                // SESSION MANAGEMENT
                HttpContext.Session.SetString("UserEmail", user.Email);
                HttpContext.Session.SetString("UserRole", "Participant");

                return RedirectToAction("Index", "Home");
            }

            ViewBag.Error = "Invalid email or password.";
            return View();
        }

        [HttpGet]
        public IActionResult Register() => View();

        [HttpPost]
        public async Task<IActionResult> Register(Participant participant)
        {
            var json = JsonSerializer.Serialize(participant);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync($"{_config["ApiSettings:BaseUrl"]}/api/Auth/register", content);

            if (response.IsSuccessStatusCode)
            {
                return RedirectToAction("Login");
            }

            ViewBag.Error = "Registration failed. Email might already exist.";
            return View();
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }
    }
}