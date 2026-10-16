
using System;

namespace RaceDay.API.Models
{
    public class Registration
    {
        public int RegistrationId { get; set; }
        public int EventId { get; set; }
        public int ParticipantId { get; set; }
        public DateTime RegistrationDate { get; set; }
    }
}
