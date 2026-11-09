namespace RaceDay.MVC.Models
{
    public class Event
    {
        public int EventId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public string Location { get; set; } = string.Empty;
        public string Distance { get; set; } = string.Empty;
        public string EventType { get; set; } = string.Empty;
    }
}