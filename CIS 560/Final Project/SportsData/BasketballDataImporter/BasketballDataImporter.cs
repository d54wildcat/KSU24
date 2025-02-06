using System.Data;
using System.Collections.Generic;
using System.Data.SqlClient;
using FantasyData.Api.Client;
using FantasyData.Api.Client.Model;
using BasketballAPI.Models;

namespace BasketballDataImporter
{
    public class BasketballDataImporter
    {
        private readonly string _connectionString;
        private readonly CBBv3StatsClient _fantasyDataClient;

        public BasketballDataImporter(string apiKey)
        {
            _fantasyDataClient = new CBBv3StatsClient(apiKey);
        }

        public async Task ImportPlayersIntoTables()
        {
            try
            {
                List<Player> players = await _fantasyDataClient.GetPlayersAsync();


            }
        }
    }
}