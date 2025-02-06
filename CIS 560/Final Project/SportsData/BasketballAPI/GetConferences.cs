using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BasketballAPI
{
    public class GetConferences
    {
        public static Dictionary<string, string> ConferenceNamesAndAbv{ get; } = new Dictionary<string, string>
    {
        { "American Atlantic", "AAC" },
        { "America East", "AmEast" },
        { "Atlantic Coast", "ACC" },
        { "Atlantic Sun", "ASun" },
        { "Atlantic 10", "A10" },
        { "Big East", "BE" },
        { "Big Sky", "BSky" },
        { "Big South", "BSouth" },
        { "Big Ten", "B1G" },
        { "Big 12", "B12" },
        { "Big West", "BWC" },
        { "Costal Athletic Association", "CAA" },
        { "Conference USA", "C-USA" },
        { "Horizon", "HL" },
        {"Independents", "IND" },
        { "Ivy", "IL" },
        { "Metro Atlantic Athletic", "MAAC" },
        { "Mid-American", "MAC" },
        { "Mid-Eastern", "MEAC" },
        { "Missouri Valley", "MVC" },
        { "Moutain West", "MWC" },
        { "Northeast", "NEC" },
        { "Ohio Valley", "OVC" },
        { "Pac-12", "PAC-12" },
        { "Patriot League", "PL" },
        { "Southeastern", "SEC" },
        { "Southern", "SoCon" },
        { "Southland", "SLC" },
        { "Southwestern Athletic", "SWAC" },
        { "Summit", "SL" },
        { "Sun Belt", "SBC" },
        { "West Coast", "WCC" },
        { "Western Athletic", "WAC" },
    };

        public static List<string> GetConferenceNames()
        {
            // Retrieve conference names from the dictionary keys
            return ConferenceNamesAndAbv.Keys.ToList();
        }

        public static List<string> GetConferenceShortNames()
        {
            // Retrieve conference abbreviations from the dictionary values
            return ConferenceNamesAndAbv.Values.ToList();
        }
    }
}
