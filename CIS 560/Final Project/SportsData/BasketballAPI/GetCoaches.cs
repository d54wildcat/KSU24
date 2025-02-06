using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BasketballAPI
{
    public class GetCoaches
    {
        public static Dictionary<string, (int, int)> CoachesAndYearsAndTeamID { get; } = new Dictionary<string, (int, int)>()
        {
            {"Tommy Lloyd", (3, 247)},//Arizona
            {"Bobby Hurley", (9, 255)},//Arizona State
            {"Scott Drew", (21, 108)},//Baylor
            {"Kevin Young", (0, 336)},//BYU
            {"Wes Miller", (3, 4)},//Cincinnati
            {"Tad Boyle", (14, 250)},//Colorado
            {"Kelvin Sampson", (10, 6)},//Houston
            {"T.J. Otzelberger", (3, 110)},//Iowa State
            {"Bill Self", (21, 106)},//KU
            {"Jerome Tang", (2, 112)},//K-State
            {"Steve Lutz", (0, 113)},//OSU
            {"Jamie Dixon", (8, 114)},//TCU
            {"Grant McCasland", (1, 111)},//Tech
            {"Johnny Dawkins", (8, 8)},//UCF
            {"Craig Smith", (3, 248)},//Utah
            {"Darian DeVries", (0, 107)},//WVU
            {"Nate Oats", (5, 275)},//Alabama
            {"John Calipari", (0, 275)},//Arkansas
            {"Bruce Pearl", (10, 276) },//Auburn
            {"Todd Golden", (2,271) },//Florida
            {"Mike White", (2, 272)},//Georgia
            {"Mark Pope", (0, 268)},//Kentucky
            {"Matt McMahon", (2, 269)},//LSU
            {"Chris Jans", (2, 278)},//Mississippi State
            {"Dennis Gates", (2, 280)},//Mizzou
            {"Porter Moser", (3, 105)},//Oklahoma
            {"Chris Beard", (1, 274)},//Ole Miss
            {"Lamont Paris", (2, 267)},//South Carolina
            {"Rick Barnes", (9, 277)},//Tennessee
            {"Rodney Terry", (2, 109)},//Texas
            {"Buzz Williams", (5, 270)},//A&M
            {"Mark Byington", (0, 273)}//Vanderbilt



        };

        public static List<string> GetCoachNames()
        {
            // Retrieve coaches names from the dictionary keys
            return CoachesAndYearsAndTeamID.Keys.ToList();
        }

        public static List<(int, int)> GetCoachesYears()
        {
            // Retrieve years coached from the dictionary values
            return CoachesAndYearsAndTeamID.Values.ToList();
        }
    }
}
