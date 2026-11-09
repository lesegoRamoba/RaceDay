using Microsoft.AspNetCore.Mvc;
using Azure.Storage.Blobs;

namespace RaceDay.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BlobController : ControllerBase
    {
        private readonly IConfiguration _config;

        public BlobController(IConfiguration config)
        {
            _config = config;
        }

        [HttpPost("upload")]
        public async Task<IActionResult> Upload(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            var connectionString = _config.GetConnectionString("AzureStorage");
            var blobServiceClient = new BlobServiceClient(connectionString);

            var containerClient = blobServiceClient.GetBlobContainerClient("event-banners");
            await containerClient.CreateIfNotExistsAsync();

            var blobClient = containerClient.GetBlobClient(file.FileName);
            using var stream = file.OpenReadStream();
            await blobClient.UploadAsync(stream, true);

            return Ok(new { Url = blobClient.Uri.ToString() });
        }
    }
}