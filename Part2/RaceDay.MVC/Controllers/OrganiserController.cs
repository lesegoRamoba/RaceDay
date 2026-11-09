using Microsoft.AspNetCore.Mvc;
using System.Net.Http.Headers;

namespace RaceDay.MVC.Controllers
{
    public class OrganiserController : Controller
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;

        public OrganiserController(IConfiguration config)
        {
            _config = config;
            _httpClient = new HttpClient();
        }

        public IActionResult Dashboard()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> UploadBanner(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                TempData["Error"] = "Please select a file.";
                return RedirectToAction("Dashboard");
            }

            using var content = new MultipartFormDataContent();
            var fileContent = new StreamContent(file.OpenReadStream());
            fileContent.Headers.ContentType = new MediaTypeHeaderValue(file.ContentType);
            content.Add(fileContent, "file", file.FileName);

            // Send file to the API (API then sends to Azure)
            var response = await _httpClient.PostAsync($"{_config["ApiSettings:BaseUrl"]}/api/Blob/upload", content);

            if (response.IsSuccessStatusCode)
            {
                TempData["Success"] = "Image successfully uploaded to Azure via the API!";
            }
            else
            {
                TempData["Error"] = "Upload failed. Ensure the API and Azurite are running.";
            }

            return RedirectToAction("Dashboard");
        }
    }
}