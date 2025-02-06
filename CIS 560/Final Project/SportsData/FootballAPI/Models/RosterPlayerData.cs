using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FootballAPI.Models
{
    public class RosterPlayerData
    {
        public string first_name { get; set; } = ""; 
        public string last_name { get; set; } = "";
        public string team { get; set; } = "";
        public int weight { get; set; }
        public int height { get; set; }
        public int year { get; set; }
        public string position { get; set; } = "";
        public string home_city { get; set; } = "";
        public string home_state { get; set; } = "";
        public int jersey { get; set; }

    }
}
