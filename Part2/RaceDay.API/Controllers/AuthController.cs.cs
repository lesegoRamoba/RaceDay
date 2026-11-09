using Microsoft.AspNetCore.Mvc;
using RaceDay.API.Data;
using RaceDay.API.Models;
using Microsoft.EntityFrameworkCore;

namespace RaceDay.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly RaceDayDbContext _context;

        public AuthController(RaceDayDbContext context)
        {
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] Participant participant)
        {
            if (await _context.Participants.AnyAsync(p => p.Email == participant.Email))
                return BadRequest("Email already exists.");

            _context.Participants.Add(participant);
            await _context.SaveChangesAsync();
            return Ok(participant);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Participant loginRequest)
        {
            var user = await _context.Participants.FirstOrDefaultAsync(p => p.Email == loginRequest.Email && p.Password == loginRequest.Password);

            if (user == null)
                return Unauthorized("Invalid email or password.");

            // For simplicity in this assignment, we return the user object (including their Role if you have one)
            return Ok(user);
        }
    }
}